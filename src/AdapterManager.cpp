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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "AdapterManager.h"
#include "SettingsManager.h"

#include "adapter.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QJSEngine>
#include <QPermissions>
#include <QDebug>

#include <QBluetoothLocalDevice>
#include <QBluetoothHostInfo>

/* ************************************************************************** */
/* ************************************************************************** */

AdapterManager *AdapterManager::getInstance()
{
    static AdapterManager *instance = new AdapterManager(QCoreApplication::instance());
    return instance;
}

AdapterManager *AdapterManager::create(QQmlEngine *, QJSEngine *)
{
    AdapterManager *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

AdapterManager::AdapterManager(QObject *parent) : QObject(parent)
{
    // Adapters plugged / unplugged
    m_adaptersRefreshTimer.setSingleShot(true);
    m_adaptersRefreshTimer.setInterval(250);
    connect(&m_adaptersRefreshTimer, &QTimer::timeout, this, &AdapterManager::refreshAdapters);

    if (!startAdaptersWatcher_bluez() && !startAdaptersWatcher_windows())
    {
        // No native adapters watcher, fallback to polling
        m_adaptersPollTimer.setInterval(s_adaptersPollInterval);
        connect(&m_adaptersPollTimer, &QTimer::timeout, this, &AdapterManager::pollAdapters);
        m_adaptersPollTimer.start();
    }

    // Preferred adapters, the scan adapter only changes when a scan is started
    SettingsManager *sm = SettingsManager::getInstance();
    connect(sm, &SettingsManager::preferredAdapterScanChanged, this, &AdapterManager::preferredAdapterChanged);
    connect(sm, &SettingsManager::preferredAdapterSimChanged, this, &AdapterManager::preferredAdapterChanged);

    // Permission changes
    if (auto *app = qobject_cast<QGuiApplication *>(QCoreApplication::instance()))
    {
        connect(app, &QGuiApplication::applicationStateChanged,
                this, &AdapterManager::applicationStateChanged);
    }

    // BLE permission initial check // will call enableBluetooth_scan();
    requestBluetoothPermission();
}

AdapterManager::~AdapterManager()
{
    stopAdaptersWatcher_windows();

    m_adapter_scan = nullptr;
    m_adapter_sim = nullptr;
    m_adapterStatus_sim = nullptr;

    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool AdapterManager::checkBluetooth_scan()
{
    //qDebug() << "AdapterManager::checkBluetooth_scan()";

    bool btA_was = m_bleAdapter_scan;
    bool btE_was = m_bleEnabled_scan;
    bool btP_was = m_blePermission;

    // Check permissions
    checkBluetoothPermission();

    // Check adapters (re-plugged adapters get a new device)
    checkAdapters();

    // Check scan adapter availability
    checkAdapterDevice_scan();

    if (btA_was != m_bleAdapter_scan || btE_was != m_bleEnabled_scan || btP_was != m_blePermission)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged_scan();

        // let's see if we can turn on the adapter now
        enableBluetooth_scan();
    }

    return (m_bleAdapter_scan && m_bleEnabled_scan && m_blePermission);
}

bool AdapterManager::enableBluetooth_scan()
{
    //qDebug() << "AdapterManager::enableBluetooth_scan()";

    bool btA_was = m_bleAdapter_scan;
    bool btE_was = m_bleEnabled_scan;
    bool btP_was = m_blePermission;

    // List all Bluetooth adapters, then pick the one to use
    updateAdapters();
    setAdapter_scan(pickAdapter_scan());

    // Check scan adapter availability
    QBluetoothLocalDevice *dev = getAdapterDevice_scan();
    if (dev && dev->isValid())
    {
        m_bleAdapter_scan = true;

        if (dev->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            // Is already activated
            m_bleEnabled_scan = true;
        }
        else
        {
            // Try to activate the adapter // Doesn't work on all platforms...
            dev->powerOn();
        }
    }
    else
    {
        qWarning() << "AdapterManager::enableBluetooth_scan() we have an invalid adapter";
        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
    }

    if (btA_was != m_bleAdapter_scan || btE_was != m_bleEnabled_scan || btP_was != m_blePermission)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged_scan();
    }

    return (m_bleAdapter_scan && m_bleEnabled_scan && m_blePermission);
}

/* ************************************************************************** */

