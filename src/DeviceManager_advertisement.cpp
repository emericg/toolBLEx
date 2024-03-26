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
#include <QDebug>

/* ************************************************************************** */

void DeviceManager::updateBleDevice_discovery(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "updateBleDevice_discovery() " << info.name() << info.address(); // << info.deviceUuid(); // << " updatedFields: " << updatedFields;

    addBleDevice(info);
}

void DeviceManager::updateBleDevice_simple(const QBluetoothDeviceInfo &info)
{
    updateBleDevice(info, QBluetoothDeviceInfo::Field::None);
}

void DeviceManager::updateBleDevice(const QBluetoothDeviceInfo &info,
                                    QBluetoothDeviceInfo::Fields updatedFields)
{
    //qDebug() << "updateBleDevice() " << info.name() << info.address(); // << info.deviceUuid(); // << " updatedFields: " << updatedFields;

    Q_UNUSED(updatedFields) // We don't use QBluetoothDeviceInfo::Fields, it's unreliable
    if (updatedFields > 1)
    {
        //QBluetoothDeviceInfo::Field::None	0x0000	None of the values changed.
        //QBluetoothDeviceInfo::Field::RSSI	0x0001	The rssi() value of the device changed.
        //QBluetoothDeviceInfo::Field::ManufacturerData	0x0002	The manufacturerData() field changed
        //QBluetoothDeviceInfo::Field::ServiceData	0x0004	The serviceData() field changed
        //QBluetoothDeviceInfo::Field::All	0x7fff	Matches every possible field.

        //qDebug() << "updateBleDevice() " << info.name() << info.address() << " updatedFields: " << updatedFields;
    }

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
                                                         id, QBluetoothUuid(),
                                                         info.manufacturerData(id));
            }

            const QList <QBluetoothUuid> &serviceIds = info.serviceIds();
            for (const auto id: serviceIds)
            {
                //qDebug() << info.name() << info.address() << Qt::hex
                //         << "ID" << id
                //         << "service data" << Qt::dec << info.serviceData(id).count() << Qt::hex
                //         << "bytes:" << info.serviceData(id).toHex();

                hassvd |= dd->parseAdvertisementToolBLEx(DeviceUtils::BLE_ADV_SERVICEDATA,
                                                         id.toUInt16(), id,
                                                         info.serviceData(id));
            }

            dd->addAdvertisementEntry(info.rssi(), hasmfd, hassvd);

            return;
        }
    }

    // Dynamic scanning ////////////////////////////////////////////////////////
    {
        //qDebug() << "addBleDevice() FROM DYNAMIC SCANNING";
        addBleDevice(info);
        return;
    }
}

/* ************************************************************************** */
