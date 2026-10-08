/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "AdapterInfoBluez.h"
#include "AdapterInfoUtils.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusArgument>
#include <QDBusObjectPath>
#include <QDBusPendingCallWatcher>
#include <QDBusError>

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QMap>
#include <QProcess>
#include <QDebug>

/* ************************************************************************** */

static const QString s_service = QStringLiteral("org.bluez");
static const QString s_iface_adapter = QStringLiteral("org.bluez.Adapter1");
static const QString s_iface_advertising = QStringLiteral("org.bluez.LEAdvertisingManager1");
static const QString s_iface_objects = QStringLiteral("org.freedesktop.DBus.ObjectManager");
static const QString s_iface_properties = QStringLiteral("org.freedesktop.DBus.Properties");

/*!
 * \brief Read a DICT<STRING, DICT<STRING, VARIANT>> (interfaces and their properties).
 */
static QMap <QString, QVariantMap> readInterfaces(const QDBusArgument &arg)
{
    QMap <QString, QVariantMap> interfaces;

    arg.beginMap();
    while (!arg.atEnd())
    {
        QString iface;
        QVariantMap props;
        arg.beginMapEntry();
        arg >> iface >> props;
        arg.endMapEntry();
        interfaces.insert(iface, props);
    }
    arg.endMap();

    return interfaces;
}

/*!
 * \brief Convert a nested a{sv} property value, still marshalled as a QDBusArgument.
 */
static QVariantMap toVariantMap(const QVariant &value)
{
    if (value.metaType() == QMetaType::fromType<QDBusArgument>())
    {
        return qdbus_cast<QVariantMap>(value.value<QDBusArgument>());
    }
    return value.toMap();
}

/* ************************************************************************** */

AdapterInfoBluez::AdapterInfoBluez(QObject *parent) : AdapterInfo(parent)
{
    //
}

void AdapterInfoBluez::query(const QBluetoothAddress &address)
{
    m_address = address;

    watchObjects();
    queryObjects();
    queryBtmgmt();
}

/* ************************************************************************** */

void AdapterInfoBluez::watchObjects()
{
    if (m_watching) return;

    QDBusConnection bus = QDBusConnection::systemBus();

    bool added = bus.connect(s_service, QStringLiteral("/"), s_iface_objects,
                             QStringLiteral("InterfacesAdded"),
                             this, SLOT(interfacesAdded(QDBusMessage)));
    bool removed = bus.connect(s_service, QStringLiteral("/"), s_iface_objects,
                               QStringLiteral("InterfacesRemoved"),
                               this, SLOT(interfacesRemoved(QDBusMessage)));

    m_watching = added && removed;
    if (!m_watching)
    {
        qWarning() << "AdapterInfoBluez::watchObjects() unable to watch BlueZ objects:"
                   << bus.lastError().message();
    }
}

void AdapterInfoBluez::queryObjects()
{
    if (m_objectsCall) return; // already running

    QDBusMessage msg = QDBusMessage::createMethodCall(s_service, QStringLiteral("/"), s_iface_objects,
                                                      QStringLiteral("GetManagedObjects"));

    m_objectsCall = new QDBusPendingCallWatcher(QDBusConnection::systemBus().asyncCall(msg), this);
    connect(m_objectsCall, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *call) {
        m_objectsCall = nullptr;
        call->deleteLater();

        const QDBusMessage reply = call->reply();
        if (reply.type() != QDBusMessage::ReplyMessage || reply.arguments().isEmpty())
        {
            qWarning() << "AdapterInfoBluez::queryObjects() GetManagedObjects failed:" << reply.errorMessage();
            return;
        }

        // GetManagedObjects() > DICT<OBJPATH, DICT<STRING, DICT<STRING, VARIANT>>>
        const QDBusArgument arg = reply.arguments().constFirst().value<QDBusArgument>();
        arg.beginMap();
        while (!arg.atEnd())
        {
            QDBusObjectPath path;
            arg.beginMapEntry();
            arg >> path;
            const QMap <QString, QVariantMap> interfaces = readInterfaces(arg);
            arg.endMapEntry();

            const auto adapter = interfaces.constFind(s_iface_adapter);
            if (adapter != interfaces.cend() && QBluetoothAddress(adapter->value(QStringLiteral("Address")).toString()) == m_address)
            {
                setAdapter(path.path(), *adapter, interfaces.value(s_iface_advertising));
            }
        }
        arg.endMap();
    });
}

void AdapterInfoBluez::queryBtmgmt()
{
    if (m_btmgmt) return; // already running

    m_btmgmt = startProcess("btmgmt", QStringList("info"), [this](const QString &output) {
        parseBtmgmt(output);
        updateDetails();
    });
    if (m_btmgmt)
    {
        connect(m_btmgmt, &QObject::destroyed, this, [this]() { m_btmgmt = nullptr; });
    }
}

/* ************************************************************************** */

