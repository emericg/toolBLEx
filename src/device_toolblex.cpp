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
#include "utils_bits.h"
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

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

DeviceToolBLEx::DeviceToolBLEx(const QString &deviceAddr, const QString &deviceName,
                               QObject *parent): Device(deviceAddr, deviceName, parent)
{
    // Creation from database cache

    m_isCached = true;
    m_hasServiceCache = checkServiceCache();

    getSqlDeviceInfos();
}

DeviceToolBLEx::DeviceToolBLEx(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    // Creation from BLE scanning

    addAdvertisementEntry(d.rssi(), !d.manufacturerIds().empty(), !d.serviceIds().empty());

    m_isCached = (d.rssi() == 0);
    m_hasServiceCache = checkServiceCache();
    m_firstSeen = QDateTime::currentDateTime();
    m_bluetoothCoreConfiguration = d.coreConfigurations();
}

DeviceToolBLEx::~DeviceToolBLEx()
{
    // will update 'last seen'
    updateCache();

    qDeleteAll(m_services);
    m_services.clear();

    qDeleteAll(m_advertisementEntries);
    m_advertisementEntries.clear();

    qDeleteAll(m_svd);
    m_svd.clear();
    qDeleteAll(m_svd_uuid);
    m_svd_uuid.clear();

    qDeleteAll(m_mfd);
    m_mfd.clear();
    qDeleteAll(m_mfd_uuid);
    m_mfd_uuid.clear();
}

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
                m_deviceBattery = getInfos.value(5).toInt();

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
    if (m_lastSeen != dt)
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

void DeviceToolBLEx::updateCache()
{
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

void DeviceToolBLEx::blacklist(bool b)
{
    if (m_isBlacklisted != b)
    {
        if (b) static_cast<DeviceManager *>(parent())->blacklistDevice(m_deviceAddress);
        else static_cast<DeviceManager *>(parent())->whitelistDevice(m_deviceAddress);

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
/* ************************************************************************** */

void DeviceToolBLEx::actionScanWithValues()
{
    qDebug() << "DeviceToolBLEx::actionScanWithValues()" << getAddress() << getName();
    logEvent("User asked for connection (scan with values)", LogEvent::USER);

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_SCAN_WITH_VALUES;
        actionStarted();
        deviceConnect();
    }
}

void DeviceToolBLEx::actionScanWithoutValues()
{
    qDebug() << "DeviceToolBLEx::actionScanWithoutValues()" << getAddress() << getName();
    logEvent("User asked for connection (scan without values)", LogEvent::USER);

    if (!isBusy())
    {
        m_ble_action = DeviceUtils::ACTION_SCAN_WITHOUT_VALUES;
        actionStarted();
        deviceConnect();
    }
}

/* ************************************************************************** */

void DeviceToolBLEx::askForNotify(const QString &uuid)
{
    // Iterate through services, until we find the characteristic we want to read
    for (auto s: m_services)
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

void DeviceToolBLEx::askForRead(const QString &uuid)
{
    // Iterate through services, until we find the characteristic we want to read
    for (auto s: m_services)
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            for (auto c: srv->getCharacteristicsInfos())
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

void DeviceToolBLEx::askForWrite(const QString &uuid, const QString &value, const QString &type)
{
    // Iterate through services, until we find the characteristic we want to write
    for (auto s: m_services)
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            for (auto c: srv->getCharacteristicsInfos())
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getUuidFull() == uuid)
                {
                    srv->askForWrite(uuid, value, type);
                    return;
                }
            }
        }
    }
}

/* ************************************************************************** */

