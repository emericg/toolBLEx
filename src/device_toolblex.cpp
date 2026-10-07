/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "device_toolblex.h"
#include "BleServiceInfo.h"
#include "BleCharacteristicInfo.h"
#include "BleDescriptorInfo.h"
#include "BleFormat.h"
#include "DeviceProfile.h"
#include "DeviceManager.h"
#include "SettingsManager.h"

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

#include <QSqlQuery>
#include <QSqlError>

#include <QHash>
#include <QDateTime>
#include <QTimer>
#include <QDebug>

#include <algorithm>

/* ************************************************************************** */
/* ************************************************************************** */

/*!
 * \brief Presentation format matching a write type string.
 * \param type: ex: "uint24_le", "int16_be", "float32_le", "utf8".
 * \return one of the GATT format types, FORMAT_RFU if unknown.
 */
static uint8_t formatFromType(const QString &type)
{
    static const QHash <QString, uint8_t> formats = {
        { QStringLiteral("uint8"),   BleFormat::FORMAT_UINT8 },
        { QStringLiteral("uint16"),  BleFormat::FORMAT_UINT16 },
        { QStringLiteral("uint24"),  BleFormat::FORMAT_UINT24 },
        { QStringLiteral("uint32"),  BleFormat::FORMAT_UINT32 },
        { QStringLiteral("uint48"),  BleFormat::FORMAT_UINT48 },
        { QStringLiteral("uint64"),  BleFormat::FORMAT_UINT64 },
        { QStringLiteral("int8"),    BleFormat::FORMAT_SINT8 },
        { QStringLiteral("int16"),   BleFormat::FORMAT_SINT16 },
        { QStringLiteral("int24"),   BleFormat::FORMAT_SINT24 },
        { QStringLiteral("int32"),   BleFormat::FORMAT_SINT32 },
        { QStringLiteral("int48"),   BleFormat::FORMAT_SINT48 },
        { QStringLiteral("int64"),   BleFormat::FORMAT_SINT64 },
        { QStringLiteral("float32"), BleFormat::FORMAT_FLOAT32 },
        { QStringLiteral("float64"), BleFormat::FORMAT_FLOAT64 },
        { QStringLiteral("utf8"),    BleFormat::FORMAT_UTF8S },
    };

    return formats.value(type.section(QLatin1Char('_'), 0, 0), BleFormat::FORMAT_RFU);
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceToolBLEx::DeviceToolBLEx(const QString &deviceAddr, const QString &deviceName,
                               QObject *parent): Device(deviceAddr, deviceName, parent)
{
    // Creation from database cache

    m_isCached = true;
    m_hasServiceCache = checkServiceCache();

    m_deviceLog_obj = new DeviceLogModel(s_max_entries_logs, this);

    m_advertisementDataModel = new AdvertisementDataModel(this);
    m_advertisementFilterModel = new AdvertisementFilterModel(this);
    m_advertisementFilterModel->setSourceModel(m_advertisementDataModel);
    m_advertisementFilterModel->setDynamicSortFilter(true);

    getSqlDeviceInfos();
}

/* ************************************************************************** */

DeviceToolBLEx::DeviceToolBLEx(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    // Creation from BLE scanning

    QDateTime timestamp = QDateTime::currentDateTime();

    m_isCached = (d.rssi() == 0);
    m_hasServiceCache = checkServiceCache();
    m_bluetoothCoreConfiguration = d.coreConfigurations();
    m_firstSeen = timestamp;

    m_deviceLog_obj = new DeviceLogModel(s_max_entries_logs, this);

    m_advertisementDataModel = new AdvertisementDataModel(this);
    m_advertisementFilterModel = new AdvertisementFilterModel(this);
    m_advertisementFilterModel->setSourceModel(m_advertisementDataModel);
    m_advertisementFilterModel->setDynamicSortFilter(true);

    bool hasmfd = false;
    bool hassvd = false;
    parseAdvertisement(d, QDateTime::currentDateTime(), hasmfd, hassvd);
    addAdvertisementEntry(timestamp, d.rssi(), hasmfd, hassvd);

    getSqlDeviceInfos();
}

/* ************************************************************************** */

DeviceToolBLEx::~DeviceToolBLEx()
{
    qDeleteAll(m_services);
    m_services.clear();

    qDeleteAll(m_advertisementEntries);
    m_advertisementEntries.clear();

    qDeleteAll(m_svd_uuid);
    m_svd_uuid.clear();

    qDeleteAll(m_mfd_uuid);
    m_mfd_uuid.clear();

    m_deviceLog_obj->clear();
    delete m_deviceLog_obj;

    m_advertisementDataModel->clear();
    delete m_advertisementDataModel;
    delete m_advertisementFilterModel;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceToolBLEx::getSqlDeviceInfos()
{
    //qDebug() << "Device::getSqlDeviceInfos(" << m_deviceAddress << ")";
    bool status = false;

    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery getInfos;
        getInfos.prepare("SELECT deviceAddrMAC, deviceModel, deviceModelID, deviceManufacturer," \
                           "deviceFirmware, deviceBattery," \
                           "deviceCoreConfig, deviceClass," \
                           "starred, comment, color," \
                           "firstSeen, lastSeen " \
                         "FROM devices WHERE deviceAddr = :deviceAddr");
        getInfos.bindValue(":deviceAddr", getAddress());
        if (getInfos.exec())
        {
            while (getInfos.next())
            {
                m_deviceAddressMAC = getInfos.value(0).toString();
                m_deviceModel = getInfos.value(1).toString();
                m_deviceModelID = getInfos.value(2).toString();
                m_deviceManufacturer = getInfos.value(3).toString();

                m_deviceFirmware = getInfos.value(4).toString();
                if (!getInfos.isNull(5)) m_deviceBattery = getInfos.value(5).toInt();

                m_bluetoothCoreConfiguration = getInfos.value(6).toInt();
                m_isBLE = (m_bluetoothCoreConfiguration == 1 || m_bluetoothCoreConfiguration == 3);
                m_isClassic = (m_bluetoothCoreConfiguration == 2 || m_bluetoothCoreConfiguration == 3);

                QString deviceClass = getInfos.value(7).toString();
                QStringList dc = deviceClass.split('-');
                if (dc.size() == 3)
                {
                    Device::setDeviceClass(dc.at(0).toInt(), dc.at(1).toInt(), dc.at(2).toInt());
                }

                m_userStarred = getInfos.value(8).toInt();
                m_userComment = getInfos.value(9).toString();
                m_userColor = getInfos.value(10).toString();

                m_firstSeen = getInfos.value(11).toDateTime();
                m_lastSeen = getInfos.value(12).toDateTime();

                QString settings = getInfos.value(11).toString();
                QJsonDocument doc = QJsonDocument::fromJson(settings.toUtf8());
                if (!doc.isNull() && doc.isObject())
                {
                    m_additionalSettings = doc.object();
                }

                status = true;
            }
        }
        else
        {
            qWarning() << "> getInfos.exec() ERROR"
                       << getInfos.lastError().type() << ":" << getInfos.lastError().text();
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

QString DeviceToolBLEx::getName_display() const
{
    QString prettyname = m_deviceName;
    prettyname.replace('\n', "↵");

    return prettyname;
}

QString DeviceToolBLEx::getAddr_display() const
{
    QString prettyaddr;

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    prettyaddr = m_bleDevice.deviceUuid().toString();
#else
    prettyaddr = m_bleDevice.address().toString();
#endif

    return prettyaddr;
}

QString DeviceToolBLEx::getName_export() const
{
    QString prettyname = m_deviceName;
    prettyname.replace('\n', '_');
    prettyname.replace(' ', '_');

    prettyname.replace('/', '_'); // on every platform
    prettyname.replace('#', '_'); // but why?

#if defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
    prettyname.replace(':', '_');
#elif defined(Q_OS_WINDOWS)
    prettyname.replace('<', '_');
    prettyname.replace('>', '_');
    prettyname.replace('"', '_');
    prettyname.replace('\\', '_');
    prettyname.replace('|', '_');
    prettyname.replace('?', '_');
    prettyname.replace('*', '_');
#endif

    return prettyname;
}

QString DeviceToolBLEx::getAddr_export() const
{
    QString prettyaddr;

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    prettyaddr = m_bleDevice.deviceUuid().toString();
#else
    prettyaddr = m_bleDevice.address().toString();
#endif

#if defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
    prettyaddr.replace(':', "");
#endif

    return prettyaddr;
}

/* ************************************************************************** */

void DeviceToolBLEx::setDeviceClass(const int major, const int minor, const int service)
{
    if (m_major != major || m_minor != minor || m_service != service)
    {
        Device::setDeviceClass(major, minor, service);
        updateCache();
    }
}

void DeviceToolBLEx::setCoreConfiguration(const int bleconf)
{
    if (bleconf > 0)
    {
        if (bleconf == 1 && !m_isBLE)
        {
            m_isBLE = true;
            Q_EMIT boolChanged();

            Device::setCoreConfiguration(bleconf);
            updateCache();
        }
        else if (bleconf == 2 && !m_isClassic)
        {
            m_isClassic = true;
            Q_EMIT boolChanged();

            Device::setCoreConfiguration(bleconf);
            updateCache();
        }
        else
        {
            Device::setCoreConfiguration(bleconf);
        }
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::setBeacon(bool v)
{
    if (m_isBeacon != v)
    {
        m_isBeacon = v;
        Q_EMIT boolChanged();

        static_cast<DeviceManager *>(parent())->invalidateFilter();
    }
}

void DeviceToolBLEx::setBlacklisted(bool v)
{
    if (m_isBlacklisted != v)
    {
        m_isBlacklisted = v;
        Q_EMIT boolChanged();

        static_cast<DeviceManager *>(parent())->invalidateFilter();
    }
}

void DeviceToolBLEx::setCached(bool v)
{
    if (m_isCached != v)
    {
        m_isCached = v;
        Q_EMIT boolChanged();

        static_cast<DeviceManager *>(parent())->invalidateFilter();
    }
}

void DeviceToolBLEx::setPairingStatus(QBluetoothLocalDevice::Pairing p)
{
    if (m_pairingStatus != p)
    {
        m_pairingStatus = p;
        Q_EMIT pairingChanged();
    }
}

void DeviceToolBLEx::setDeviceColor(const QString &color)
{
    m_color = color;
}

void DeviceToolBLEx::setUserColor(const QString &color)
{
    if (m_userColor != color)
    {
        m_userColor = color;
        Q_EMIT colorChanged();

        updateCache();
    }
}

void DeviceToolBLEx::setUserComment(const QString &comment)
{
    if (m_userComment != comment)
    {
        m_userComment = comment;
        Q_EMIT commentChanged();

        updateCache();
    }
}

void DeviceToolBLEx::setUserStar(bool star)
{
    if (m_userStarred != star)
    {
        m_userStarred = star;
        Q_EMIT starChanged();

        updateCache();
    }
}

void DeviceToolBLEx::setLastSeen(const QDateTime &dt)
{
    if (m_lastSeen.toSecsSinceEpoch() / 60 != dt.toSecsSinceEpoch() / 60)
    {
        m_lastSeen = dt;
        Q_EMIT seenChanged();

        static_cast<DeviceManager *>(parent())->invalidateFilter();

        updateCache();
    }
}

bool DeviceToolBLEx::isLastSeenToday()
{
    return (m_lastSeen.secsTo(QDateTime(QDate::currentDate(), QTime(0, 0, 0))) <= 0);
}

/* ************************************************************************** */

void DeviceToolBLEx::blacklist(bool b)
{
    if (m_isBlacklisted != b)
    {
        if (b) static_cast<DeviceManager *>(parent())->blacklistBleDevice(m_deviceAddress);
        else static_cast<DeviceManager *>(parent())->whitelistBleDevice(m_deviceAddress);

        setBlacklisted(b);
    }
}

void DeviceToolBLEx::cache(bool c)
{
    if (m_isCached != c)
    {
        if (c) static_cast<DeviceManager *>(parent())->cacheDeviceSeen(m_deviceAddress);
        else static_cast<DeviceManager *>(parent())->uncacheDeviceSeen(m_deviceAddress);

        setCached(c);
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::updateCache()
{
    //qDebug() << "DeviceToolBLEx::updateCache()" << getAddress() << getName();

    if (m_dbInternal || m_dbExternal)
    {
        QString deviceClass;
        if (m_major && m_minor)
        {
            deviceClass = QString::number(m_major) + "-" +
                          QString::number(m_minor) + "-" +
                          QString::number(m_service);
        }

        QSqlQuery updateCache;
        updateCache.prepare("UPDATE devices SET "
                             "deviceCoreConfig = :deviceCoreConfig, "
                             "deviceClass = :deviceClass, "
                             "starred = :starred, "
                             "comment = :comment, "
                             "color = :color, "
                             "lastSeen = :lastSeen "
                            "WHERE deviceAddr = :deviceAddr");
        updateCache.bindValue(":deviceCoreConfig", m_bluetoothCoreConfiguration);
        updateCache.bindValue(":deviceClass", deviceClass);
        updateCache.bindValue(":starred", m_userStarred);
        updateCache.bindValue(":comment", m_userComment);
        updateCache.bindValue(":color", m_userColor);
        updateCache.bindValue(":lastSeen", m_lastSeen);
        updateCache.bindValue(":deviceAddr", getAddress());

        if (!updateCache.exec())
        {
            qWarning() << "> updateCache.exec() ERROR"
                       << updateCache.lastError().type() << ":" << updateCache.lastError().text();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::actionScanWithValues()
{
    qDebug() << "DeviceToolBLEx::actionScanWithValues()" << getAddress() << getName();
    logEvent("User asked for connection (scan with values)", LogEvent::USER);

    if (!isWorking())
    {
        actionStarted(DeviceUtils::ACTION_SCAN_WITH_VALUES);
        deviceConnect();
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::actionScanWithoutValues()
{
    qDebug() << "DeviceToolBLEx::actionScanWithoutValues()" << getAddress() << getName();
    logEvent("User asked for connection (scan without values)", LogEvent::USER);

    if (!isWorking())
    {
        actionStarted(DeviceUtils::ACTION_SCAN_WITHOUT_VALUES);
        deviceConnect();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::askForNotify(const QString &uuid)
{
    // Iterate through services, until we find the characteristic we want to read
    for (const auto &s: std::as_const(m_services))
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            for (auto c: srv->getCharacteristicsInfos())
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getUuidFull() == uuid)
                {
                    srv->askForNotify(uuid);
                    return;
                }
            }
        }
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::askForRead(const QString &uuid)
{
    // Iterate through services, until we find the characteristic we want to read
    for (const auto &s: std::as_const(m_services))
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            for (const auto &c: srv->getCharacteristicsInfos())
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getUuidFull() == uuid)
                {
                    srv->askForRead(uuid);
                    return;
                }
            }
        }
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::askForDescriptorRead(QObject *descriptor)
{
    DescriptorInfo *dsc = qobject_cast<DescriptorInfo *>(descriptor);
    if (!dsc) return;

    // Iterate through services, until we find the characteristic owning that descriptor
    for (const auto &s: std::as_const(m_services))
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            for (const auto &c: srv->getCharacteristicsInfos())
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getDescriptorsInfos().contains(descriptor))
                {
                    srv->askForDescriptorRead(dsc);
                    return;
                }
            }
        }
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::askForWrite(const QString &uuid, const QString &value, const QString &type,
                                 bool withResponse, int exponent)
{
    // Iterate through services, until we find the characteristic we want to write
    for (const auto &s: std::as_const(m_services))
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            for (const auto &c: srv->getCharacteristicsInfos())
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getUuidFull() == uuid)
                {
                    srv->askForWrite(uuid, value, type, withResponse, exponent);
                    return;
                }
            }
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

QByteArray DeviceToolBLEx::askForData_qba(const QString &value, const QString &type, int exponent)
{
    QByteArray data;

    if (type == "data")
    {
        //qDebug() << "DATA > " << value.toLatin1();
        if (value.size() % 2 == 0) // an incomplete byte cannot be written
        {
            data = QByteArray::fromHex(value.toLatin1());
        }
    }
    else if (type == "ascii")
    {
        //qDebug() << "ASCII > " << value.toLatin1().toHex();
        data = value.toLatin1();
    }
    else
    {
        // Numbers and utf8 text, using the presentation format encoder
        const uint8_t format = formatFromType(type);
        BleFormat::WriteError error = BleFormat::WRITE_OK;

        data = BleFormat::writeValue(value, format, static_cast<int8_t>(exponent), &error);

        if (error != BleFormat::WRITE_OK)
        {
            data.clear(); // no silent rounding for manual input
        }
        else if (type.endsWith("_be") && BleFormat::formatSize(format) > 0)
        {
            std::reverse(data.begin(), data.end());
        }
    }

    //qDebug() << "DeviceToolBLEx::askForData_qba(" << value << " / " << type << ")  >> " << data << "   size:" << data.size();
    return data;
}

/* ************************************************************************** */

QStringList DeviceToolBLEx::askForData_strlst(const QString &value, const QString &type, int exponent)
{
    QByteArray in = askForData_qba(value, type, exponent);
    QStringList out;

    // Make it compatible with the data widget for display
    for (int i = 0; i < in.size();)
    {
        QByteArray hex;
        hex += in.at(i++);
        out.append(hex.toHex());
    }

    //qDebug() << "DeviceToolBLEx::askForData_strlst(" << value << " / " << type << ")  >> " << out;
    return out;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::deviceConnected()
{
    logEvent("Device connected", LogEvent::CONN);

    if (m_ble_action == DeviceUtils::ACTION_SCAN ||
        m_ble_action == DeviceUtils::ACTION_SCAN_WITH_VALUES ||
        m_ble_action == DeviceUtils::ACTION_SCAN_WITHOUT_VALUES)
    {
        qDeleteAll(m_services);
        m_services.clear();
    }

    Device::deviceConnected();
}

/* ************************************************************************** */

void DeviceToolBLEx::deviceDisconnected()
{
    logEvent("Device disconnected", LogEvent::CONN);

    m_areServiceReady = false;
    Q_EMIT servicesChanged();

    Device::deviceDisconnected();
}

/* ************************************************************************** */

void DeviceToolBLEx::deviceErrored(QLowEnergyController::Error error)
{
    if (error <= QLowEnergyController::NoError) return;

    QString errorstr = "UnknownError";
    if (error == QLowEnergyController::UnknownRemoteDeviceError) errorstr = "UnknownRemoteDeviceError";
    else if (error == QLowEnergyController::NetworkError) errorstr = "NetworkError";
    else if (error == QLowEnergyController::InvalidBluetoothAdapterError) errorstr = "InvalidBluetoothAdapterError";
    else if (error == QLowEnergyController::ConnectionError) errorstr = "ConnectionError";
    else if (error == QLowEnergyController::AdvertisingError) errorstr = "AdvertisingError";
    else if (error == QLowEnergyController::RemoteHostClosedError) errorstr = "RemoteHostClosedError";
    else if (error == QLowEnergyController::AuthorizationError) errorstr = "AuthorizationError";
    else if (error == QLowEnergyController::MissingPermissionsError) errorstr = "MissingPermissionsError";
    else if (error == QLowEnergyController::RssiReadError) errorstr = "RssiReadError";
    logEvent("Device errored: " + errorstr, LogEvent::ERROR);

    Device::deviceErrored(error);
}

/* ************************************************************************** */

void DeviceToolBLEx::deviceStateChanged(QLowEnergyController::ControllerState state)
{
    QString statestr = "UnconnectedState";
    if (state == QLowEnergyController::ConnectingState) statestr = "ConnectingState";
    else if (state == QLowEnergyController::ConnectedState) statestr = "ConnectedState";
    else if (state == QLowEnergyController::DiscoveringState) statestr = "DiscoveringState";
    else if (state == QLowEnergyController::DiscoveredState) statestr = "DiscoveredState";
    else if (state == QLowEnergyController::ClosingState) statestr = "ClosingState";
    else if (state == QLowEnergyController::AdvertisingState) statestr = "AdvertisingState";
    logEvent("Device state changed: " + statestr, LogEvent::STATE);

    Device::deviceStateChanged(state);
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::addLowEnergyService(const QBluetoothUuid &uuid)
{
    qDebug() << "DeviceToolBLEx::addLowEnergyService(" << uuid.toString() << ")";
    logEvent("Service found: " + uuid.toString(), LogEvent::STATE);

    QLowEnergyService *service = m_bleController->createServiceObject(uuid);
    if (!service)
    {
        qWarning() << "Cannot create service for UUID" << uuid;
        return;
    }

    QLowEnergyService::DiscoveryMode scanmode = QLowEnergyService::FullDiscovery;
    if (m_ble_action == DeviceUtils::ACTION_SCAN_WITHOUT_VALUES)
    {
        m_services_scanmode = DeviceToolBLEx::srv_scanning; // start scanning (without values)
        scanmode = QLowEnergyService::SkipValueDiscovery;
    }
    else if (m_ble_action == DeviceUtils::ACTION_SCAN_WITH_VALUES)
    {
        m_services_scanmode = DeviceToolBLEx::srv_scanning_values; // start scanning (with values)
        scanmode = QLowEnergyService::FullDiscovery;
    }

    auto serv = new ServiceInfo(service, scanmode, this);
    m_services.append(serv);

    Q_EMIT servicesChanged();
}

/* ************************************************************************** */

void DeviceToolBLEx::serviceScanDone()
{
    qDebug() << "DeviceToolBLEx::serviceScanDone(" << m_deviceAddress << ")";
    logEvent("Service scan is done", LogEvent::STATE);
/*
    // Update services status
    // all service(s) are now known, characteristic(s) discovery has started

    if (m_services_scanmode == 3) // "incomplete scan"
    {
        m_services_scanmode = 7; // now "scanned"
    }
    else if (m_services_scanmode == 4) // "incomplete scan (with values)"
    {
        m_services_scanmode = 8; // now "scanned (with values)"
    }
    Q_EMIT servicesChanged();

    // Still working...
    m_ble_status = DeviceUtils::DEVICE_WORKING;
    Q_EMIT statusUpdated();
*/
}

/* ************************************************************************** */

void DeviceToolBLEx::serviceDiscoveryDone()
{
    qDebug() << "DeviceToolBLEx::serviceDiscoveryDone(" << getAddress() << ")";
    logEvent("Service discovery is done", LogEvent::STATE);

    // Update services status
    // all service(s) are now known, characteristic(s) discovery have been discovered

    if (m_services_scanmode == srv_scanning)
    {
        m_services_scanmode = srv_scanned;
    }
    else if (m_services_scanmode == srv_scanning_values)
    {
        m_services_scanmode = srv_scanned_values;
    }

    m_areServiceReady = true;
    Q_EMIT servicesChanged();

    // Device is ready
    logEvent("Device is ready", LogEvent::CONN);

    // No longer working, just connected
    m_ble_status = DeviceUtils::DEVICE_CONNECTED;
    Q_EMIT statusUpdated();
}

void DeviceToolBLEx::serviceDetailsDiscovered_fromservice()
{
    for (auto s: std::as_const(m_services))
    {
        ServiceInfo *ss = qobject_cast<ServiceInfo *>(s);
        if (ss->getServiceStatus() == QLowEnergyService::RemoteService ||
            ss->getServiceStatus() == QLowEnergyService::RemoteServiceDiscovering)
        {
            return; // we are not ready
        }
    }

    serviceDiscoveryDone();
}

void DeviceToolBLEx::decodeStandardCharacteristic(const QBluetoothUuid &uuid, const QByteArray &value)
{
    if (value.isEmpty()) return;

    bool ok = false;
    const quint16 uuid16 = uuid.toUInt16(&ok);
    if (!ok) return;

    // UTF-8 strings, often padded with trailing NULs or spaces
    const auto toString = [&value]() {
        QByteArray str = value;
        const int nul = str.indexOf('\0');
        if (nul >= 0) str.truncate(nul);
        return QString::fromUtf8(str).trimmed();
    };

    switch (uuid16)
    {
    case 0x2A19: // Battery Level
        setBattery(static_cast<quint8>(value.at(0)));
        break;
    case 0x2A24: // Model Number String
        setModel(toString());
        break;
    case 0x2A25: // Serial Number String
        //setSerialNumber(toString());
        break;
    case 0x2A26: // Firmware Revision String
        setFirmware(toString());
        break;
    case 0x2A27: // Hardware Revision String
        //setHardwareRevision(toString());
        break;
    case 0x2A28: // Software Revision String
        //setSoftwareRevision(toString());
        break;
    case 0x2A29: // Manufacturer Name String
        //setManufacturer(toString());
        break;

    default:
        break;
    }
}

/* ************************************************************************** */

int DeviceToolBLEx::getCharacteristicsCount() const
{
    int characteristicCount = 0;

    // Count characteristics
    for (const auto s: m_services)
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv) characteristicCount += srv->getCharacteristicsCount();
    }

    return characteristicCount;
}

/* ************************************************************************** */

void DeviceToolBLEx::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceToolBLEx::bleWriteDone(" << m_deviceAddress << ")";
}

void DeviceToolBLEx::bleReadDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceToolBLEx::bleReadDone(" << m_deviceAddress << ")";
}

void DeviceToolBLEx::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "DeviceToolBLEx::bleReadNotify(" << m_deviceAddress << ")";
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::parseAdvertisement(const QBluetoothDeviceInfo &info, const QDateTime &timestamp,
                                        bool &hasMfd, bool &hasSvd)
{
    const QList <quint16> &manufacturerIds = info.manufacturerIds();
    for (const auto id: manufacturerIds)
    {
        //qDebug() << info.name() << info.address() << Qt::hex
        //         << "ID" << id
        //         << "manufacturer data" << Qt::dec << info.manufacturerData(id).size() << Qt::hex
        //         << "bytes:" << info.manufacturerData(id).toHex();

        if (id == 0x004C) setBeacon(true); // iBeacon

        hasMfd |= parseAdvertisementToolBLEx(DeviceUtils::BLE_ADV_MANUFACTURERDATA,
                                             id, QBluetoothUuid(), info.manufacturerData(id),
                                             timestamp);
    }

    const QList <QBluetoothUuid> &serviceIds = info.serviceIds();
    for (const auto id: serviceIds)
    {
        //qDebug() << info.name() << info.address() << Qt::hex
        //         << "ID" << id
        //         << "service data" << Qt::dec << info.serviceData(id).size() << Qt::hex
        //         << "bytes:" << info.serviceData(id).toHex();

        if (id == QBluetoothUuid(quint32(0xFEAA))) setBeacon(true); // Eddystone beacon
        else if (id == QBluetoothUuid(quint32(0xFEF3))) setBeacon(true); // Eddystone beacon
        else if (id == QBluetoothUuid(quint32(0xFCF1))) setBeacon(true); // Google Beacons ??? Google FastPair ???

        hasSvd |= parseAdvertisementToolBLEx(DeviceUtils::BLE_ADV_SERVICEDATA,
                                             id.toUInt16(), id, info.serviceData(id),
                                             timestamp);
    }
}

bool DeviceToolBLEx::parseAdvertisementToolBLEx(const uint16_t mode,
                                                const uint16_t id,
                                                const QBluetoothUuid &uuid,
                                                const QByteArray &data,
                                                const QDateTime &timestamp)
{
    // Add to the model
    bool hasNewData = m_advertisementDataModel->addEntry(mode, id, uuid, data, timestamp);
    if (!hasNewData) return false;

    const QString uuidStr = AdvertisementData::uuidToString(mode, id, uuid);
    const QString uuidDisplay = (uuidStr.size() <= 8) ? "0x" + uuidStr : uuidStr;

    if (mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
    {
/*
        if (!m_mfd.isEmpty())
        {
            hasNewData = m_mfd.first()->compare(data);
            if (!hasNewData) return false;
        }
*/
        logEvent2(timestamp, LogEvent::ADV, "New manufacturer data: ID " + uuidDisplay +
                                            " / " + QString::number(data.size()) + " bytes / 0x" + data.toHex());

        bool uuidFound = false;
        for (const auto &uuu: std::as_const(m_mfd_uuid))
        {
            if (uuu->getUuidStr() == uuidStr)
            {
                uuidFound = true;
                break;
            }
        }
        if (!uuidFound)
        {
            AdvertisementUUID *uu = new AdvertisementUUID(mode, uuidStr, true);
            m_mfd_uuid.push_back(uu);
            Q_EMIT advertisementUuidChanged();

            m_advertisementFilterModel->syncUuid(uu);
        }
    }
    else if (mode == DeviceUtils::BLE_ADV_SERVICEDATA)
    {
/*
        if (!m_svd.isEmpty())
        {
            hasNewData = m_svd.first()->compare(data);
            if (!hasNewData) return false;
        }
*/
        logEvent2(timestamp, LogEvent::ADV, "New service data: UUID " + uuidDisplay +
                                            " / " + QString::number(data.size()) + " bytes / 0x" + data.toHex());

        bool uuidFound = false;
        for (auto uuu: std::as_const(m_svd_uuid))
        {
            if (uuu->getUuidStr() == uuidStr)
            {
                uuidFound = true;
                break;
            }
        }
        if (!uuidFound)
        {
            AdvertisementUUID *uu = new AdvertisementUUID(mode, uuidStr, true);
            m_svd_uuid.push_back(uu);
            Q_EMIT advertisementUuidChanged();

            m_advertisementFilterModel->syncUuid(uu);
        }
    }

    // Stat
    if (!m_hasAdvertisement)
    {
        if (m_advertisementDataModel->getAdvertisementMfdCount() ||
            m_advertisementDataModel->getAdvertisementSvdCount())
        {
            m_hasAdvertisement = true;
        }
    }

    Q_EMIT advertisementChanged();

    return hasNewData;
}

/* ************************************************************************** */

void DeviceToolBLEx::clearAdvertisement()
{
    //m_advertisementFilterModel->clearFilter();
    m_advertisementDataModel->clear();
    m_hasAdvertisement = false;

    Q_EMIT advertisementChanged();
}

/* ************************************************************************** */

void DeviceToolBLEx::addAdvertisementEntry(const QDateTime &timestamp, const int rssi,
                                           const bool hasMFD, const bool hasSVD)
{
    m_advertisementEntries.push_back(new AdvertisementEntry(timestamp, rssi, hasMFD, hasSVD, this));

    // Drop entries older than the retention window, or above the hard cap
    const QDateTime oldest = timestamp.addMSecs(-s_max_age_advertisement_ms);
    while (m_advertisementEntries.length() > s_max_entries_advertisement ||
           (m_advertisementEntries.length() > 1 && m_advertisementEntries.first()->getTimestamp() < oldest))
    {
        delete m_advertisementEntries.takeFirst();
    }

    if (m_advertisementEntries.length() > 1)
    {
        // Mean of consecutive deltas, which reduces to (last - first) / (n - 1)
        const qint64 span = m_advertisementEntries.first()->getTimestamp().msecsTo(m_advertisementEntries.last()->getTimestamp());
        m_advertisementInterval = static_cast<int>(span / (m_advertisementEntries.length() - 1.0));
    }

    Q_EMIT rssiUpdated();
}

void DeviceToolBLEx::cleanAdvertisementEntries()
{
    qDeleteAll(m_advertisementEntries);
    m_advertisementEntries.clear();
}

void DeviceToolBLEx::getAdvTimelineData(QXYSeries *none, QXYSeries *mfd,
                                        QXYSeries *svd, QXYSeries *both,
                                        qint64 refTimeMs, qint64 windowMs) const
{
    if (!none || !mfd || !svd || !both) return;

    QList <QPointF> pts_none, pts_mfd, pts_svd, pts_both;
    const qint64 oldestMs = refTimeMs - windowMs;

    for (const AdvertisementEntry *a: m_advertisementEntries)
    {
        const qint64 ts = a->getTimestamp().toMSecsSinceEpoch();
        if (ts < oldestMs || a->getRssi() >= 0) continue;

        const QPointF pt((ts - refTimeMs) / 1000.0, a->getRssi());
        if (a->hasMFD() && a->hasSVD()) pts_both.append(pt);
        else if (a->hasMFD()) pts_mfd.append(pt);
        else if (a->hasSVD()) pts_svd.append(pt);
        else pts_none.append(pt);
    }

    none->replace(pts_none);
    mfd->replace(pts_mfd);
    svd->replace(pts_svd);
    both->replace(pts_both);
}

/* ************************************************************************** */

void DeviceToolBLEx::setAdvertisedServices(const QList <QBluetoothUuid> &services)
{
    if (services.size() != m_advertised_services.size())
    {
        m_advertised_services.clear();
        for (auto u: services)
        {
            m_advertised_services.push_back(u.toString(QUuid::WithBraces).toUpper());
        }
        Q_EMIT servicesAdvertisedChanged();
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::clearDeviceServices()
{
    //qDebug() << "DeviceToolBLEx::clearDeviceServices(" << m_deviceAddress << ")";

    if (m_services.isEmpty()) return;

    // Do not delete services while there is activity on the device
    if (m_ble_status >= DeviceUtils::DEVICE_WORKING) return;

    logEvent("Services cleared", LogEvent::USER);

    const QList <QObject *> old_services = m_services;
    m_services.clear();

    m_services_scanmode = srv_unscanned;
    m_areServiceReady = false;

    Q_EMIT servicesChanged();
    Q_EMIT characteristicsChanged();

    for (const auto &s: old_services)
    {
        if (s) s->deleteLater();
    }
}

void DeviceToolBLEx::clearDeviceServicesData()
{
    //qDebug() << "DeviceToolBLEx::clearDeviceServicesData(" << m_deviceAddress << ")";

    if (m_services.isEmpty()) return;

    logEvent("Services data cleared", LogEvent::USER);

    for (const auto &s: std::as_const(m_services))
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv) srv->clearCharacteristicsData();
    }

    // We still have the service/characteristic structure, but no longer the values
    if (m_services_scanmode == srv_cached_values) m_services_scanmode = srv_cached;
    else if (m_services_scanmode == srv_incomplete_values) m_services_scanmode = srv_incomplete;
    else if (m_services_scanmode == srv_scanned_values) m_services_scanmode = srv_scanned;

    Q_EMIT servicesChanged();
}

/* ************************************************************************** */

bool DeviceToolBLEx::checkServiceCache()
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    cachePath += "/devices/" + m_deviceAddress + ".cache";

    bool checkResult = QFile::exists(cachePath);
    if (m_hasServiceCache != checkResult)
    {
        m_hasServiceCache = checkResult;
        Q_EMIT servicesChanged();
    }

    return checkResult;
}

QJsonObject DeviceToolBLEx::getProfileJson(bool withGenericInfo, bool withAdvertisements,
                                           bool withServices, bool withValues,
                                           const QString &comment) const
{
    QJsonObject root = DeviceProfile::createRoot();
    root.insert("name", m_deviceName);
    root.insert("address", getAddress());
    if (!comment.trimmed().isEmpty()) root.insert("comment", comment.trimmed());

    // Generic info
    if (withGenericInfo)
    {
        QJsonObject info;
        if (hasAddressMAC() && !m_deviceManufacturer.isEmpty()) info.insert("mac_manufacturer", m_deviceManufacturer);
        if (!m_userComment.isEmpty()) info.insert("user_comment", m_userComment);
        info.insert("first_seen", m_firstSeen.toString(Qt::ISODate));
        info.insert("last_seen", m_lastSeen.toString(Qt::ISODate));

        root.insert("device_info", info);
    }

    // Advertisements (latest packet of each manufacturer / service data UUID)
    if (withAdvertisements)
    {
        QJsonObject advertising;
        if (!m_deviceName.isEmpty()) advertising.insert("local_name", m_deviceName);
        if (m_advertisementInterval > 0)
        {
            advertising.insert("interval_ms", QJsonArray{m_advertisementInterval, m_advertisementInterval});
        }
        if (!m_advertised_services.isEmpty())
        {
            advertising.insert("services", QJsonArray::fromStringList(m_advertised_services));
        }

        QJsonArray mfdArray;
        QJsonArray svdArray;
        for (const auto *adv: std::as_const(m_advertisementDataModel->m_advertisements_latest))
        {
            if (adv->getMode() == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
            {
                mfdArray.append(QJsonObject{ {"id", "0x" + adv->getUUID_str().toUpper()},
                                             {"data", DeviceProfile::valueToString(adv->getDataBA())} });
            }
            else if (adv->getMode() == DeviceUtils::BLE_ADV_SERVICEDATA)
            {
                svdArray.append(QJsonObject{ {"uuid", DeviceProfile::uuidToString(QBluetoothUuid(adv->getUUID_uint()))},
                                             {"data", DeviceProfile::valueToString(adv->getDataBA())} });
            }
        }
        if (!mfdArray.isEmpty()) advertising.insert("manufacturer_data", mfdArray);
        if (!svdArray.isEmpty()) advertising.insert("service_data", svdArray);

        root.insert("advertising", advertising);
    }

    // Services
    if (withServices)
    {
        QJsonArray servicesArray;
        for (const auto &s: std::as_const(m_services))
        {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            // Characteristics
            QJsonArray characteristicsArray;
            for (const auto &c: srv->getCharacteristicsInfos())
            {
                    CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                    if (cst)
                    {
                        // Descriptors (their values are part of the structure)
                        QJsonArray descriptorsArray;
                        for (const auto &d: cst->getDescriptorsInfos())
                        {
                            DescriptorInfo *dsc = qobject_cast<DescriptorInfo *>(d);
                            if (dsc)
                            {
                                QJsonObject descriptorObject;
                                descriptorObject.insert("name", dsc->getNameRaw());
                                descriptorObject.insert("uuid", dsc->getUuidFull());
                                descriptorObject.insert("value", dsc->getValueHex());

                                descriptorsArray.append(descriptorObject);
                            }
                        }

                        QJsonObject characteristicObject;
                        characteristicObject.insert("name", cst->getName());
                        characteristicObject.insert("uuid", cst->getUuidFull());
                        characteristicObject.insert("properties", QJsonArray::fromStringList(cst->getPropertyList()));
                        if (withValues && cst->getDataSize() > 0) characteristicObject.insert("value", cst->getValueHex());
                        characteristicObject.insert("descriptors", descriptorsArray);

                        characteristicsArray.append(characteristicObject);
                    }
                }

                QJsonObject serviceObject;
                serviceObject.insert("name", srv->getName());
                serviceObject.insert("uuid", srv->getUuidFull());
                serviceObject.insert("type", QJsonArray::fromStringList(srv->getTypeList()));
                serviceObject.insert("characteristics", characteristicsArray);

                servicesArray.append(serviceObject);
            }
        }

        root.insert("services", servicesArray);
    }

    return root;
}

bool DeviceToolBLEx::saveServiceCache(bool withValues)
{
    qDebug() << "DeviceToolBLEx::saveServiceCache(" << m_deviceAddress << ")";

    bool status = false;

    const QJsonObject root = getProfileJson(false, false, true, withValues);

    // Get cache directory path
    QString cacheDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/devices";
    QDir cacheDirectory(cacheDirectoryPath);
    if (!cacheDirectory.exists())
    {
        cacheDirectory.mkpath(cacheDirectoryPath);
    }

    qDebug() << "CACHE DIRECTORY" << cacheDirectory;

    if (cacheDirectory.exists())
    {
        // Finish preping cache path
        QString cacheFilePath = "/" + m_deviceAddress + ".cache";
        cacheFilePath = cacheDirectoryPath + cacheFilePath;

        // Open file and save content
        QFile efile(cacheFilePath);
        if (efile.open(QFile::WriteOnly | QIODevice::Text))
        {
            QJsonDocument cacheJsonDoc(root);
            efile.write(cacheJsonDoc.toJson());
            efile.close();

            status = true;

            if (m_hasServiceCache != true)
            {
                m_hasServiceCache = true;
                Q_EMIT servicesChanged();
            }
        }
    }

    return status;
}

void DeviceToolBLEx::restoreServiceCache()
{
    qDebug() << "DeviceToolBLEx::restoreServiceCache(" << m_deviceAddress << ")";

    QString cacheDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    cacheDirectoryPath += "/devices/" + m_deviceAddress + ".cache";

    QFile file(cacheDirectoryPath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QJsonDocument cacheJsonDoc = QJsonDocument().fromJson(file.readAll());
        QJsonObject root = cacheJsonDoc.object();
        file.close();

        qDeleteAll(m_services);
        m_services.clear();
        m_services_scanmode = srv_cached; // cache is in use

        const QJsonArray servicesArray = root["services"].toArray();
        for (const auto &srv_json: servicesArray)
        {
            QJsonObject obj = srv_json.toObject();
            qDebug() << "+ SERVICE >" << obj["name"].toString() << obj["uuid"].toString();

            auto srv = new ServiceInfo(obj, this);
            m_services.append(srv);

            // The cache may or may not contain the characteristic values
            for (const auto &c: srv->getCharacteristicsInfos())
            {
                const CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getDataSize() > 0) m_services_scanmode = srv_cached_values;
            }
        }

        Q_EMIT servicesChanged();
        Q_EMIT characteristicsChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceToolBLEx::getExportFile(QString &filename, const QString &suffix) const
{
    bool status = false;

    // No path given by the UI? Generate a "default" path
    if (filename.isEmpty())
    {
        filename = SettingsManager::getInstance()->getExportDirectory_str();
        filename += "/" + getName_display() + "-" + getAddr_display();
        filename += suffix;
    }

    // Check if the directory exist, or try to create it
    QDir exportDirectory = QFileInfo(filename).dir();
    if (!exportDirectory.exists())
    {
        exportDirectory.mkpath(exportDirectory.path());
    }

    if (exportDirectory.exists())
    {
        status = true;
    }
    else
    {
        filename.clear();
        status = false;
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::logEvent(const QString &txt, const int event, QDateTime timestamp)
{
    if (!txt.isEmpty())
    {
        // log format
        LogEvent *log = new LogEvent(timestamp, event, txt, this);
        if (log) m_deviceLog_obj->append(log);

        // text format
        QString logline = timestamp.toString("[hh:mm:ss.zzz] ") + txt + QChar('\n');
        m_deviceLog_str += logline;
        Q_EMIT logLineAppended(logline);

        Q_EMIT logUpdated();
    }
}

void DeviceToolBLEx::logEvent2(const QDateTime &timestamp, const int event, const QString &txt)
{
    if (!txt.isEmpty())
    {
        // log format
        LogEvent *log = new LogEvent(timestamp, event, txt, this);
        if (log) m_deviceLog_obj->append(log);

        // text format
        QString logline = timestamp.toString("[hh:mm:ss.zzz] ") + txt + QChar('\n');
        m_deviceLog_str += logline;
        Q_EMIT logLineAppended(logline);

        Q_EMIT logUpdated();
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::clearDeviceLog()
{   
    m_deviceLog_obj->clear();
    m_deviceLog_str.clear();

    Q_EMIT logUpdated();
}

/* ************************************************************************** */

bool DeviceToolBLEx::exportDeviceLog(const QString &filename)
{
    bool status = false;

    QString exportFilePath = filename;

    if (getExportFile(exportFilePath, QStringLiteral("-log.txt")))
    {
        qDebug() << "DeviceToolBLEx::exportDeviceLog(" << exportFilePath << ")";

        // Open file and save content
        QFile efile(exportFilePath);
        if (efile.open(QFile::WriteOnly | QIODevice::Text))
        {
            QTextStream eout(&efile);
            eout.setEncoding(QStringConverter::Utf8);
            eout << m_deviceLog_str;

            status = true;
            efile.close();
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceToolBLEx::exportDeviceInfo(const QString &filename,
                                      bool withGenericInfo, bool withAdvertisements,
                                      bool withServices, bool withValues,
                                      const QString &comment)
{
    bool status = false;

    // Create export string ////////////////////////////////////////////////////

    QString exportString;
    QString endl = QChar('\n');

    // Name and address
    exportString += "Device Name: " + m_deviceName + endl;
    if (hasAddressMAC())
    {
        exportString += "Device MAC: " + getAddressMAC() + endl;
        if (m_deviceManufacturer.length() > 0) exportString += "Device MAC manufacturer: " + m_deviceManufacturer + endl;
    }
    else if (hasAddressUUID())
    {
        exportString += "Device MAC: " + getAddressUUID() + endl;
    }
    exportString += endl;

    // Capture comment
    if (!comment.trimmed().isEmpty())
    {
        exportString += "Capture comment:" + endl;
        exportString += comment.trimmed() + endl;
        exportString += endl;
    }

    // Generic info
    if (withGenericInfo)
    {
        if (!m_userComment.isEmpty()) exportString += "User comment: " + m_userComment + endl;
        exportString += "First seen: " + m_firstSeen.toString() + endl;
        exportString += "Last seen: " + m_lastSeen.toString() + endl;

        if (!m_advertised_services.isEmpty()) exportString += endl + "Service(s) advertised:" + endl;
        for (const auto &srv: std::as_const(m_advertised_services))
        {
            exportString += "- " + srv + endl;
        }

        exportString += endl;
    }

    // Advertisements
    if (withAdvertisements)
    {
        exportString += "Advertising interval: " + QString::number(m_advertisementInterval) + " ms" + endl;

        if (m_advertisementDataModel->getAdvertisementCount() == 0)
        {
            exportString += "> No advertisement packets." + endl;
            exportString += endl;
        }
        else
        {
            exportString += "Advertisement packet(s):" + endl;

            for (const auto &adv: std::as_const(m_advertisementDataModel->m_advertisements))
            {
                if (adv->getMode() == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
                {
                    exportString += "> MFD > ";
                    exportString += adv->getTimestamp().toString("hh:mm:ss.zzz") + " > ";
                    exportString += "0x" + adv->getUUID_str() + " (" + adv->getUUID_vendor() + ")" + " > (";
                    if (adv->getDataSize() < 100) exportString += QString::number(adv->getDataSize()).rightJustified(2, ' ');
                    else exportString += QString::number(adv->getDataSize()).rightJustified(3, ' ');
                    exportString += " bytes) 0x" + adv->getDataHex();
                }
                else if (adv->getMode() == DeviceUtils::BLE_ADV_SERVICEDATA)
                {
                    exportString += "> SVD > ";
                    exportString += adv->getTimestamp().toString("hh:mm:ss.zzz") + " > ";
                    exportString += "0x" + adv->getUUID_str() + " > (";
                    if (adv->getDataSize() < 100) exportString += QString::number(adv->getDataSize()).rightJustified(2, ' ');
                    else exportString += QString::number(adv->getDataSize()).rightJustified(3, ' ');
                    exportString += " bytes) 0x" + adv->getDataHex();
                }
                else
                {
                    exportString += "> ??? > ";
                }

                exportString += endl;
            }
        }
    }

    // Services
    if (withServices)
    {
        for (const auto &s: std::as_const(m_services))
        {
            ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
            if (srv)
            {
                exportString += "Service Name: \"" + srv->getName() + "\"" + endl;
                exportString += "Service UUID: " + srv->getUuidFull() + endl;

                for (const auto &c: srv->getCharacteristicsInfos())
                {
                    CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                    if (cst)
                    {
                        exportString += "Characteristic Name: " + cst->getName();
                        exportString += " - UUID: " + cst->getUuidFull();
                        exportString += " - Properties: " + cst->getProperty();

                        if (withValues)
                        {
                            if (cst->getDataSize() <= 0)
                                exportString += " - Value: <none>";
                            else
                                exportString += " - Value: 0x" + cst->getValueHex();
                        }

                        exportString += endl;

                        for (const auto &d: cst->getDescriptorsInfos())
                        {
                            DescriptorInfo *dsc = qobject_cast<DescriptorInfo *>(d);
                            if (dsc)
                            {
                                exportString += "  Descriptor Name: " + dsc->getName();
                                exportString += " - UUID: " + dsc->getUuidFull();

                                if (withValues)
                                {
                                    if (dsc->getDataSize() <= 0)
                                        exportString += " - Value: <none>";
                                    else
                                        exportString += " - Value: 0x" + dsc->getValueHex();
                                }

                                exportString += endl;
                            }
                        }
                    }
                }

                exportString += endl;
            }
        }
    }

    // Save export string to file //////////////////////////////////////////////

    QString exportFilePath = filename;

    if (getExportFile(exportFilePath, QStringLiteral(".txt")))
    {
        qDebug() << "DeviceToolBLEx::exportDeviceInfo(" << exportFilePath << ")";

        // Open file and save content
        QFile efile(exportFilePath);
        if (efile.open(QFile::WriteOnly | QIODevice::Text))
        {
            QTextStream eout(&efile);
            eout.setEncoding(QStringConverter::Utf8);
            eout << exportString;

            status = true;
            efile.close();
        }
    }

    return status;
}

bool DeviceToolBLEx::exportDeviceProfile(const QString &filename,
                                         bool withGenericInfo, bool withAdvertisements,
                                         bool withServices, bool withValues,
                                         const QString &comment)
{
    bool status = false;

    const QJsonObject root = getProfileJson(withGenericInfo, withAdvertisements,
                                            withServices, withValues, comment);

    QString exportFilePath = filename;

    if (getExportFile(exportFilePath, DeviceProfile::fileSuffix))
    {
        qDebug() << "DeviceToolBLEx::exportDeviceProfile(" << exportFilePath << ")";

        QFile efile(exportFilePath);
        if (efile.open(QFile::WriteOnly))
        {
            status = (efile.write(QJsonDocument(root).toJson()) > 0);
            efile.close();
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */
