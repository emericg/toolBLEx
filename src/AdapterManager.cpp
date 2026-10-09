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
#include "AdapterTracker.h"

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

/* ************************************************************************** */

AdapterManager::AdapterManager(QObject *parent) : QObject(parent)
{
    // Adapters plugged / unplugged
    m_adaptersRefreshTimer.setSingleShot(true);
    m_adaptersRefreshTimer.setInterval(250);
    connect(&m_adaptersRefreshTimer, &QTimer::timeout, this, &AdapterManager::refreshAdapters);

    // Scan and simulator adapters, followed when re-plugged or powered on / off
    connect(&m_tracker_scan, &AdapterTracker::deviceChanged, this, &AdapterManager::adapterChanged_scan);
    connect(&m_tracker_scan, &AdapterTracker::hostModeChanged, this, &AdapterManager::hostModeChanged_scan);
    connect(&m_tracker_scan, &AdapterTracker::pairingFinished, this, &AdapterManager::pairingFinished_scan);
    connect(&m_tracker_scan, &AdapterTracker::errorOccurred, this, &AdapterManager::pairingError_scan);
    connect(&m_tracker_sim, &AdapterTracker::deviceChanged, this, &AdapterManager::deviceChanged_sim);
    connect(&m_tracker_sim, &AdapterTracker::hostModeChanged, this, &AdapterManager::hostModeChanged_sim);
    connect(&m_trackerStatus_sim, &AdapterTracker::deviceChanged, this, &AdapterManager::updateStatus_sim);
    connect(&m_trackerStatus_sim, &AdapterTracker::hostModeChanged, this, &AdapterManager::updateStatus_sim);

#if !defined(Q_OS_MACOS) && !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID)
    // macOS and mobile platforms only have their built-in adapter, there is nothing to watch
    if (!startAdaptersWatcher_bluez() && !startAdaptersWatcher_windows())
    {
        // No native adapters watcher, fallback to polling
        m_adaptersPollTimer.setInterval(s_adaptersPollInterval);
        connect(&m_adaptersPollTimer, &QTimer::timeout, this, &AdapterManager::pollAdapters);
        m_adaptersPollTimer.start();
    }
#endif

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

/* ************************************************************************** */

AdapterManager::~AdapterManager()
{
    stopAdaptersWatcher_windows();

    m_tracker_scan.setAdapter(nullptr);
    m_tracker_sim.setAdapter(nullptr);
    m_trackerStatus_sim.setAdapter(nullptr);
    m_adapter_scan = nullptr;
    m_adapter_sim = nullptr;
    m_adapterStatus_sim = nullptr;

    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool AdapterManager::enableBluetooth_scan()
{
    //qDebug() << "AdapterManager::enableBluetooth_scan()";

    powerOnAdapter_scan();
    notifyStatus_scan();

    return hasBluetooth_scan();
}

void AdapterManager::powerOnAdapter_scan()
{
    // List all Bluetooth adapters, then pick the one to use
    updateAdapters();
    setAdapter_scan(pickAdapter_scan());
    checkAdapterDevice_scan();

    if (m_bleAdapter_scan && !m_bleEnabled_scan)
    {
        // Try to activate the adapter // Doesn't work on all platforms...
        // The enabled status is updated through the host mode change
        getAdapterDevice_scan()->powerOn();
    }
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
        permissionGranted();
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
        permissionGranted();
        break;
    case Qt::PermissionStatus::Denied:
    case Qt::PermissionStatus::Undetermined:
        setBluetoothPermission(false);
        notifyStatus();
        break;
    }

    Q_EMIT permissionRequestFinished(m_blePermission);
}

void AdapterManager::permissionGranted()
{
    setBluetoothPermission(true);
    powerOnAdapter_scan();
    notifyStatus();
}

bool AdapterManager::checkBluetoothPermission()
{
    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        if (!m_blePermission) permissionGranted();
        break;
    case Qt::PermissionStatus::Denied:
        setBluetoothPermission(false);
        notifyStatus();
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

        // The Bluetooth status is notified by the callers, once the adapters are updated, see notifyStatus()
    }
}

void AdapterManager::notifyStatus()
{
    notifyStatus_scan();
    notifyStatus_sim();
}

/* ************************************************************************** */

void AdapterManager::applicationStateChanged(Qt::ApplicationState state)
{
    if (state != Qt::ApplicationActive) return;

    // The permission may have been changed from the OS settings while we were in the background
    checkBluetoothPermission();
}