void AdapterInfoBluez::setAdapter(const QString &path, const QVariantMap &adapterProps,
                                  const QVariantMap &advertisingProps)
{
    if (m_path != path)
    {
        QDBusConnection bus = QDBusConnection::systemBus();

        if (!m_path.isEmpty())
        {
            bus.disconnect(s_service, m_path, s_iface_properties, QStringLiteral("PropertiesChanged"),
                           this, SLOT(propertiesChanged(QString,QVariantMap,QStringList)));
        }

        m_path = path;

        if (!m_path.isEmpty())
        {
            if (!bus.connect(s_service, m_path, s_iface_properties, QStringLiteral("PropertiesChanged"),
                             this, SLOT(propertiesChanged(QString,QVariantMap,QStringList))))
            {
                qWarning() << "AdapterInfoBluez::setAdapter() unable to watch" << m_path << bus.lastError().message();
            }
        }
    }

    if (m_path.isEmpty()) return; // keep the last known details

    m_adapterProps = adapterProps;
    m_advertisingProps = advertisingProps;
    readUsbId();
    updateDetails();
}

void AdapterInfoBluez::readUsbId()
{
    m_usbId.clear();

    const QString hci = m_path.section('/', -1);
    if (!hci.startsWith(QLatin1String("hci"))) return;

    const QString usbInterface = QFileInfo("/sys/class/bluetooth/" + hci + "/device").canonicalFilePath();
    if (usbInterface.isEmpty()) return;

    QDir usbDevice(usbInterface);
    if (!usbDevice.cdUp()) return;

    auto readId = [&usbDevice](const QString &file) {
        QFile f(usbDevice.filePath(file));
        if (!f.open(QIODevice::ReadOnly)) return QString();
        return QString::fromLatin1(f.readAll()).trimmed();
    };

    const QString vendor = readId("idVendor");
    const QString product = readId("idProduct");
    if (!vendor.isEmpty() && !product.isEmpty()) m_usbId = vendor + ':' + product;
}

/* ************************************************************************** */

void AdapterInfoBluez::propertiesChanged(const QString &interface, const QVariantMap &changed,
                                         const QStringList &invalidated)
{
    QVariantMap *props = nullptr;
    if (interface == s_iface_adapter) props = &m_adapterProps;
    else if (interface == s_iface_advertising) props = &m_advertisingProps;
    else return;

    for (auto it = changed.cbegin(); it != changed.cend(); ++it) props->insert(it.key(), it.value());
    for (const auto &key: invalidated) props->remove(key);

    updateDetails();
}

void AdapterInfoBluez::interfacesAdded(const QDBusMessage &msg)
{
    // InterfacesAdded(OBJPATH object_path, DICT<STRING, DICT<STRING, VARIANT>> interfaces_and_properties)
    const QList <QVariant> args = msg.arguments();
    if (args.size() < 2) return;

    const QString path = args.at(0).value<QDBusObjectPath>().path();
    const QMap <QString, QVariantMap> interfaces = readInterfaces(args.at(1).value<QDBusArgument>());

    const auto adapter = interfaces.constFind(s_iface_adapter);
    if (adapter != interfaces.cend())
    {
        // the adapter is back (plugged in, or bluetoothd restarted)
        if (QBluetoothAddress(adapter->value(QStringLiteral("Address")).toString()) == m_address)
        {
            setAdapter(path, *adapter, interfaces.value(s_iface_advertising));
        }
    }
    else if (path == m_path && interfaces.contains(s_iface_advertising))
    {
        // the adapter has been powered on
        m_advertisingProps = interfaces.value(s_iface_advertising);
        updateDetails();
    }
}

void AdapterInfoBluez::interfacesRemoved(const QDBusMessage &msg)
{
    // InterfacesRemoved(OBJPATH object_path, ARRAY<STRING> interfaces)
    const QList <QVariant> args = msg.arguments();
    if (args.size() < 2) return;

    const QString path = args.at(0).value<QDBusObjectPath>().path();
    if (path.isEmpty() || path != m_path) return;

    const QStringList interfaces = args.at(1).toStringList();
    if (interfaces.contains(s_iface_adapter))
    {
        setAdapter(QString(), {}, {});
    }
    else if (interfaces.contains(s_iface_advertising))
    {
        // the adapter has been powered off, keep its capabilities
        m_advertisingProps.remove(QStringLiteral("ActiveInstances"));
        updateDetails();
    }
}

/* ************************************************************************** */

