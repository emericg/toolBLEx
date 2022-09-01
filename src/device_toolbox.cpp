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
    advUUIDstr = QString::number(advUUID, 16).rightJustified(4, '0');

    VendorsDatabase *v = VendorsDatabase::getInstance();
    if (adv_mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
        v->getVendor_manufacturerID(advUUIDstr, advUUIDvendor);
    else if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA)
        v->getVendor_serviceUUID(advUUIDstr, advUUIDvendor);

    advData = data;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceToolbox::DeviceToolbox(const QString &deviceAddr, const QString &deviceName, QObject *parent):
    Device(deviceAddr, deviceName, parent)
{
    //
}

DeviceToolbox::DeviceToolbox(const QBluetoothDeviceInfo &d, QObject *parent):
    Device(d, parent)
{
    addAdvertisementEntry(d.rssi(), !d.manufacturerIds().empty(), !d.serviceIds().empty());
    setCoreConfiguration(d.coreConfigurations());

    if (d.rssi() == 0) setCached(true);
    if (d.isCached()) setCached(true);
}

DeviceToolbox::~DeviceToolbox()
{
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

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceToolbox::setCoreConfiguration(const int bleconf)
{
    if (bleconf == 1 && !m_isBLE) { m_isBLE = true; Q_EMIT boolChanged(); }
    if (bleconf == 2 && !m_isClassic) { m_isClassic = true; Q_EMIT boolChanged(); }

    Device::setCoreConfiguration(bleconf);
}

/* ************************************************************************** */

void DeviceToolbox::serviceScanDone()
{
    qDebug() << "DeviceToolbox::serviceScanDone(" << m_deviceAddress << ")";

    if (m_services.isEmpty())
    {
        Q_EMIT servicesUpdated();
    }
}

/* ************************************************************************** */

void DeviceToolbox::addLowEnergyService(const QBluetoothUuid &uuid)
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
/* ************************************************************************** */

bool DeviceToolbox::parseAdvertisementToolBLEx(const uint16_t mode,
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

void DeviceToolbox::addAdvertisementEntry(const int rssi, const bool hasMFD, const bool hasSVD)
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

void DeviceToolbox::cleanAdvertisementEntries()
{
    qDeleteAll(m_advertisementEntries);
    m_advertisementEntries.clear();
}

/* ************************************************************************** */

void DeviceToolbox::mfdFilterUpdate()
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

void DeviceToolbox::svdFilterUpdate()
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

void DeviceToolbox::advertisementFilterUpdate()
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