/* ************************************************************************** */

void AdapterManager::discoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        m_bleEnabled_scan = false;
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;

        QTimer::singleShot(s_discoveryErrorRecoveryDelay, this, &AdapterManager::recoverFromDiscoveryError);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;

        QTimer::singleShot(s_discoveryErrorRecoveryDelay, this, &AdapterManager::recoverFromDiscoveryError);
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Platform.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_bleEnabled_scan = false;
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        setBluetoothPermission(false);
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_bleAdapter_scan = false;
        m_bleEnabled_scan = false;
    }

    // The permission may have changed too
    notifyStatus();
}

/* ************************************************************************** */
/* ************************************************************************** */

Adapter *AdapterManager::getAdapter(const QBluetoothAddress &address) const
{
    if (address.isNull()) return nullptr;

    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (adp->getAddress() == address) return adp;
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
        // Adapters are identified by address, see getAdapter()
        if (hi.address().isNull())
        {
            qWarning() << "> Bluetooth adapter" << hi.name() << "ignored, it has no address";
            continue;
        }

        m_adaptersPresent.insert(hi.address().toUInt64());
    }

    bool adaptersAdded = false;
    for (const QBluetoothHostInfo &hi: std::as_const(adaptersList))
    {
        if (hi.address().isNull()) continue;

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
            adaptersAdded = true;
        }
    }

    // Unplugged adapters are kept, as they usually reappear
    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (!m_adaptersPresent.contains(adp->getAddress().toUInt64()))
            {
                adp->setAvailable(false);
            }
        }
    }

    updateDefaultAdapters();
    updateAdapterSelected_scan();
    updateStatus_sim();

    if (adaptersAdded) Q_EMIT adaptersListUpdated();
}

void AdapterManager::updateDefaultAdapters()
{
    const QBluetoothAddress preferredAdapter_scan(SettingsManager::getInstance()->getPreferredAdapter_scan());
    const QBluetoothAddress preferredAdapter_sim(SettingsManager::getInstance()->getPreferredAdapter_sim());

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
    return m_adapter_scan ? m_adapter_scan->getAddress() : QBluetoothAddress();
}