void AdapterInfoBluez::parseBtmgmt(const QString &output)
{
    // Output example:
    // hci1:	Primary controller
    // 	addr 00:11:22:33:44:55 version 13 manufacturer 2279 class 0x6c0104
    // 	supported settings: powered connectable fast-connectable discoverable bondable link-security ssp br/edr le advertising
    //                      secure-conn debug-keys privacy static-addr phy-configuration ll-privacy
    // 	current settings: powered ssp br/edr le secure-conn ll-privacy
    // 	name desktop-emeric #2
    // 	short name

    const QString address = m_address.toString();
    const QString supported = QStringLiteral("supported settings:");

    const QStringList lines = output.split('\n');
    for (int i = 0; i < lines.size(); i++)
    {
        const QString line = lines.at(i).trimmed();
        if (!line.startsWith(QLatin1String("addr ")) || !line.contains(address)) continue;

        const QStringList line_split = line.split(' ', Qt::SkipEmptyParts);
        for (int j = 0; j + 1 < line_split.size(); j++)
        {
            const auto &section = line_split.at(j);
            if (section == "version")
            {
                bool ok = false;
                const int version = line_split.at(++j).toInt(&ok);
                if (ok) m_mgmtVersion = version;
            }
            else if (section == "manufacturer")
            {
                bool ok = false;
                const int manufacturer = line_split.at(++j).toInt(&ok);
                if (ok) m_mgmtManufacturer = manufacturer;
            }
        }

        for (int j = i + 1; j < lines.size(); j++)
        {
            const QString next = lines.at(j).trimmed();
            if (next.startsWith(QLatin1String("addr ")) || next.startsWith(QLatin1String("hci"))) break;

            if (next.startsWith(supported))
            {
                m_mgmtSettings = next.mid(supported.size()).split(' ', Qt::SkipEmptyParts);
                break;
            }
        }

        break;
    }
}

/* ************************************************************************** */

void AdapterInfoBluez::updateDetails()
{
    AdapterDetails d;

    // org.bluez.Adapter1
    const QVariantMap &a = m_adapterProps;

    d.name = a.value(QStringLiteral("Name")).toString();
    d.alias = a.value(QStringLiteral("Alias")).toString();
    d.addressType = a.value(QStringLiteral("AddressType")).toString();
    d.usbId = m_usbId;

    const QVariant version = a.value(QStringLiteral("Version"));
    if (version.isValid()) d.coreVersion = AdapterInfoUtils::coreVersionString(version.toInt());
    else if (m_mgmtVersion >= 0) d.coreVersion = AdapterInfoUtils::coreVersionString(m_mgmtVersion);

    const QVariant manufacturer = a.value(QStringLiteral("Manufacturer"));
    d.manufacturerId = manufacturer.isValid() ? manufacturer.toInt() : m_mgmtManufacturer;

    const QVariant rolesValue = a.value(QStringLiteral("Roles"));
    if (rolesValue.isValid())
    {
        const QStringList roles = rolesValue.toStringList();
        d.centralRole = roles.contains(QLatin1String("central"));
        d.peripheralRole = roles.contains(QLatin1String("peripheral"));
        d.lowEnergy = !roles.isEmpty();
    }

    // org.bluez.LEAdvertisingManager1
    const QVariantMap &adv = m_advertisingProps;
    if (!adv.isEmpty())
    {
        d.lowEnergy = true;

        const QVariant instances = adv.value(QStringLiteral("SupportedInstances"));
        if (instances.isValid()) d.advertisingInstances = instances.toInt();

        const QVariant active = adv.value(QStringLiteral("ActiveInstances"));
        if (active.isValid()) d.activeAdvertisingInstances = active.toInt();

        const QVariant channels = adv.value(QStringLiteral("SupportedSecondaryChannels"));
        if (channels.isValid())
        {
            d.phys = channels.toStringList();
            d.extendedAdvertising = !d.phys.isEmpty();
        }

        const QVariantMap caps = toVariantMap(adv.value(QStringLiteral("SupportedCapabilities")));
        if (caps.contains(QStringLiteral("MaxAdvLen"))) d.maxAdvertisingLength = caps.value(QStringLiteral("MaxAdvLen")).toInt();
        if (caps.contains(QStringLiteral("MaxScnRspLen"))) d.maxScanResponseLength = caps.value(QStringLiteral("MaxScnRspLen")).toInt();
        if (caps.contains(QStringLiteral("MinTxPower"))) d.txPowerMin = caps.value(QStringLiteral("MinTxPower")).toInt();
        if (caps.contains(QStringLiteral("MaxTxPower"))) d.txPowerMax = caps.value(QStringLiteral("MaxTxPower")).toInt();

        const QVariant features = adv.value(QStringLiteral("SupportedFeatures"));
        if (features.isValid())
        {
            d.advertisingOffload = features.toStringList().contains(QLatin1String("HardwareOffload"));
        }
    }

    // mgmt supported settings
    if (!m_mgmtSettings.isEmpty())
    {
        d.settings = m_mgmtSettings;
        d.classic = m_mgmtSettings.contains(QLatin1String("br/edr"));
        d.lowEnergy = m_mgmtSettings.contains(QLatin1String("le"));
        d.leSecureConnections = m_mgmtSettings.contains(QLatin1String("secure-conn"));
    }

    setDetails(d);
}

/* ************************************************************************** */