QByteArray DeviceToolBLEx::askForData_qba(const QString &value, const QString &type)
{
    QByteArray data;

    if (type.startsWith("uint"))
    {
        //qDebug() << "uINTEGER > " << value.toULongLong();
        if (type.startsWith("uint8")) {
            int8_t u = value.toShort();
            data.append(reinterpret_cast<const char*>(&u), 1);
        }
        else if (type.startsWith("uint16")) {
            uint16_t u = value.toUShort();
            if (!type.endsWith("_be")) u = endian_flip_16(u);
            data.append(reinterpret_cast<const char*>(&u), 2);
        }
        else if (type.startsWith("uint32")) {
            uint32_t u = value.toUInt();
            if (!type.endsWith("_be")) u = endian_flip_32(u);
            data.append(reinterpret_cast<const char*>(&u), 4);
        }
        else if (type.startsWith("uint64")) {
            uint64_t u = value.toULongLong();
            if (!type.endsWith("_be")) u = endian_flip_64(u);
            data.append(reinterpret_cast<const char*>(&u), 8);
        }
    }
    else if (type.startsWith("int"))
    {
        //qDebug() << "sINTEGER > " << value.toInt();
        if (type.startsWith("int8")) {
            int8_t i = value.toShort();
            data.append(reinterpret_cast<const char*>(&i), 1);
        }
        else if (type.startsWith("int16")) {
            int16_t i = value.toShort();
            if (!type.endsWith("_be")) i = endian_flip_16(i);
            data.append(reinterpret_cast<const char*>(&i), 2);
        }
        else if (type.startsWith("int32")) {
            int32_t i = value.toInt();
            if (!type.endsWith("_be")) i = endian_flip_32(i);
            data.append(reinterpret_cast<const char*>(&i), 4);
        }
        else if (type.startsWith("int64")) {
            int64_t i = value.toLongLong();
            if (!type.endsWith("_be")) i = endian_flip_64(i);
            data.append(reinterpret_cast<const char*>(&i), 8);
        }
    }

    else if (type == "float32")
    {
        //qDebug() << "FLOAT > " << value.toFloat();
        float f = value.toFloat();
        if (!type.endsWith("_be")) f = endian_flip_32(f);
        data.append(reinterpret_cast<const char*>(&f), 4);
    }
    else if (type == "float64")
    {
        //qDebug() << "DOUBLE > " << value.toDouble();
        double d = value.toDouble();
        if (!type.endsWith("_be")) d = endian_flip_64(d);
        data.append(reinterpret_cast<const char*>(&d), 8);
    }

    else if (type == "data")
    {
        //qDebug() << "DATA > " << value.toLatin1();
        for (int i = 0; i < value.size();) {
            int a = QString(value.at(i++)).toInt(nullptr, 16) << 4;
            if (i <value.size()) a += QString(value.at(i++)).toInt(nullptr, 16);
            data.append(a);
        }
    }
    else if (type == "ascii")
    {
        //qDebug() << "ASCII > " << value.toLatin1().toHex();
        data = value.toLatin1();
    }

    //qDebug() << "DeviceToolBLEx::askForData_qba(" << value << " / " << type << ")  >> " << data << "   size:" << data.size();
    return data;
}

QStringList DeviceToolBLEx::askForData_strlst(const QString &value, const QString &type)
{
    QByteArray in = askForData_qba(value, type);
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

void DeviceToolBLEx::deviceDisconnected()
{
    logEvent("Device disconnected", LogEvent::CONN);

    Device::deviceDisconnected();
}

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
        m_services_scanmode = 2; // incomplete scan
        scanmode = QLowEnergyService::SkipValueDiscovery;
    }
    else if (m_ble_action == DeviceUtils::ACTION_SCAN_WITH_VALUES)
    {
        m_services_scanmode = 3; // incomplete scan (with values)
        scanmode = QLowEnergyService::FullDiscovery;
    }

    auto serv = new ServiceInfo(service, scanmode, this);
    m_services.append(serv);

    Q_EMIT servicesChanged();
}

void DeviceToolBLEx::serviceDetailsDiscovered(QLowEnergyService::ServiceState)
{
    //qDebug() << "Device::serviceDetailsDiscovered(" << getAddress() << state << ")";
}

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

