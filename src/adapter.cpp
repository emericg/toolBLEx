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
#include "AdapterInfo.h"
#include "VendorsDatabase.h"

#include <QDebug>

/* ************************************************************************** */

Adapter::Adapter(const QBluetoothHostInfo &adapterInfo, QObject *parent) : QObject(parent)
{
    m_hostname = adapterInfo.name();
    m_address = adapterInfo.address();

    checkAdapter();

    VendorsDatabase *v = VendorsDatabase::getInstance();
    v->getVendor(m_address.toString(), m_mac_manufacturer);

    m_info = AdapterInfo::create(this);
    if (m_info)
    {
        connect(m_info, &AdapterInfo::detailsChanged, this, &Adapter::detailsChanged);
        m_info->query(adapterInfo.address());
    }
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

void Adapter::detailsChanged(const AdapterDetails &details)
{
    m_details = details;

    if (!m_details.alias.isEmpty()) m_hostname = m_details.alias;
    m_system_name = (m_details.name != m_hostname) ? m_details.name : QString();

    m_chipset = m_details.chipset;
    if (m_chipset.isEmpty() && !m_details.usbId.isEmpty()) m_chipset = "USB " + m_details.usbId;

    m_manufacturer.clear();
    if (m_details.manufacturerId >= 0)
    {
        const QString manufacturer = QString("%1").arg(m_details.manufacturerId, 4, 16, QLatin1Char('0'));
        VendorsDatabase::getInstance()->getVendor_manufacturerID(manufacturer, m_manufacturer);
    }

    m_bluetooth_features = generateFeatures();

    Q_EMIT adapterUpdated();
}

QStringList Adapter::getRoles() const
{
    QStringList roles;
    if (m_details.centralRole.value_or(false)) roles << "Central";
    if (m_details.peripheralRole.value_or(false)) roles << "Peripheral";
    return roles;
}

QStringList Adapter::generateFeatures() const
{
    QStringList features;
    const AdapterDetails &d = m_details;

    if (d.lowEnergy.value_or(false)) features << "LE";
    if (d.classic.value_or(false)) features << "BR/EDR";
    if (d.leSecureConnections.value_or(false)) features << "LE Secure Connections";
    if (d.extendedAdvertising.value_or(false)) features << "Extended advertising";
    if (d.advertisingOffload.value_or(false)) features << "Advertising offload";

    return features;
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

bool Adapter::checkAdapter(bool force)
{
    bool status = false;

    if (!force && m_adapter_device && m_adapter_device->isValid())
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

        m_adapter_device = new QBluetoothLocalDevice(m_address, this);
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

            Q_EMIT deviceChanged();

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

void Adapter::setHostMode(int hostMode)
{
    if (m_bluetooth_host_mode != hostMode)
    {
        m_bluetooth_host_mode = hostMode;
        Q_EMIT adapterUpdated();
    }
}

void Adapter::setAvailable(bool available)
{
    if (m_available == available) return;
    m_available = available;

    if (m_available) checkAdapter(true);
    else setHostMode(QBluetoothLocalDevice::HostPoweredOff);

    Q_EMIT adapterUpdated();
}

void Adapter::setDefault_scan(bool isDefault)
{
    if (m_default_scan != isDefault)
    {
        m_default_scan = isDefault;
        Q_EMIT adapterUpdated();
    }
}

void Adapter::setDefault_sim(bool isDefault)
{
    if (m_default_sim != isDefault)
    {
        m_default_sim = isDefault;
        Q_EMIT adapterUpdated();
    }
}

void Adapter::setInUse_scan(bool inUse)
{
    if (m_inUse_scan != inUse)
    {
        m_inUse_scan = inUse;
        Q_EMIT adapterUpdated();
    }
}

void Adapter::setInUse_sim(bool inUse)
{
    if (m_inUse_sim != inUse)
    {
        m_inUse_sim = inUse;
        Q_EMIT adapterUpdated();
    }
}

/* ************************************************************************** */