bool AdapterManager::requestBluetoothPermission()
{
    //qDebug() << "AdapterManager::requestBluetoothPermission()";

    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        setBluetoothPermission(true);
        enableBluetooth_scan();
        Q_EMIT permissionRequestFinished(true);
        break;
    case Qt::PermissionStatus::Denied:
    case Qt::PermissionStatus::Undetermined:
        qDebug() << "Requesting BLUETOOTH permission...";
        qApp->requestPermission(bluetoothPermission, this, &AdapterManager::requestBluetoothPermission_results);
        break;
    }

    return m_blePermission;
}

void AdapterManager::requestBluetoothPermission_results(const QPermission &permission)
{
    // evaluate the results
    switch (permission.status())
    {
    case Qt::PermissionStatus::Granted:
        setBluetoothPermission(true);
        enableBluetooth_scan();
        break;
    case Qt::PermissionStatus::Denied:
    case Qt::PermissionStatus::Undetermined:
        setBluetoothPermission(false);
        break;
    }

    Q_EMIT permissionRequestFinished(m_blePermission);
}

bool AdapterManager::checkBluetoothPermission()
{
    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        setBluetoothPermission(true);
        break;
    case Qt::PermissionStatus::Denied:
        setBluetoothPermission(false);
        break;
    case Qt::PermissionStatus::Undetermined:
        break;
    }

    return m_blePermission;
}

void AdapterManager::setBluetoothPermission(bool perm)
{
    if (m_blePermission != perm)
    {
        m_blePermission = perm;
        Q_EMIT permissionChanged();

        // The scan status is updated by the callers, along with the scan adapter
        Q_EMIT bluetoothChanged_sim();
    }
}

void AdapterManager::applicationStateChanged(Qt::ApplicationState state)
{
    if (state != Qt::ApplicationActive) return;

    // The permission may have been changed from the OS settings while we were in the background
    bool btP_was = m_blePermission;
    checkBluetoothPermission();

    if (btP_was != m_blePermission)
    {
        Q_EMIT bluetoothChanged_scan();

        if (m_blePermission) enableBluetooth_scan();
    }
}

/* ************************************************************************** */

void AdapterManager::discoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        if (m_bleEnabled_scan)
        {
            m_bleEnabled_scan = false;
            Q_EMIT bluetoothChanged_scan();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
        Q_EMIT bluetoothChanged_scan();

        QTimer::singleShot(s_discoveryErrorRecoveryDelay, this, &AdapterManager::recoverFromDiscoveryError);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        m_bleAdapter_scan = false;

        if (m_bleEnabled_scan)
        {
            m_bleEnabled_scan = false;
            Q_EMIT bluetoothChanged_scan();
        }

        QTimer::singleShot(s_discoveryErrorRecoveryDelay, this, &AdapterManager::recoverFromDiscoveryError);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Platform.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
        Q_EMIT bluetoothChanged_scan();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";

        m_bleEnabled_scan = false;
        Q_EMIT bluetoothChanged_scan();
        setBluetoothPermission(false);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_bleEnabled_scan = false;
        Q_EMIT bluetoothChanged_scan();
        setBluetoothPermission(false);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        m_bleEnabled_scan = false;
        Q_EMIT bluetoothChanged_scan();
        setBluetoothPermission(false);
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
        Q_EMIT bluetoothChanged_scan();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

Adapter *AdapterManager::getAdapter(const QBluetoothAddress &address) const
{
    if (address.isNull()) return nullptr;

    const QString addr = address.toString();
    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (adp->getAddress() == addr) return adp;
        }
    }

    return nullptr;
}

void AdapterManager::updateAdapters()
{
    const QList <QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
    if (adaptersList.isEmpty())
    {
        qWarning() << "> No Bluetooth adapter found...";
    }

    m_adaptersPresent.clear();
    for (const QBluetoothHostInfo &hi: std::as_const(adaptersList))
    {
        m_adaptersPresent.insert(hi.address().toUInt64());
    }

    for (const QBluetoothHostInfo &hi: std::as_const(adaptersList))
    {
        Adapter *adapter = getAdapter(hi.address());
        if (adapter)
        {
            if (adapter->isAvailable()) adapter->checkAdapter();
            else adapter->setAvailable(true); // re-plugged, gets a new device
        }
        else
        {
            adapter = new Adapter(hi, this);

            m_bluetoothAdapters.push_back(adapter);
            Q_EMIT adaptersListUpdated();
        }
    }

    // Unplugged adapters are kept, as they usually reappear
    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (!m_adaptersPresent.contains(QBluetoothAddress(adp->getAddress()).toUInt64()))
            {
                adp->setAvailable(false);
            }
        }
    }

    updateDefaultAdapters();
    updateAdapterSelected_scan();
    updateStatus_sim();
}

