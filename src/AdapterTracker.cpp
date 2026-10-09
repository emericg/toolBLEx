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

#include "AdapterTracker.h"
#include "adapter.h"

/* ************************************************************************** */

AdapterTracker::AdapterTracker(QObject *parent) : QObject(parent)
{
    //
}

void AdapterTracker::setAdapter(Adapter *adapter)
{
    if (m_adapter == adapter) return;

    if (m_adapter) disconnect(m_adapter, nullptr, this, nullptr);
    if (m_device) disconnect(m_device, nullptr, this, nullptr);

    m_adapter = adapter;
    m_device = nullptr;

    if (m_adapter)
    {
        connect(m_adapter, &Adapter::deviceChanged, this, &AdapterTracker::adapterDeviceChanged);
        connectDevice();
    }
}

void AdapterTracker::connectDevice()
{
    // The previous device is usually deleted already, along with its connections
    if (m_device) disconnect(m_device, nullptr, this, nullptr);

    m_device = m_adapter->getDevice();
    if (m_device)
    {
        connect(m_device, &QBluetoothLocalDevice::hostModeStateChanged, this, &AdapterTracker::hostModeChanged);
        connect(m_device, &QBluetoothLocalDevice::pairingFinished, this, &AdapterTracker::pairingFinished);
        connect(m_device, &QBluetoothLocalDevice::errorOccurred, this, &AdapterTracker::errorOccurred);
    }
}

void AdapterTracker::adapterDeviceChanged()
{
    connectDevice();
    Q_EMIT deviceChanged();
}

/* ************************************************************************** */
