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

#include <cstdlib>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>

#include <QDateTime>
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