void AdapterManager::checkAdapters()
{
    for (auto obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (adp->isAvailable()) adp->checkAdapter();
        }
    }

    updateDefaultAdapters();
    updateStatus_sim();
}

void AdapterManager::updateDefaultAdapters()
{
    const QString preferredAdapter_scan = SettingsManager::getInstance()->getPreferredAdapter_scan();
    const QString preferredAdapter_sim = SettingsManager::getInstance()->getPreferredAdapter_sim();

    for (auto obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            adp->setDefault_scan(adp->getAddress() == preferredAdapter_scan);
            adp->setDefault_sim(adp->getAddress() == preferredAdapter_sim);
        }
    }
}

void AdapterManager::preferredAdapterChanged()
{
    updateDefaultAdapters();
    updateAdapterSelected_scan();
    updateStatus_sim();
}

/* ************************************************************************** */
/* ************************************************************************** */

QBluetoothLocalDevice *AdapterManager::getAdapterDevice_scan() const
{
    return m_adapter_scan ? m_adapter_scan->getDevice() : nullptr;
}

QBluetoothAddress AdapterManager::getAdapterAddress_scan() const
{
    return m_adapter_scan ? QBluetoothAddress(m_adapter_scan->getAddress()) : QBluetoothAddress();
}

void AdapterManager::updateAdapterSelected_scan()
{
    // Preferred adapter, if known (even if unplugged)
    const QString preferredAdapter = SettingsManager::getInstance()->getPreferredAdapter_scan();
    if (Adapter *preferred = getAdapter(QBluetoothAddress(preferredAdapter)))
    {
        m_adapterSelected_scan = QBluetoothAddress(preferred->getAddress());
        return;
    }

    // Selection is kept while the adapter is unplugged
    if (getAdapter(m_adapterSelected_scan)) return;

    // First available adapter
    m_adapterSelected_scan.clear();
    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (adp->isValid())
            {
                m_adapterSelected_scan = QBluetoothAddress(adp->getAddress());
                break;
            }
        }
    }
}

Adapter *AdapterManager::pickAdapter_scan() const
{
    // Keep the scan adapter while it is usable, see switchAdapter_scan()
    if (m_adapter_scan && m_adapter_scan->isValid()) return m_adapter_scan;

    Adapter *selected = getAdapter(m_adapterSelected_scan);
    if (selected && selected->isValid()) return selected;

    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (adp->isValid()) return adp;
        }
    }

    return nullptr;
}

void AdapterManager::setAdapter_scan(Adapter *adapter)
{
    if (m_adapter_scan == adapter) return;

    if (m_adapter_scan)
    {
        disconnect(m_adapter_scan, &Adapter::deviceChanged,
                   this, &AdapterManager::deviceChanged_scan);

        if (QBluetoothLocalDevice *dev = m_adapter_scan->getDevice())
        {
            disconnect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                       this, &AdapterManager::hostModeChanged_scan);
        }
    }

    m_adapter_scan = adapter;

    if (m_adapter_scan)
    {
        qDebug() << "AdapterManager::setAdapter_scan()" << m_adapter_scan->getAddress();

        connect(m_adapter_scan, &Adapter::deviceChanged,
                this, &AdapterManager::deviceChanged_scan);

        // Keep us informed of Bluetooth adapter state change
        // On some platform, this can only inform us about disconnection, not reconnection
        if (QBluetoothLocalDevice *dev = m_adapter_scan->getDevice())
        {
            connect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                    this, &AdapterManager::hostModeChanged_scan);
        }
    }

    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            adp->setInUse_scan(adp == m_adapter_scan);
        }
    }

    // The scan adapter is the simulator fallback
    updateStatus_sim();

    Q_EMIT adapterChanged_scan();
}

void AdapterManager::checkAdapterDevice_scan()
{
    QBluetoothLocalDevice *dev = getAdapterDevice_scan();
    if (dev && dev->isValid())
    {
        m_bleAdapter_scan = true;

        if (dev->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            m_bleEnabled_scan = true;
        }
        else
        {
            m_bleEnabled_scan = false;
            qWarning() << "Bluetooth adapter host mode:" << dev->hostMode();
        }
    }
    else
    {
        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
        qWarning() << "Bluetooth adapter INVALID";
    }
}

