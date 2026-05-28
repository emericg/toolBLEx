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

Adapter::Adapter(const QBluetoothHostInfo &adapterInfo, QObject *parent) : QObject(parent)
{
    checkAdapter();

    m_hostname = adapterInfo.name();
    m_address = adapterInfo.address().toString();

    VendorsDatabase *v = VendorsDatabase::getInstance();
    v->getVendor(m_address, m_mac_manufacturer);

#if defined(Q_OS_LINUX)
    QProcess process;
    process.start("btmgmt", QStringList("info"));
    process.waitForFinished(8000); // 8 ms

    QString output(process.readAllStandardOutput());
    //qDebug() << output;
    //QString err(process.readAllStandardError());
    //qDebug() << err;

    // Output example:
    // hci1: Primary controller
    // addr 00:11:22:33:44:55 version 13 manufacturer 2279 class 0x6c0104
    // supported settings: powered connectable fast-connectable discoverable bondable link-security ssp br/edr le advertising secure-conn debug-keys privacy static-addr phy-configuration ll-privacy
    // current settings: powered ssp br/edr le secure-conn ll-privacy
    // name desktop-emeric #2
    // short name

    const QStringList output_split = output.split('\n');
    for (int i = 0; i < output_split.size(); i++)
    {
        auto line = output_split.at(i);
        if (line.contains("addr ") && line.contains(m_address))
        {
            const QStringList line_split = line.split(' ');
            for (int j = 0; j < line_split.size(); j++)
            {
                auto &section = line_split.at(j);
                if (section == "version")
                {
                    QString version = line_split.at(++j);

                    if (version == "17") m_bluetooth_version = "6.3";
                    else if (version == "16") m_bluetooth_version = "6.2";
                    else if (version == "15") m_bluetooth_version = "6.1";
                    else if (version == "14") m_bluetooth_version = "6.0";
                    else if (version == "13") m_bluetooth_version = "5.4";
                    else if (version == "12") m_bluetooth_version = "5.3";
                    else if (version == "11") m_bluetooth_version = "5.2";
                    else if (version == "10") m_bluetooth_version = "5.1";
                    else if (version == "9") m_bluetooth_version = "5.0";
                    else if (version == "8") m_bluetooth_version = "4.2";
                    else if (version == "7") m_bluetooth_version = "4.1";
                    else if (version == "6") m_bluetooth_version = "4.0";
                    else if (version == "5") m_bluetooth_version = "3.0";
                    else if (version == "4") m_bluetooth_version = "2.1";
                    else if (version == "3") m_bluetooth_version = "2.0";
                    else if (version == "2") m_bluetooth_version = "1.2";
                    else if (version == "1") m_bluetooth_version = "1.1";
                    else if (version == "0") m_bluetooth_version = "1.0";

                    //qDebug() << "version >" << version << m_bluetooth_version;
                }
                else if (section == "manufacturer")
                {
                    QString manufacturer = QString("%1").arg(line_split.at(++j).toInt(), 4, 16, QLatin1Char('0'));

                    VendorsDatabase *v = VendorsDatabase::getInstance();
                    v->getVendor_manufacturerID(manufacturer, m_manufacturer);

                    //qDebug() << "manufacturer >" << manufacturer << m_manufacturer;
                }
                else if (section == "class")
                {
                    QString cclass = line_split.at(++j);
                    //qDebug() << "class >" << cclass;
                }
            }
/*
            // The next line might interest us too...
            auto nextline = output_split.at(++i);
            if (nextline.contains("supported settings: "))
            {
                nextline.remove("supported settings: ");
                nextline.remove('\t');

                const QStringList nextline_split = nextline.remove("supported settings: ").split(' ', Qt::SkipEmptyParts);
                for (auto &section: std::as_const(nextline_split))
                {
                    m_bluetooth_features.push_back(section);
                }
            }
*/
        }

        if (!m_bluetooth_version.isEmpty()) break;
    }
#endif // defined(Q_OS_LINUX)
}