void DeviceToolBLEx::serviceScanDone() // aka discoveryFinished()
{
    qDebug() << "DeviceToolBLEx::serviceScanDone(" << m_deviceAddress << ")";
    logEvent("Service scan is done", LogEvent::STATE);

    // Update service status
    if (m_services_scanmode == 2) // "incomplete scan"
    {
        m_services_scanmode = 4; // now "scanned"
    }
    else if (m_services_scanmode == 3) // "incomplete scan (with values)"
    {
        m_services_scanmode = 5; // now "scanned (with values)"
    }
    Q_EMIT servicesChanged();

    // No longer working, just connected
    m_ble_status = DeviceUtils::DEVICE_CONNECTED;
    Q_EMIT statusUpdated();
}

/* ************************************************************************** */

void DeviceToolBLEx::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleWriteDone(" << m_deviceAddress << ")";
}

void DeviceToolBLEx::bleReadDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleReadDone(" << m_deviceAddress << ")";
}

void DeviceToolBLEx::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleReadNotify(" << m_deviceAddress << ")";
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceToolBLEx::parseAdvertisementToolBLEx(const uint16_t mode,
                                                const uint16_t id,
                                                const QBluetoothUuid &uuid,
                                                const QByteArray &data)
{
    bool hasNewData = false;
    Q_UNUSED(uuid)

    if (mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
    {
        if (!m_mfd.isEmpty())
        {
            hasNewData = m_mfd.first()->compare(data);
            if (!hasNewData) return false;
        }

        logEvent("New manufacturer data: ID 0x" + QString::number(id, 16).rightJustified(4, '0') +
                 " / " + QString::number(data.size()) + " bytes / 0x" + data.toHex(), LogEvent::ADV);

        AdvertisementData *a = new AdvertisementData(mode, id, data, this);
        m_advertisementData.push_front(a); // always add it to the unfiltered list

        bool uuidFound = false;
        for (auto uuu: m_mfd_uuid)
        {
            if (uuu->getUuid() == id)
            {
                uuidFound = true;

                if (uuu->getSelected())
                {
                    m_advertisementData_filtered.push_front(a);
                }
            }
        }
        if (!uuidFound)
        {
            AdvertisementUUID *uu = new AdvertisementUUID(id, true);
            m_mfd_uuid.push_back(uu);
            m_advertisementData_filtered.push_front(a);
        }

        m_mfd.push_front(a);
        if (m_mfd.length() >= s_max_entries_packets)
        {
            AdvertisementData *d = m_mfd.back();
            m_mfd.pop_back();
            m_advertisementData.removeOne(d);
            m_advertisementData_filtered.removeOne(d);
            delete d;
        }

        Q_EMIT advertisementChanged();

        mfdFilterUpdate();
    }
    else if (mode == DeviceUtils::BLE_ADV_SERVICEDATA)
    {
        if (!m_svd.isEmpty())
        {
            hasNewData = m_svd.first()->compare(data);
            if (!hasNewData) return false;
        }

        logEvent("New service data: " + uuid.toString() + " / " + QString::number(data.size()) +
                 " bytes / 0x" + data.toHex(), LogEvent::ADV);

        AdvertisementData *a = new AdvertisementData(mode, id, data, this);
        m_advertisementData.push_front(a); // always add it to the unfiltered list

        bool uuidFound = false;
        for (auto uuu: m_svd_uuid)
        {
            if (uuu->getUuid() == id)
            {
                uuidFound = true;

                if (uuu->getSelected())
                {
                    m_advertisementData_filtered.push_front(a);
                }
            }
        }
        if (!uuidFound)
        {
            AdvertisementUUID *uu = new AdvertisementUUID(id, true);
            m_svd_uuid.push_back(uu);
            m_advertisementData_filtered.push_front(a);
        }

        m_svd.push_front(a);
        if (m_svd.length() >= s_max_entries_packets)
        {
            AdvertisementData *d = m_svd.back();
            m_svd.pop_back();
            m_advertisementData.removeOne(d);
            m_advertisementData_filtered.removeOne(d);
            delete d;
        }

        Q_EMIT advertisementChanged();

        svdFilterUpdate();
    }

    if (m_mfd.length() > 0 || m_svd.length())
    {
        if (!m_hasAdvertisement)
        {
            m_hasAdvertisement = true;
            Q_EMIT advertisementChanged();
        }
    }

    return hasNewData;
}

/* ************************************************************************** */

void DeviceToolBLEx::addAdvertisementEntry(const int rssi, const bool hasMFD, const bool hasSVD)
{
    int maxentries = s_min_entries_advertisement;
    if (m_advertisementInterval > 0 && m_advertisementInterval < 1000) maxentries = s_max_entries_advertisement;

    m_advertisementEntries.push_back(new AdvertisementEntry(rssi, hasMFD, hasSVD, this));
    if (m_advertisementEntries.length() > maxentries)
    {
        delete m_advertisementEntries.at(0);
        m_advertisementEntries.pop_front();
    }

    if (m_advertisementEntries.length() > 1)
    {
        int intvm = 0;
        for (int i=1; i < m_advertisementEntries.length(); i++)
        {
            //qDebug() << i << m_rssiHistory.at(i)->getTimestamp();
            intvm += m_advertisementEntries.at(i-1)->getTimestamp().msecsTo(m_advertisementEntries.at(i)->getTimestamp());
        }
        m_advertisementInterval = (intvm / (m_advertisementEntries.length()-1.0));
    }

    Q_EMIT rssiUpdated();
}

void DeviceToolBLEx::cleanAdvertisementEntries()
{
    qDeleteAll(m_advertisementEntries);
    m_advertisementEntries.clear();
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

void DeviceToolBLEx::mfdFilterUpdate()
{
    QList <uint16_t> accepted_uuids;
    for (auto u: m_mfd_uuid)
    {
        if (u->getSelected())
        {
            accepted_uuids.push_back(u->getUuid());
        }
    }

    for (auto adv: m_advertisementData_filtered)
    {
        if (!accepted_uuids.contains(adv->getUUID_int()))
        {
            m_advertisementData_filtered.removeOne(adv);
        }
    }

    Q_EMIT advertisementFilteredChanged();
}

void DeviceToolBLEx::svdFilterUpdate()
{
    QList <uint16_t> accepted_uuids;
    for (auto u: m_svd_uuid)
    {
        if (u->getSelected())
        {
            accepted_uuids.push_back(u->getUuid());
        }
    }

    for (auto adv: m_advertisementData_filtered)
    {
        if (!accepted_uuids.contains(adv->getUUID_int()))
        {
            m_advertisementData_filtered.removeOne(adv);
        }
    }

    Q_EMIT advertisementFilteredChanged();
}

bool comparefunc(AdvertisementData *c1, AdvertisementData *c2)
{
    return c1->getTimestamp() > c2->getTimestamp();
}

void DeviceToolBLEx::advertisementFilterUpdate()
{
    QList <uint16_t> accepted_uuids;
    for (auto u: m_svd_uuid)
    {
        if (u->getSelected())
        {
            accepted_uuids.push_back(u->getUuid());
        }
    }
    for (auto u: m_mfd_uuid)
    {
        if (u->getSelected())
        {
            accepted_uuids.push_back(u->getUuid());
        }
    }

    m_advertisementData_filtered.clear();
    for (auto adv: m_svd)
    {
        if (accepted_uuids.contains(adv->getUUID_int()))
        {
            m_advertisementData_filtered.push_front(adv);
        }
    }
    for (auto adv: m_mfd)
    {
        if (accepted_uuids.contains(adv->getUUID_int()))
        {
            m_advertisementData_filtered.push_front(adv);
        }
    }

    std::sort(m_advertisementData_filtered.begin(), m_advertisementData_filtered.end(), comparefunc);

    Q_EMIT advertisementFilteredChanged();
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

bool DeviceToolBLEx::saveServiceCache()
{
    bool status = false;

    // Services
    QJsonArray servicesArray;
    for (auto s: m_services)
    {
        ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
        if (srv)
        {
            // Characteristics
            QJsonArray characteristicsArray;
            for (auto c: srv->getCharacteristicsInfos())
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst)
                {
                    QJsonObject characteristicObject;
                    characteristicObject.insert("name", QJsonValue::fromVariant(cst->getName()));
                    characteristicObject.insert("uuid", QJsonValue::fromVariant(cst->getUuidFull()));
                    characteristicObject.insert("properties", QJsonValue::fromVariant(cst->getPropertyList()));

                    characteristicsArray.append(characteristicObject);
                }
            }

            QJsonObject serviceObject;
            serviceObject.insert("name", QJsonValue::fromVariant(srv->getName()));
            serviceObject.insert("uuid", QJsonValue::fromVariant(srv->getUuidFull()));
            serviceObject.insert("type", QJsonValue::fromVariant(srv->getTypeList()));
            serviceObject.insert("characteristics", characteristicsArray);

            servicesArray.append(serviceObject);
        }
    }

    QJsonObject root;
    root.insert("address", QJsonValue::fromVariant(getAddress()));
    root.insert("services", servicesArray);

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
        m_services_scanmode = 1; // cache is in use

        QJsonArray servicesArray = root["services"].toArray();
        for (const auto &srv_json: servicesArray)
        {
            QJsonObject obj = srv_json.toObject();
            qDebug() << "+ SERVICE >" << obj["name"].toString() << obj["uuid"].toString();

            auto srv = new ServiceInfo(obj, this);
            m_services.append(srv);
        }

        Q_EMIT servicesChanged();
        Q_EMIT characteristicsChanged();
    }
}

