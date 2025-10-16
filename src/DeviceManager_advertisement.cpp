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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceManager.h"

#include "device_toolblex.h"

#include <QBluetoothDeviceInfo>
#include <QList>
#include <QDebug>

/* ************************************************************************** */

void DeviceManager::bleDevice_discovered(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "bleDevice_discovered() " << info.name() << info.address(); // << info.deviceUuid();
    bleDevice_updated(info, QBluetoothDeviceInfo::Field::None);
}

/* ************************************************************************** */

void DeviceManager::bleDevice_updated(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields)
{
    //qDebug() << "bleDevice_updated() " << info.name() << info.address(); // << info.deviceUuid() // << " updatedFields: " << updatedFields

    Q_UNUSED(updatedFields) // We don't use QBluetoothDeviceInfo::Fields, it's unreliable

    //qDebug() << "updateBleDevice() serviceUuids : " << info.serviceUuids();

    // Supported devices ///////////////////////////////////////////////////////

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
        if (dd && dd->getAddress() == info.deviceUuid().toString())
#else
        if (dd && dd->getAddress() == info.address().toString())
#endif
        {
            dd->setName(info.name());
            dd->setRssi(info.rssi());
            dd->setLastSeen(QDateTime::currentDateTime());
            dd->setCoreConfiguration(info.coreConfigurations());
            dd->setDeviceClass(info.majorDeviceClass(), info.minorDeviceClass(), info.serviceClasses());
            dd->setAdvertisedServices(info.serviceUuids());

            bool hasmfd = false;
            bool hassvd = false;

            // Handle advertisement //

            const QList <quint16> &manufacturerIds = info.manufacturerIds();
            for (const auto id: manufacturerIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "manufacturer data" << Qt::dec << info.manufacturerData(id).count() << Qt::hex
                //         << "bytes:" << info.manufacturerData(id).toHex();

                hasmfd |= dd->parseAdvertisementToolBLEx(DeviceUtils::BLE_ADV_MANUFACTURERDATA,
                                                         id, QBluetoothUuid(), info.manufacturerData(id));
            }

            const QList <QBluetoothUuid> &serviceIds = info.serviceIds();
            for (const auto id: serviceIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "service data" << Qt::dec << info.serviceData(id).count() << Qt::hex
                //         << "bytes:" << info.serviceData(id).toHex();

                hassvd |= dd->parseAdvertisementToolBLEx(DeviceUtils::BLE_ADV_SERVICEDATA,
                                                         id.toUInt16(), id, info.serviceData(id));
            }

            dd->addAdvertisementEntry(info.rssi(), hasmfd, hassvd);

            return;
        }
    }

    /// Dynamic scanning ///////////////////////////////////////////////////////

    if (m_scanning)
    {
        //qDebug() << "addBleDevice(" << info.name() << ") FROM DYNAMIC SCANNING";
        addBleDevice(info);
        return;
    }
}

/* ************************************************************************** */