Adapter::~Adapter()
{
    delete m_adapter_device;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Adapter::hostModeStateChanged(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "Adapter::hostModeStateChanged(" << m_address << ") state: " << state;
    setHostMode(state);
}

void Adapter::deviceConnected(const QBluetoothAddress &address)
{
    qDebug() << "Adapter::deviceConnected(" << m_address << ") to " << address;
}

void Adapter::deviceDisconnected(const QBluetoothAddress &address)
{
    qDebug() << "Adapter::deviceDisconnected(" << m_address << ") to " << address;
}

void Adapter::pairingFinished(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing)
{
    qDebug() << "Adapter::pairingFinished(" << m_address << ") to " << address << " / pairing status:" << pairing;
}

void Adapter::errorOccurred(QBluetoothLocalDevice::Error error)
{
    qWarning() << "Adapter::errorOccurred(" << m_address << ") ERROR:" << error;

    // NoError,
    // PairingError,
    // MissingPermissionsError,
    // UnknownError
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Adapter::checkAdapter()
{
    bool status = false;

    if (m_adapter_device && m_adapter_device->isValid())
    {
        //qDebug() << "Adapter::checkAdapter(" << m_address << ") VALID";
        setHostMode(m_adapter_device->hostMode());
        status = true;
    }
    else
    {
        if (m_adapter_device)
        {
            disconnect(m_adapter_device, &QBluetoothLocalDevice::hostModeStateChanged,
                       this, &Adapter::hostModeStateChanged);
            disconnect(m_adapter_device, &QBluetoothLocalDevice::deviceConnected,
                       this, &Adapter::deviceConnected);
            disconnect(m_adapter_device, &QBluetoothLocalDevice::deviceDisconnected,
                       this, &Adapter::deviceDisconnected);
            disconnect(m_adapter_device, &QBluetoothLocalDevice::pairingFinished,
                       this, &Adapter::pairingFinished);

            disconnect(m_adapter_device, &QBluetoothLocalDevice::errorOccurred,
                       this, &Adapter::errorOccurred);

            delete m_adapter_device;
            m_adapter_device = nullptr;
        }

        m_adapter_device = new QBluetoothLocalDevice(QBluetoothAddress(m_address), this);
        if (m_adapter_device)
        {
            setHostMode(m_adapter_device->hostMode());

            connect(m_adapter_device, &QBluetoothLocalDevice::hostModeStateChanged,
                    this, &Adapter::hostModeStateChanged);
            connect(m_adapter_device, &QBluetoothLocalDevice::deviceConnected,
                    this, &Adapter::deviceConnected);
            connect(m_adapter_device, &QBluetoothLocalDevice::deviceDisconnected,
                    this, &Adapter::deviceDisconnected);
            connect(m_adapter_device, &QBluetoothLocalDevice::pairingFinished,
                    this, &Adapter::pairingFinished);

            connect(m_adapter_device, &QBluetoothLocalDevice::errorOccurred,
                    this, &Adapter::errorOccurred);

            if (m_adapter_device->isValid())
            {
                status = true;
            }
            else
            {
                qWarning() << "Adapter::checkAdapter(" << m_address << ") UNABLE TO GET VALID ADAPTER";
                status = false;
            }
        }
    }

    return status;
}

void Adapter::update(bool isDefault, int inUse)
{
    bool changed = false;

    if (m_default != isDefault)
    {
        m_default = isDefault;
        changed = true;
    }
    if (m_inUse != inUse)
    {
        m_inUse = inUse;
        changed = true;
    }

    if (changed) Q_EMIT adapterUpdated();
}

void Adapter::setHostMode(int hostMode)
{
    if (m_bluetooth_host_mode != hostMode)
    {
        m_bluetooth_host_mode = hostMode;
        Q_EMIT adapterUpdated();
    }
}

void Adapter::setDefault(bool isDefault)
{
    if (m_default != isDefault)
    {
        m_default = isDefault;
        Q_EMIT adapterUpdated();
    }
}

void Adapter::setInUse(bool inUse)
{
    if (m_inUse != inUse)
    {
        m_inUse = inUse;
        Q_EMIT adapterUpdated();
    }
}

/* ************************************************************************** */
