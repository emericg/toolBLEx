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

#include "adapter.h"
#include "VendorsDatabase.h"

#include <QProcess>
#include <QDebug>

/* ************************************************************************** */

Adapter::Adapter(const QBluetoothHostInfo &adapterInfo,
                 bool inUse, int hostMode,
                 QObject *parent) : QObject(parent)
{
    m_default = inUse;
    m_bluetooth_host_mode = hostMode;

    m_hostname = adapterInfo.name();
    m_address = adapterInfo.address().toString();
    m_bluetooth_version = "";

    VendorsDatabase *v = VendorsDatabase::getInstance();
    v->getVendor(m_address, m_mac_manufacturer);

#if defined(Q_OS_LINUX)
    QProcess process;
    process.start("btmgmt", QStringList("info"));
    process.waitForFinished(8000);

    QString output(process.readAllStandardOutput());
    //qDebug() << output;
    //QString err(process.readAllStandardError());
    //qDebug() << err;

    QStringList output_split = output.split('\n');
    for (const auto &line: output_split)
    {
        if (line.contains("addr ") && line.contains(m_address))
        {
            if (line.contains("version 12")) m_bluetooth_version = "5.3";
            else if (line.contains("version 11")) m_bluetooth_version = "5.2";
            else if (line.contains("version 10")) m_bluetooth_version = "5.1";
            else if (line.contains("version 9")) m_bluetooth_version = "5.0";
            else if (line.contains("version 8")) m_bluetooth_version = "4.2";
            else if (line.contains("version 7")) m_bluetooth_version = "4.1";
            else if (line.contains("version 6")) m_bluetooth_version = "4.0";
            else if (line.contains("version 5")) m_bluetooth_version = "3.0";
            else if (line.contains("version 4")) m_bluetooth_version = "2.1";
            else if (line.contains("version 3")) m_bluetooth_version = "2.0";
            else if (line.contains("version 2")) m_bluetooth_version = "1.2";
            else if (line.contains("version 1")) m_bluetooth_version = "1.1";
            else if (line.contains("version 0")) m_bluetooth_version = "1.0";
        }

        if (!m_bluetooth_version.isEmpty()) break;
    }
#endif // defined(Q_OS_LINUX)
}

/* ************************************************************************** */

void Adapter::update(bool inUse, int hostMode)
{
    m_default = inUse;
    m_bluetooth_host_mode = hostMode;
    Q_EMIT adapterUpdated();
}

/* ************************************************************************** */
