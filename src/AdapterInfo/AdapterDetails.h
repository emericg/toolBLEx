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

#ifndef ADAPTER_DETAILS_H
#define ADAPTER_DETAILS_H
/* ************************************************************************** */

#include <QString>
#include <QStringList>

#include <optional>
#include <tuple>

/* ************************************************************************** */

/*!
 * \brief Local Bluetooth adapter information, as gathered by an AdapterInfo backend.
 *
 * All fields are optional: empty strings or lists, -1, or std::nullopt,
 * when the platform does not provide them.
 */
struct AdapterDetails
{
    QString name;                   //!< System name (Linux: pretty hostname, or main.conf Name).
    QString alias;                  //!< Name seen by remote devices.
    QString addressType;            //!< "public" or "random".

    QString chipset;                //!< Chipset name.
    QString chipsetFirmware;        //!< Chipset firmware version.
    QString usbId;                  //!< USB vendor and product IDs, ex: "8087:0026".
    QString coreVersion;            //!< Bluetooth core specification version, ex: "5.4".
    int manufacturerId = -1;        //!< Bluetooth SIG company identifier of the controller.
    int lmpSubversion = -1;         //!< Manufacturer specific LMP subversion.

    std::optional <bool> classic;               //!< BR/EDR supported.
    std::optional <bool> lowEnergy;             //!< LE supported.
    std::optional <bool> centralRole;           //!< LE central role supported.
    std::optional <bool> peripheralRole;        //!< LE peripheral role supported.
    std::optional <bool> leSecureConnections;   //!< LE Secure Connections supported.
    std::optional <bool> extendedAdvertising;   //!< LE extended advertising supported.
    std::optional <bool> advertisingOffload;    //!< Advertising handled by the controller.

    int maxAdvertisingLength = -1;  //!< Maximum advertising data length, in bytes.
    int maxScanResponseLength = -1; //!< Maximum scan response data length, in bytes.
    std::optional <int> txPowerMin; //!< Minimum advertising TX power, in dBm.
    std::optional <int> txPowerMax; //!< Maximum advertising TX power, in dBm.
    int advertisingInstances = -1;  //!< Number of advertising sets supported.
    int activeAdvertisingInstances = -1; //!< Number of advertising sets in use.

    QStringList phys;               //!< LE PHYs, ex: "1M", "2M", "Coded".
    QStringList settings;           //!< Raw platform settings list (Linux: mgmt supported settings).

    auto tie() const
    {
        return std::tie(name, alias, addressType,
                        chipset, chipsetFirmware, usbId, coreVersion, manufacturerId, lmpSubversion,
                        classic, lowEnergy, centralRole, peripheralRole,
                        leSecureConnections, extendedAdvertising, advertisingOffload,
                        maxAdvertisingLength, maxScanResponseLength, txPowerMin, txPowerMax,
                        advertisingInstances, activeAdvertisingInstances,
                        phys, settings);
    }
    bool operator==(const AdapterDetails &other) const { return tie() == other.tie(); }
    bool operator!=(const AdapterDetails &other) const { return !(*this == other); }
};

/* ************************************************************************** */
#endif // ADAPTER_DETAILS_H
