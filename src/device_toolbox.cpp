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

#include "device_toolbox.h"
#include "serviceinfo.h"
#include "characteristicinfo.h"

#include "SettingsManager.h"
#include "DeviceManager.h"
#include "VendorsDatabase.h"

#include <cstdlib>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QJsonDocument>
#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

AdvertisementData::AdvertisementData(const uint16_t adv_mode, const uint16_t adv_id,
                                     const QByteArray &data,
                                     QObject *parent): QObject(parent)
{
    m_timestamp = QDateTime::currentDateTime();
    advMode = adv_mode;
    advUUID = adv_id;

    advUUIDstr = QString::number(advUUID, 16).toUpper().rightJustified(4, '0');

    VendorsDatabase *v = VendorsDatabase::getInstance();
    if (adv_mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
        v->getVendor_manufacturerID(advUUIDstr, advUUIDvendor);
    else if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA)
        v->getVendor_serviceUUID(advUUIDstr, advUUIDvendor);

    advData = data;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceToolBLEx::DeviceToolBLEx(const QString &deviceAddr, const QString &deviceName,
                               QObject *parent): Device(deviceAddr, deviceName, parent)
{
    // Creation from database cache

    setCache(true);
    setCached(true);

    getSqlDeviceInfos();
}

DeviceToolBLEx::DeviceToolBLEx(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    // Creation from BLE scanning

    addAdvertisementEntry(d.rssi(), !d.manufacturerIds().empty(), !d.serviceIds().empty());
    setCoreConfiguration(d.coreConfigurations());

    m_firstSeen = QDateTime::currentDateTime();

    if (d.rssi() == 0) setCached(true);
    if (d.isCached()) setCached(true);
}

DeviceToolBLEx::~DeviceToolBLEx()
{
    // will update last seen
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

                int deviceCoreConfig = getInfos.value(6).toInt();
                setCoreConfiguration(deviceCoreConfig);

                QString deviceClass = getInfos.value(7).toString();
                QStringList dc = deviceClass.split('-');
                if (dc.size() == 3)
                {
                    setDeviceClass(dc.at(0).toInt(), dc.at(1).toInt(), dc.at(2).toInt());
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
                Q_EMIT batteryUpdated();
                Q_EMIT sensorUpdated();
                Q_EMIT settingsUpdated();
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

/* ************************************************************************** */

void DeviceToolBLEx::setBeacon(bool v)
{
    if (m_isBeacon != v)
    {
        m_isBeacon = v;
        Q_EMIT boolChanged();
    }
}

void DeviceToolBLEx::setBlacklisted(bool v)
{
    if (m_isBlacklisted != v)
    {
        m_isBlacklisted = v;
        Q_EMIT boolChanged();

        static_cast<DeviceManager *>(parent())->invalidate();
    }
}

void DeviceToolBLEx::setCached(bool v)
{
    if (m_isCached != v)
    {
        m_isCached = v;
        Q_EMIT boolChanged();

        static_cast<DeviceManager *>(parent())->invalidate();
    }
}

void DeviceToolBLEx::setCache(bool v)
{
    if (m_hasCache != v)
    {
        m_hasCache = v;
        Q_EMIT cacheChanged();

        static_cast<DeviceManager *>(parent())->invalidate();
    }
}

void DeviceToolBLEx::setDeviceColor(const QString &color)
{
    m_color = color;
}

void DeviceToolBLEx::setStarred(bool v)
{
    if (m_userStarred != v)
    {
        m_userStarred = v;
        Q_EMIT starChanged();

        updateCache();
    }
}

void DeviceToolBLEx::setLastSeen(const QDateTime &dt)
{
    m_lastSeen = dt;
    Q_EMIT seenChanged();
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
                             "lastSeen = :lastSeen "
                            "WHERE deviceAddr = :deviceAddr");
        updateCache.bindValue(":deviceCoreConfig", m_bluetoothCoreConfiguration);
        updateCache.bindValue(":deviceClass", deviceClass);
        updateCache.bindValue(":starred", m_userStarred);
        updateCache.bindValue(":comment", m_userComment);
        //updateCache.bindValue(":color", m_userColor);
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
        if (c) static_cast<DeviceManager *>(parent())->cacheDevice(m_deviceAddress);
        else static_cast<DeviceManager *>(parent())->uncacheDevice(m_deviceAddress);

        setCache(c);
        if (m_rssi >= 0) setCached(c);
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolBLEx::deviceConnected()
{
    Device::deviceConnected();
}

/* ************************************************************************** */

void DeviceToolBLEx::addLowEnergyService(const QBluetoothUuid &uuid)
{
    qDebug() << "DeviceToolbox::addLowEnergyService(" << uuid.toString() << ")";

    QLowEnergyService *service = m_bleController->createServiceObject(uuid);
    if (!service)
    {
        qWarning() << "Cannot create service for UUID" << uuid;
        return;
    }

    auto serv = new ServiceInfo(service);
    m_services.append(serv);

    Q_EMIT servicesUpdated();
}

/* ************************************************************************** */

void DeviceToolBLEx::serviceScanDone()
{
    qDebug() << "DeviceToolbox::serviceScanDone(" << m_deviceAddress << ")";

    if (m_services.isEmpty())
    {
        Q_EMIT servicesUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceToolBLEx::parseAdvertisementToolBLEx(const uint16_t mode,
                                                const uint16_t id,
                                                const QBluetoothUuid &uuid,
                                                const QByteArray &data)
{
    bool hasNewData = false;

    // mode:
    // DeviceUtils::BLE_ADV_MANUFACTURERDATA
    // DeviceUtils::BLE_ADV_SERVICEDATA

    if (mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
    {
        if (!m_mfd.isEmpty())
        {
            hasNewData = m_mfd.first()->compare(data);
            if (!hasNewData) return false;
        }

        AdvertisementData *a = new AdvertisementData(mode, id, data);

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
        if (m_mfd.length() >= 16)
        {
            AdvertisementData *d = m_mfd.back();
            m_mfd.pop_back();
            m_advertisementData_filtered.removeOne(d);
            delete d;
        }

        Q_EMIT advertisementChanged();
    }
    else if (mode == DeviceUtils::BLE_ADV_SERVICEDATA)
    {
        if (!m_svd.isEmpty())
        {
            hasNewData = m_svd.first()->compare(data);
            if (!hasNewData) return false;
        }

        AdvertisementData *a = new AdvertisementData(mode, id, data);

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
        if (m_svd.length() >= 16)
        {
            AdvertisementData *d = m_svd.back();
            m_svd.pop_back();
            m_advertisementData_filtered.removeOne(d);
            delete d;
        }

        Q_EMIT advertisementChanged();
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
    m_advertisementEntries.push_back(new AdvertisementEntry(rssi, hasMFD, hasSVD));
    if (m_advertisementEntries.length() > 60)
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