/* ************************************************************************** */

bool DeviceToolBLEx::getExportFile(QString &filename, bool log) const
{
    bool status = false;

    // No path given by the UI? Generate a "default" path
    if (filename.isEmpty())
    {
        filename = SettingsManager::getInstance()->getExportDirectory_str();
        filename += "/" + getName_display() + "-" + getAddr_display();
        if (log) filename += "-log";
        filename += ".txt";
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

void DeviceToolBLEx::logEvent(const QString &logline, const int event)
{
    if (!logline.isEmpty())
    {
        // log format
        LogEvent *log = new LogEvent(QDateTime::currentDateTime(), event, logline, this);
        if (log)
        {
            m_deviceLog.push_back(log);
            Q_EMIT logUpdated();
        }

        // text format
        m_deviceLogString += QDateTime::currentDateTime().toString("[hh:mm:ss.zzz] ") + logline + QChar('\n');
    }
}

bool DeviceToolBLEx::saveLog(const QString &filename)
{
    bool status = false;

    QString exportFilePath = filename;

    if (getExportFile(exportFilePath, true))
    {
        qDebug() << "DeviceToolBLEx::saveLog(" << exportFilePath << ")";

        // Open file and save content
        QFile efile(exportFilePath);
        if (efile.open(QFile::WriteOnly | QIODevice::Text))
        {
            QTextStream eout(&efile);
            eout.setEncoding(QStringConverter::Utf8);
            eout << m_deviceLogString;

            status = true;
            efile.close();
        }
    }

    return status;
}

void DeviceToolBLEx::clearLog()
{
    qDeleteAll(m_deviceLog);
    m_deviceLog.clear();

    Q_EMIT logUpdated();
}

/* ************************************************************************** */

bool DeviceToolBLEx::exportDeviceInfo(const QString &filename,
                                      bool withGenericInfo, bool withAdvertisements,
                                      bool withServices, bool withValues)
{
    bool status = false;

    // Create export string ////////////////////////////////////////////////////

    QString str;
    QString endl = QChar('\n');

    // Name and address
    str += "Device Name: " + m_deviceName + endl;
    if (hasAddressMAC())
    {
        str += "Device MAC: " + getAddressMAC() + endl;
        if (m_deviceManufacturer.length() > 0) str += "Device MAC manufacturer: " + m_deviceManufacturer + endl;
    }
    else if (hasAddressUUID())
    {
        str += "Device MAC: " + getAddressUUID() + endl;
    }
    str += endl;

    // Generic info
    if (withGenericInfo)
    {
        if (!m_userComment.isEmpty()) str += "User comment: " + m_userComment + endl;
        str += "First seen: " + m_firstSeen.toString() + endl;
        str += "Last seen: " + m_lastSeen.toString() + endl;

        if (!m_advertised_services.isEmpty()) str += endl + "Service(s) advertised:" + endl;
        for (const auto &srv: m_advertised_services)
        {
            str += "- " + srv + endl;
        }

        str += endl;
    }

    // Advertisements
    if (withAdvertisements)
    {
        str += "Advertising interval: " + QString::number(m_advertisementInterval) + " ms" + endl;

        if (m_advertisementData.size() == 0)
        {
            str += "> No advertisement packets." + endl;
            str += endl;
        }
        else
        {
            str += "Advertisement packet(s):" + endl;

            for (auto adv: m_advertisementData)
            {
                if (adv->getMode() == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
                {
                    str += "> MFD > ";
                    str += adv->getTimestamp().toString("hh:mm:ss.zzz") + " > ";
                    str += "0x" + adv->getUUID_str() + " (" + adv->getUUID_vendor() + ")" + " > (";
                    if (adv->getDataSize() < 100) str += QString::number(adv->getDataSize()).rightJustified(2, ' ');
                    else  str += QString::number(adv->getDataSize()).rightJustified(3, ' ');
                    str += " bytes) 0x" + adv->getDataHex();
                }
                else if (adv->getMode() == DeviceUtils::BLE_ADV_SERVICEDATA)
                {
                    str += "> SVD > ";
                    str += adv->getTimestamp().toString("hh:mm:ss.zzz") + " > ";
                    str += "0x" + adv->getUUID_str() + " > (";
                    if (adv->getDataSize() < 100) str += QString::number(adv->getDataSize()).rightJustified(2, ' ');
                    else  str += QString::number(adv->getDataSize()).rightJustified(3, ' ');
                    str += " bytes) 0x" + adv->getDataHex();
                }
                else
                {
                    str += "> ??? > ";
                }

                str += endl;
            }
        }
    }

    // Services
    if (withServices)
    {
        for (auto s: m_services)
        {
            ServiceInfo *srv = qobject_cast<ServiceInfo *>(s);
            if (srv)
            {
                str += "Service Name: \"" + srv->getName() + "\"" + endl;
                str += "Service UUID: " + srv->getUuidFull() + endl;

                for (auto c: srv->getCharacteristicsInfos())
                {
                    CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                    if (cst)
                    {
                        str += "Characteristic Name: " + cst->getName();
                        str += " - UUID: " + cst->getUuidFull();
                        str += " - Properties: " + cst->getProperty();
                        //exp += " - Handle: " + cst->getHandle();

                        if (withValues)
                        {
                            if (cst->getValue() == "<none>")
                                str += " - Value: <none>";
                            else
                                str += " - Value: 0x" + cst->getValueHex();
                        }

                        str += endl;
                    }
                }

                str += endl;
            }
        }
    }

    // Save export string to file //////////////////////////////////////////////

    QString exportFilePath = filename;

    if (getExportFile(exportFilePath, false))
    {
        qDebug() << "DeviceToolBLEx::exportDeviceInfo(" << exportFilePath << ")";

        // Open file and save content
        QFile efile(exportFilePath);
        if (efile.open(QFile::WriteOnly | QIODevice::Text))
        {
            QTextStream eout(&efile);
            eout.setEncoding(QStringConverter::Utf8);
            eout << str;

            status = true;
            efile.close();
        }
    }

    return status;
}

/* ************************************************************************** */
