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

#include "device_toolblex_adv.h"
#include "device_utils.h"
#include "VendorsDatabase.h"

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QDateTime>
#include <QDebug>

/* ************************************************************************** */

AdvertisementData::AdvertisementData(const uint16_t adv_mode, const uint16_t adv_id,
                                     const QBluetoothUuid &adv_uuid,
                                     const QByteArray &data, const QDateTime &timestamp,
                                     QObject *parent): QObject(parent)
{
    m_timestamp = timestamp;
    advMode = adv_mode;
    advUUID = adv_id;
    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA) advServiceUUID = adv_uuid;
    advUUIDstr = uuidToString(adv_mode, adv_id, adv_uuid);

    VendorsDatabase *v = VendorsDatabase::getInstance();
    if (adv_mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
        v->getVendor_manufacturerID(advUUIDstr, advUUIDvendor);
    else if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA)
        v->getVendor_serviceUUID(advUUIDstr, advUUIDvendor);

    advData = data;
}

QString AdvertisementData::uuidToString(const uint16_t adv_mode, const uint16_t adv_id,
                                        const QBluetoothUuid &adv_uuid)
{
    if (adv_mode == DeviceUtils::BLE_ADV_SERVICEDATA)
    {
        bool success = false;

        const quint16 uuid16 = adv_uuid.toUInt16(&success);
        if (success) return QString::number(uuid16, 16).toUpper().rightJustified(4, '0');

        const quint32 uuid32 = adv_uuid.toUInt32(&success);
        if (success) return QString::number(uuid32, 16).toUpper().rightJustified(8, '0');

        return adv_uuid.toString(QUuid::WithoutBraces).toUpper();
    }

    return QString::number(adv_id, 16).toUpper().rightJustified(4, '0');
}

/* ************************************************************************** */
