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

    // BLE permission initial check // will call enableBluetooth();
    requestBluetoothPermission();
}

AdapterManager::~AdapterManager()
{
    stopAdaptersWatcher_windows();

    m_adapter_scan = nullptr;

    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool AdapterManager::checkBluetooth()
{
    //qDebug() << "AdapterManager::checkBluetooth()";

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermission;

    // Check permissions
    checkBluetoothPermission();

    // Check adapters (re-plugged adapters get a new device)
    checkAdapters();

    // Check scan adapter availability
    checkAdapterDevice_scan();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermission)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();

        // let's see if we can turn on the adapter now
        enableBluetooth();
    }

    return (m_bleAdapter && m_bleEnabled && m_blePermission);
}

bool AdapterManager::enableBluetooth()
{
    //qDebug() << "AdapterManager::enableBluetooth()";

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermission;

    // List all Bluetooth adapters, then pick the one to use
    updateAdapters();
    setAdapter_scan(pickAdapter_scan());

    // Check scan adapter availability
    QBluetoothLocalDevice *dev = getAdapterDevice_scan();
    if (dev && dev->isValid())
    {
        m_bleAdapter = true;

        if (dev->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            // Is already activated
            m_bleEnabled = true;
        }
        else
        {
            // Try to activate the adapter // Doesn't work on all platforms...
            dev->powerOn();
        }
    }
    else
    {
        qWarning() << "AdapterManager::enableBluetooth() we have an invalid adapter";
        m_bleAdapter = false;
        m_bleEnabled = false;
    }

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermission)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return (m_bleAdapter && m_bleEnabled && m_blePermission);
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
        enableBluetooth();
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
        enableBluetooth();
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
        Q_EMIT bluetoothChanged();

        if (m_blePermission) enableBluetooth();
    }
}

/* ************************************************************************** */

void AdapterManager::discoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        if (m_bleEnabled)
        {
            m_bleEnabled = false;
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();

        QTimer::singleShot(s_discoveryErrorRecoveryDelay, this, &AdapterManager::recoverFromDiscoveryError);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        m_bleAdapter = false;

        if (m_bleEnabled)
        {
            m_bleEnabled = false;
            Q_EMIT bluetoothChanged();
        }

        QTimer::singleShot(s_discoveryErrorRecoveryDelay, this, &AdapterManager::recoverFromDiscoveryError);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Platform.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";

        m_bleEnabled = false;
        m_blePermission = false;
        Q_EMIT bluetoothChanged();
        Q_EMIT permissionChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_bleEnabled = false;
        m_blePermission = false;
        Q_EMIT bluetoothChanged();
        Q_EMIT permissionChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        m_bleEnabled = false;
        m_blePermission = false;
        Q_EMIT bluetoothChanged();
        Q_EMIT permissionChanged();
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
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

    Q_EMIT adapterChanged_scan();
}

void AdapterManager::checkAdapterDevice_scan()
{
    QBluetoothLocalDevice *dev = getAdapterDevice_scan();
    if (dev && dev->isValid())
    {
        m_bleAdapter = true;

        if (dev->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            m_bleEnabled = true;
        }
        else
        {
            m_bleEnabled = false;
            qWarning() << "Bluetooth adapter host mode:" << dev->hostMode();
        }
    }
    else
    {
        m_bleAdapter = false;
        m_bleEnabled = false;
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

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;

    setAdapter_scan(selected);
    checkAdapterDevice_scan();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled)
    {
        Q_EMIT bluetoothChanged();
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

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;

    m_bleAdapter = (dev && dev->isValid());
    m_bleEnabled = (m_bleAdapter && state > QBluetoothLocalDevice::HostPoweredOff);

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled)
    {
        Q_EMIT bluetoothChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

QBluetoothAddress AdapterManager::getAdapterAddress_sim() const
{
    return m_adapter_sim ? QBluetoothAddress(m_adapter_sim->getAddress()) : QBluetoothAddress();
}

QBluetoothAddress AdapterManager::acquireAdapter_sim()
{
    releaseAdapter_sim();

    // Refresh the adapters list
    updateAdapters();

    // Most of the time, the simulator and the scanner use the same adapter
    Adapter *adapter = getAdapter(QBluetoothAddress(SettingsManager::getInstance()->getPreferredAdapter_sim()));
    if (!adapter || !adapter->isValid()) adapter = pickAdapter_scan();
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

/* ************************************************************************** */
/* ************************************************************************** */

void AdapterManager::refreshAdapters()
{
    //qDebug() << "AdapterManager::refreshAdapters()";

    if (!m_blePermission) return;

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;

    updateAdapters();

    setAdapter_scan(pickAdapter_scan());
    checkAdapterDevice_scan();
    checkAdapter_sim();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled)
    {
        Q_EMIT bluetoothChanged();
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

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;

    setAdapter_scan(adapter);
    checkAdapterDevice_scan();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled)
    {
        Q_EMIT bluetoothChanged();
    }
}

/* ************************************************************************** */
