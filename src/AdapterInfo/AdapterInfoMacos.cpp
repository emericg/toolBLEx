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

#include "AdapterInfoMacos.h"

#include <QProcess>
#include <QDebug>

/* ************************************************************************** */

AdapterInfoMacos::AdapterInfoMacos(QObject *parent) : AdapterInfo(parent)
{
    //
}

void AdapterInfoMacos::query(const QBluetoothAddress &address)
{
    m_address = address;

    if (m_profiler) return; // already running

    const QStringList arguments = { "-detailLevel", "full", "SPBluetoothDataType" };
    m_profiler = startProcess("system_profiler", arguments, [this](const QString &output) {
        AdapterDetails details = m_details;
        parseProfiler(output, details);
        setDetails(details);
    });
    if (m_profiler)
    {
        connect(m_profiler, &QObject::destroyed, this, [this]() { m_profiler = nullptr; });
    }
}

/* ************************************************************************** */

void AdapterInfoMacos::parseProfiler(const QString &output, AdapterDetails &details)
{
    // Output example:
    // Bluetooth:
    //
    // Bluetooth Controller:
    //     Address: 00:11:22:33:44:55
    //     State: On
    //     Chipset: BCM_4388C2
    //     Discoverable: Off
    //     Firmware Version: 23.5.224.1475
    //     Product ID: 0x4A3F
    //     Supported services: 0x392039 < HFP AVRCP A2DP HID Braille LEA AACP GATT SerialPort >
    //     Transport: PCIe
    //     Vendor ID: 0x004C (Apple)
    // Not Connected:
    //     DeviceName:
    //     Address: 11:22:33:44:55:66

    bool controllersection = false;

    const QStringList output_split = output.split('\n');
    for (const auto &line: output_split)
    {
        if (controllersection)
        {
            const QStringList line_split = line.trimmed().split(' ', Qt::SkipEmptyParts);
            if (line_split.size() < 2) break;

            if (line.contains("BT Spec:"))
            {
                if (line_split.size() >= 3) details.coreVersion = line_split.at(2);
            }
            else if (line.contains("Chipset:")) details.chipset = line_split.at(1);
            else if (line.contains("Firmware Version:"))
            {
                if (line_split.size() >= 3) details.chipsetFirmware = line_split.at(2);
            }
            else if (line.contains("Vendor ID:"))
            {
                if (line_split.size() >= 3)
                {
                    bool ok = false;
                    const int manufacturer = QString(line_split.at(2)).remove("0x").toInt(&ok, 16);
                    if (ok) details.manufacturerId = manufacturer;
                }
            }
        }

        if (line.contains("Bluetooth Controller"))
        {
            controllersection = true;
        }
        else if (line.contains("Connected"))
        {
            break; // went too far
        }
    }
}

/* ************************************************************************** */