void AdapterManager::updateAdapterSelected_scan()
{
    // Preferred adapter, if known (even if unplugged)
    const QString preferredAdapter = SettingsManager::getInstance()->getPreferredAdapter_scan();
    if (Adapter *preferred = getAdapter(QBluetoothAddress(preferredAdapter)))
    {
        m_adapterSelected_scan = preferred->getAddress();
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
                m_adapterSelected_scan = adp->getAddress();
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
    if (selected && selected->isPoweredOn()) return selected;

    Adapter *fallback = (selected && selected->isValid()) ? selected : nullptr;
    for (auto *obj: std::as_const(m_bluetoothAdapters))
    {
        if (auto *adp = qobject_cast<Adapter *>(obj))
        {
            if (adp->isPoweredOn()) return adp;
            if (!fallback && adp->isValid()) fallback = adp;
        }
    }

    return fallback;
}

void AdapterManager::setAdapter_scan(Adapter *adapter)
{
    if (m_adapter_scan == adapter) return;

    m_adapter_scan = adapter;
    m_tracker_scan.setAdapter(adapter);

    if (m_adapter_scan) qDebug() << "AdapterManager::setAdapter_scan()" << m_adapter_scan->getAddress();

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

void AdapterManager::updateStatus_scan()
{
    checkAdapterDevice_scan();
    notifyStatus_scan();
}

void AdapterManager::notifyStatus_scan()
{
    if (m_bleAdapterNotified_scan == m_bleAdapter_scan &&
        m_bleEnabledNotified_scan == m_bleEnabled_scan &&
        m_blePermissionNotified_scan == m_blePermission) return;

    m_bleAdapterNotified_scan = m_bleAdapter_scan;
    m_bleEnabledNotified_scan = m_bleEnabled_scan;
    m_blePermissionNotified_scan = m_blePermission;

    Q_EMIT bluetoothChanged_scan();
}

bool AdapterManager::switchAdapter_scan()
{
    // Refresh the adapters list and the selection
    updateAdapters();

    Adapter *selected = getAdapter(m_adapterSelected_scan);
    if (!selected || selected == m_adapter_scan) return false;
    if (!selected->isPoweredOn()) return false;

    setAdapter_scan(selected);
    updateStatus_scan();

    return true;
}

/* ************************************************************************** */

void AdapterManager::hostModeChanged_scan(QBluetoothLocalDevice::HostMode state)
{
    //qDebug() << "AdapterManager::hostModeChanged_scan() host mode now:" << state;

    // A powered off adapter is still available, it can be powered on again
    QBluetoothLocalDevice *dev = getAdapterDevice_scan();

    m_bleAdapter_scan = (dev && dev->isValid());
    m_bleEnabled_scan = (m_bleAdapter_scan && state > QBluetoothLocalDevice::HostPoweredOff);

    notifyStatus_scan();
}

/* ************************************************************************** */
/* ************************************************************************** */

QBluetoothAddress AdapterManager::getAdapterAddress_sim() const
{
    return m_adapter_sim ? m_adapter_sim->getAddress() : QBluetoothAddress();
}

Adapter *AdapterManager::pickAdapter_sim() const
{
    // Most of the time, the simulator and the scanner use the same adapter
    Adapter *preferred = getAdapter(QBluetoothAddress(SettingsManager::getInstance()->getPreferredAdapter_sim()));
    if (preferred && preferred->isPoweredOn()) return preferred;

    Adapter *adapter = pickAdapter_scan();
    if (adapter && adapter->isPoweredOn()) return adapter;

    return (preferred && preferred->isValid()) ? preferred : adapter;
}

void AdapterManager::checkAdapterDevice_sim()
{
    // A powered off adapter is still available, it can be powered on again
    m_bleAdapter_sim = (m_adapterStatus_sim && m_adapterStatus_sim->isValid());
    m_bleEnabled_sim = (m_adapterStatus_sim && m_adapterStatus_sim->isPoweredOn());
}

void AdapterManager::updateStatus_sim()
{
    m_adapterStatus_sim = m_adapter_sim ? m_adapter_sim : pickAdapter_sim();
    m_trackerStatus_sim.setAdapter(m_adapterStatus_sim);

    checkAdapterDevice_sim();
    notifyStatus_sim();
}

void AdapterManager::notifyStatus_sim()
{
    if (m_bleAdapterNotified_sim == m_bleAdapter_sim &&
        m_bleEnabledNotified_sim == m_bleEnabled_sim &&
        m_blePermissionNotified_sim == m_blePermission) return;

    m_bleAdapterNotified_sim = m_bleAdapter_sim;
    m_bleEnabledNotified_sim = m_bleEnabled_sim;
    m_blePermissionNotified_sim = m_blePermission;

    Q_EMIT bluetoothChanged_sim();
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
    m_tracker_sim.setAdapter(adapter);

    updateStatus_sim();

    return m_adapter_sim->getAddress();
}

void AdapterManager::releaseAdapter_sim()
{
    if (!m_adapter_sim) return;

    m_tracker_sim.setAdapter(nullptr);
    m_adapter_sim->setInUse_sim(false);
    m_adapter_sim = nullptr;

    updateStatus_sim();
}

void AdapterManager::checkAdapter_sim()
{
    if (!m_adapter_sim) return;

    if (!m_adapter_sim->isValid())
    {
        loseAdapter_sim(false);
    }
    else if (!m_adapter_sim->isPoweredOn())
    {
        loseAdapter_sim(true);
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
    // A new device means the adapter has been unplugged, even if it is back already
    loseAdapter_sim(false);
}

void AdapterManager::hostModeChanged_sim(QBluetoothLocalDevice::HostMode state)
{
    if (state == QBluetoothLocalDevice::HostPoweredOff)
    {
        // An unplugged adapter is usually reported as powered off first,
        // the refresh tells them apart, see checkAdapter_sim()
        m_adaptersRefreshTimer.start();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void AdapterManager::refreshAdapters()
{
    //qDebug() << "AdapterManager::refreshAdapters()";

    if (!m_blePermission)
    {
        // A running simulator still needs to know about its adapter
        checkAdapter_sim();
        return;
    }

    updateAdapters();

    setAdapter_scan(pickAdapter_scan());
    updateStatus_scan();
    checkAdapter_sim();
}

void AdapterManager::pollAdapters()
{
    if (!m_blePermission) return;

    QSet <quint64> present;
    const QList <QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
    for (const QBluetoothHostInfo &hi: adaptersList)
    {
        if (!hi.address().isNull()) present.insert(hi.address().toUInt64());
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

    setAdapter_scan(adapter);
    updateStatus_scan();
}

/* ************************************************************************** */