bool AdapterManager::switchAdapter_scan()
{
    // Refresh the adapters list and the selection
    updateAdapters();

    Adapter *selected = getAdapter(m_adapterSelected_scan);
    if (!selected || selected == m_adapter_scan) return false;
    if (!selected->isValid() || selected->getDevice()->hostMode() == QBluetoothLocalDevice::HostPoweredOff) return false;

    bool btA_was = m_bleAdapter_scan;
    bool btE_was = m_bleEnabled_scan;

    setAdapter_scan(selected);
    checkAdapterDevice_scan();

    if (btA_was != m_bleAdapter_scan || btE_was != m_bleEnabled_scan)
    {
        Q_EMIT bluetoothChanged_scan();
    }

    return true;
}

/* ************************************************************************** */

void AdapterManager::deviceChanged_scan()
{
    // The previous device has been deleted, along with its connections
    if (QBluetoothLocalDevice *dev = getAdapterDevice_scan())
    {
        connect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                this, &AdapterManager::hostModeChanged_scan);
    }

    Q_EMIT adapterChanged_scan();
}

void AdapterManager::hostModeChanged_scan(QBluetoothLocalDevice::HostMode state)
{
    //qDebug() << "AdapterManager::hostModeChanged_scan() host mode now:" << state;

    // A powered off adapter is still available, it can be powered on again
    QBluetoothLocalDevice *dev = getAdapterDevice_scan();

    bool btA_was = m_bleAdapter_scan;
    bool btE_was = m_bleEnabled_scan;

    m_bleAdapter_scan = (dev && dev->isValid());
    m_bleEnabled_scan = (m_bleAdapter_scan && state > QBluetoothLocalDevice::HostPoweredOff);

    if (btA_was != m_bleAdapter_scan || btE_was != m_bleEnabled_scan)
    {
        Q_EMIT bluetoothChanged_scan();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

QBluetoothAddress AdapterManager::getAdapterAddress_sim() const
{
    return m_adapter_sim ? QBluetoothAddress(m_adapter_sim->getAddress()) : QBluetoothAddress();
}

Adapter *AdapterManager::pickAdapter_sim() const
{
    // Most of the time, the simulator and the scanner use the same adapter
    Adapter *adapter = getAdapter(QBluetoothAddress(SettingsManager::getInstance()->getPreferredAdapter_sim()));
    if (adapter && adapter->isValid()) return adapter;

    return pickAdapter_scan();
}

void AdapterManager::updateStatus_sim()
{
    setAdapterStatus_sim(m_adapter_sim ? m_adapter_sim : pickAdapter_sim());

    QBluetoothLocalDevice *dev = m_adapterStatus_sim ? m_adapterStatus_sim->getDevice() : nullptr;

    bool btA_was = m_bleAdapter_sim;
    bool btE_was = m_bleEnabled_sim;

    // A powered off adapter is still available, it can be powered on again
    m_bleAdapter_sim = (dev && m_adapterStatus_sim->isValid());
    m_bleEnabled_sim = (m_bleAdapter_sim && dev->hostMode() > QBluetoothLocalDevice::HostPoweredOff);

    if (btA_was != m_bleAdapter_sim || btE_was != m_bleEnabled_sim)
    {
        Q_EMIT bluetoothChanged_sim();
    }
}

void AdapterManager::setAdapterStatus_sim(Adapter *adapter)
{
    if (m_adapterStatus_sim == adapter) return;

    if (m_adapterStatus_sim)
    {
        disconnect(m_adapterStatus_sim, &Adapter::deviceChanged,
                   this, &AdapterManager::deviceChangedStatus_sim);

        if (QBluetoothLocalDevice *dev = m_adapterStatus_sim->getDevice())
        {
            disconnect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                       this, &AdapterManager::updateStatus_sim);
        }
    }

    m_adapterStatus_sim = adapter;

    if (m_adapterStatus_sim)
    {
        connect(m_adapterStatus_sim, &Adapter::deviceChanged,
                this, &AdapterManager::deviceChangedStatus_sim);

        if (QBluetoothLocalDevice *dev = m_adapterStatus_sim->getDevice())
        {
            connect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                    this, &AdapterManager::updateStatus_sim);
        }
    }
}

bool AdapterManager::enableBluetooth_sim()
{
    updateAdapters();

    if (m_bleAdapter_sim && !m_bleEnabled_sim)
    {
        // Doesn't work on all platforms, the status is updated through the host mode change
        m_adapterStatus_sim->getDevice()->powerOn();
    }

    return hasBluetooth_sim();
}

QBluetoothAddress AdapterManager::acquireAdapter_sim()
{
    releaseAdapter_sim();

    // Refresh the adapters list
    updateAdapters();

    Adapter *adapter = pickAdapter_sim();
    if (!adapter) return QBluetoothAddress();

    m_adapter_sim = adapter;
    m_adapter_sim->setInUse_sim(true);

    // A new device means the adapter has been unplugged, even if it is back already
    connect(m_adapter_sim, &Adapter::deviceChanged,
            this, &AdapterManager::deviceChanged_sim);

    if (QBluetoothLocalDevice *dev = m_adapter_sim->getDevice())
    {
        connect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                this, &AdapterManager::hostModeChanged_sim);
    }

    updateStatus_sim();

    return QBluetoothAddress(m_adapter_sim->getAddress());
}

void AdapterManager::releaseAdapter_sim()
{
    if (!m_adapter_sim) return;

    disconnect(m_adapter_sim, &Adapter::deviceChanged,
               this, &AdapterManager::deviceChanged_sim);

    if (QBluetoothLocalDevice *dev = m_adapter_sim->getDevice())
    {
        disconnect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                   this, &AdapterManager::hostModeChanged_sim);
    }

    m_adapter_sim->setInUse_sim(false);
    m_adapter_sim = nullptr;

    updateStatus_sim();
}

void AdapterManager::checkAdapter_sim()
{
    if (m_adapter_sim && !m_adapter_sim->isValid())
    {
        loseAdapter_sim(false);
    }
}

void AdapterManager::loseAdapter_sim(bool poweredOff)
{
    qWarning() << "AdapterManager::loseAdapter_sim() simulator adapter lost, powered off:" << poweredOff;

    releaseAdapter_sim();
    Q_EMIT adapterLost_sim(poweredOff);
}

/* ************************************************************************** */

void AdapterManager::deviceChanged_sim()
{
    loseAdapter_sim(false);
}

void AdapterManager::hostModeChanged_sim(QBluetoothLocalDevice::HostMode state)
{
    if (state == QBluetoothLocalDevice::HostPoweredOff)
    {
        loseAdapter_sim(true);
    }
}

void AdapterManager::deviceChangedStatus_sim()
{
    // The previous device has been deleted, along with its connections
    if (QBluetoothLocalDevice *dev = m_adapterStatus_sim->getDevice())
    {
        connect(dev, &QBluetoothLocalDevice::hostModeStateChanged,
                this, &AdapterManager::updateStatus_sim, Qt::UniqueConnection);
    }

    updateStatus_sim();
}

/* ************************************************************************** */
/* ************************************************************************** */

void AdapterManager::refreshAdapters()
{
    //qDebug() << "AdapterManager::refreshAdapters()";

    if (!m_blePermission) return;

    bool btA_was = m_bleAdapter_scan;
    bool btE_was = m_bleEnabled_scan;

    updateAdapters();

    setAdapter_scan(pickAdapter_scan());
    checkAdapterDevice_scan();
    checkAdapter_sim();

    if (btA_was != m_bleAdapter_scan || btE_was != m_bleEnabled_scan)
    {
        Q_EMIT bluetoothChanged_scan();
    }
}

void AdapterManager::pollAdapters()
{
    if (!m_blePermission) return;

    QSet <quint64> present;
    const QList <QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
    for (const QBluetoothHostInfo &hi: adaptersList)
    {
        present.insert(hi.address().toUInt64());
    }

    if (present != m_adaptersPresent)
    {
        qDebug() << "AdapterManager::pollAdapters() adapters plugged or unplugged";
        m_adaptersRefreshTimer.start();
    }
}

void AdapterManager::recoverFromDiscoveryError()
{
    //qDebug() << "AdapterManager::recoverFromDiscoveryError()";

    if (!m_blePermission) return;

    updateAdapters();
    checkAdapter_sim();

    Adapter *adapter = pickAdapter_scan();
    if (adapter == m_adapter_scan) return;

    bool btA_was = m_bleAdapter_scan;
    bool btE_was = m_bleEnabled_scan;

    setAdapter_scan(adapter);
    checkAdapterDevice_scan();

    if (btA_was != m_bleAdapter_scan || btE_was != m_bleEnabled_scan)
    {
        Q_EMIT bluetoothChanged_scan();
    }
}

/* ************************************************************************** */
