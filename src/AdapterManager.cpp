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

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include "AdapterManager_bluez.h"
#endif

#include <QCoreApplication>
#include <QGuiApplication>
#include <QJSEngine>
#include <QPermissions>
#include <QSet>
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
    connect(&m_adaptersRefreshTimer, &QTimer::timeout, this, [this]() { refreshAdapters(); });

    // Nothing to watch on macOS and mobile platforms, they only have their built-in adapter
    startAdaptersWatcher_bluez();
    startAdaptersWatcher_windows();

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

    // BLE permission initial check, the scan adapter is not powered on without user request
    requestBluetoothPermission();
}

/* ************************************************************************** */

AdapterManager::~AdapterManager()
{
    stopAdaptersWatcher_windows();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool AdapterManager::enableBluetooth_scan()
{
    //qDebug() << "AdapterManager::enableBluetooth_scan()";

    // The user tries again
    m_scanFailure = ScanFailure::None;
    refreshAdapters(true);

    return hasBluetooth_scan();
}

/* ************************************************************************** */

bool AdapterManager::requestBluetoothPermission(bool powerOn)
{
    //qDebug() << "AdapterManager::requestBluetoothPermission()";

    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        permissionGranted(powerOn);
        Q_EMIT permissionRequestFinished(true);
        break;
    case Qt::PermissionStatus::Denied:
    case Qt::PermissionStatus::Undetermined:
        qDebug() << "Requesting BLUETOOTH permission...";
        qApp->requestPermission(bluetoothPermission, this, [this, powerOn](const QPermission &permission) {
            if (permission.status() == Qt::PermissionStatus::Granted)
            {
                permissionGranted(powerOn);
            }
            else
            {
                setBluetoothPermission(false);
                notifyStatus();
            }

            Q_EMIT permissionRequestFinished(m_blePermission);
        });
        break;
    }

    return m_blePermission;
}

void AdapterManager::permissionGranted(bool powerOn)
{
    setBluetoothPermission(true);
    refreshAdapters(powerOn);
}

bool AdapterManager::checkBluetoothPermission()
{
    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        if (!m_blePermission) permissionGranted(false);
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

/* ************************************************************************** */

void AdapterManager::notifyStatus()
{
    const Status scan { hasBluetoothAdapter_scan(), hasBluetoothEnabled_scan(), m_blePermission };
    if (scan != m_statusNotified_scan)
    {
        m_statusNotified_scan = scan;
        Q_EMIT bluetoothChanged_scan();
    }

    const Status sim { hasBluetoothAdapter_sim(), hasBluetoothEnabled_sim(), m_blePermission };
    if (sim != m_statusNotified_sim)
    {
        m_statusNotified_sim = sim;
        Q_EMIT bluetoothChanged_sim();
    }
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

        m_scanFailure = ScanFailure::Disabled;
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        // Switch to another adapter if this one has been unplugged
        m_scanFailure = ScanFailure::Unusable;
        m_adaptersRefreshTimer.start();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        // Switch to another adapter if this one has been unplugged
        m_scanFailure = ScanFailure::Unusable;
        m_adaptersRefreshTimer.start();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Platform.";

        m_scanFailure = ScanFailure::Unusable;
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_scanFailure = ScanFailure::Disabled;
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        setBluetoothPermission(false);
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_scanFailure = ScanFailure::Unusable;
    }

    notifyStatus();
}

/* ************************************************************************** */
/* ************************************************************************** */

QVariant AdapterManager::getAdapters() const
{
    return QVariant::fromValue(QList <QObject *>(m_bluetoothAdapters.cbegin(), m_bluetoothAdapters.cend()));
}

Adapter *AdapterManager::getAdapter(const QBluetoothAddress &address) const
{
    if (address.isNull()) return nullptr;

    for (Adapter *adp: std::as_const(m_bluetoothAdapters))
    {
        if (adp->getAddress() == address) return adp;
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

    QSet <quint64> adaptersPresent;
    bool adaptersAdded = false;
    for (const QBluetoothHostInfo &hi: adaptersList)
    {
        // Adapters are identified by address, see getAdapter()
        if (hi.address().isNull())
        {
            qWarning() << "> Bluetooth adapter" << hi.name() << "ignored, it has no address";
            continue;
        }

        adaptersPresent.insert(hi.address().toUInt64());

        Adapter *adapter = getAdapter(hi.address());
        if (adapter)
        {
            if (adapter->isAvailable()) adapter->checkAdapter();
            else adapter->setAvailable(true); // re-plugged, gets a new device
        }
        else
        {
            adapter = new Adapter(hi, this);
            connectAdapter(adapter);

            m_bluetoothAdapters.push_back(adapter);
            adaptersAdded = true;
        }
    }

    // Unplugged adapters are kept, as they usually reappear
    for (Adapter *adp: std::as_const(m_bluetoothAdapters))
    {
        if (!adaptersPresent.contains(adp->getAddress().toUInt64()))
        {
            adp->setAvailable(false);
        }
    }

    updateDefaultAdapters();

    if (adaptersAdded) Q_EMIT adaptersListUpdated();
}

void AdapterManager::connectAdapter(Adapter *adapter)
{
    connect(adapter, &Adapter::deviceChanged, this, [this, adapter]() {
        if (adapter == m_adapter_scan)
        {
            m_scanFailure = ScanFailure::None;
            Q_EMIT adapterChanged_scan();
        }

        // A new device means the adapter has been unplugged, even if it is back already
        if (adapter == m_adapter_sim) loseAdapter_sim(false);
    });

    connect(adapter, &Adapter::hostModeChanged, this, [this, adapter](QBluetoothLocalDevice::HostMode state) {
        if (adapter == m_adapter_scan) m_scanFailure = ScanFailure::None;

        // An unplugged adapter is usually reported as powered off first,
        // the refresh tells them apart, see checkAdapter_sim()
        if (m_held_sim && adapter == m_adapter_sim && state == QBluetoothLocalDevice::HostPoweredOff)
        {
            m_adaptersRefreshTimer.start();
        }

        notifyStatus();
    });

    connect(adapter, &Adapter::pairingFinished, this,
            [this, adapter](const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing) {
        if (adapter == m_adapter_scan) Q_EMIT pairingFinished_scan(address, pairing);
    });

    connect(adapter, &Adapter::errorOccurred, this, [this, adapter](QBluetoothLocalDevice::Error error) {
        if (adapter == m_adapter_scan) Q_EMIT pairingError_scan(error);
    });
}

void AdapterManager::updateDefaultAdapters()
{
    const QBluetoothAddress preferredAdapter_scan(SettingsManager::getInstance()->getPreferredAdapter_scan());
    const QBluetoothAddress preferredAdapter_sim(SettingsManager::getInstance()->getPreferredAdapter_sim());

    for (Adapter *adp: std::as_const(m_bluetoothAdapters))
    {
        adp->setDefault_scan(adp->getAddress() == preferredAdapter_scan);
        adp->setDefault_sim(adp->getAddress() == preferredAdapter_sim);
    }
}

void AdapterManager::preferredAdapterChanged()
{
    updateDefaultAdapters();
    notifyStatus();
}

Adapter *AdapterManager::pickAdapter(Adapter *current, const QString &preferred) const
{
    Adapter *pref = getAdapter(QBluetoothAddress(preferred));
    if (pref && pref->isPoweredOn()) return pref;

    // A powered off adapter is kept, it can be powered on again
    if (current && current->isValid()) return current;
    if (pref && pref->isValid()) return pref;

    Adapter *fallback = nullptr;
    for (Adapter *adp: std::as_const(m_bluetoothAdapters))
    {
        if (adp->isPoweredOn()) return adp;
        if (!fallback && adp->isValid()) fallback = adp;
    }

    return fallback;
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

bool AdapterManager::hasBluetoothAdapter_scan() const
{
    return (m_adapter_scan && m_adapter_scan->isValid() && m_scanFailure != ScanFailure::Unusable);
}

bool AdapterManager::hasBluetoothEnabled_scan() const
{
    return (hasBluetoothAdapter_scan() && m_adapter_scan->isPoweredOn() && m_scanFailure == ScanFailure::None);
}

void AdapterManager::setAdapter_scan(Adapter *adapter)
{
    if (m_adapter_scan == adapter) return;

    m_adapter_scan = adapter;
    m_scanFailure = ScanFailure::None;

    if (m_adapter_scan) qDebug() << "AdapterManager::setAdapter_scan()" << m_adapter_scan->getAddress();

    for (Adapter *adp: std::as_const(m_bluetoothAdapters))
    {
        adp->setInUse_scan(adp == m_adapter_scan);
    }

    Q_EMIT adapterChanged_scan();
}

bool AdapterManager::switchAdapter_scan()
{
    updateAdapters();

    Adapter *adapter = pickAdapter(m_adapter_scan, SettingsManager::getInstance()->getPreferredAdapter_scan());
    const bool switching = (adapter != m_adapter_scan);
    setAdapter_scan(adapter);

    notifyStatus();

    return switching;
}

/* ************************************************************************** */
/* ************************************************************************** */

QBluetoothLocalDevice *AdapterManager::getAdapterDevice_sim() const
{
    return m_held_sim ? m_adapter_sim->getDevice() : nullptr;
}

QBluetoothAddress AdapterManager::getAdapterAddress_sim() const
{
    return m_held_sim ? m_adapter_sim->getAddress() : QBluetoothAddress();
}

Adapter *AdapterManager::pickAdapter_sim() const
{
    // Most of the time, the simulator and the scanner use the same adapter
    Adapter *current = (m_adapter_sim && m_adapter_sim->isValid()) ? m_adapter_sim : m_adapter_scan;
    return pickAdapter(current, SettingsManager::getInstance()->getPreferredAdapter_sim());
}

Adapter *AdapterManager::getAdapterStatus_sim() const
{
    return m_held_sim ? m_adapter_sim : pickAdapter_sim();
}

bool AdapterManager::hasBluetoothAdapter_sim() const
{
    const Adapter *adapter = getAdapterStatus_sim();
    return (adapter && adapter->isValid());
}

bool AdapterManager::hasBluetoothEnabled_sim() const
{
    const Adapter *adapter = getAdapterStatus_sim();
    return (adapter && adapter->isPoweredOn());
}

bool AdapterManager::enableBluetooth_sim()
{
    updateAdapters();

    Adapter *adapter = getAdapterStatus_sim();
    if (adapter && adapter->isValid() && !adapter->isPoweredOn())
    {
        // Doesn't work on all platforms, the status is updated through the host mode change
        adapter->getDevice()->powerOn();
    }

    notifyStatus();

    return hasBluetooth_sim();
}

void AdapterManager::acquireAdapter_sim()
{
    releaseAdapter_sim();

    // Refresh the adapters list
    updateAdapters();

    m_adapter_sim = pickAdapter_sim();
    if (m_adapter_sim)
    {
        m_held_sim = true;
        m_adapter_sim->setInUse_sim(true);
    }

    notifyStatus();
}

void AdapterManager::releaseAdapter_sim()
{
    if (!m_held_sim) return;

    m_held_sim = false;
    m_adapter_sim->setInUse_sim(false);

    notifyStatus();
}

void AdapterManager::checkAdapter_sim()
{
    if (!m_adapter_sim) return;

    if (!m_adapter_sim->isValid())
    {
        loseAdapter_sim(false);
        m_adapter_sim = nullptr;
    }
    else if (!m_adapter_sim->isPoweredOn())
    {
        loseAdapter_sim(true);
    }
}

void AdapterManager::loseAdapter_sim(bool poweredOff)
{
    if (!m_held_sim) return;

    qWarning() << "AdapterManager::loseAdapter_sim() simulator adapter lost, powered off:" << poweredOff;

    releaseAdapter_sim();
    Q_EMIT adapterLost_sim(poweredOff);
}

/* ************************************************************************** */
/* ************************************************************************** */

void AdapterManager::refreshAdapters(bool powerOn)
{
    //qDebug() << "AdapterManager::refreshAdapters()";

    if (m_blePermission)
    {
        updateAdapters();

        // The scan adapter is kept while plugged in, the preferred one is picked up by switchAdapter_scan()
        if (!m_adapter_scan || !m_adapter_scan->isValid())
        {
            setAdapter_scan(pickAdapter(nullptr, SettingsManager::getInstance()->getPreferredAdapter_scan()));
        }

        if (powerOn && m_adapter_scan && m_adapter_scan->isValid() && !m_adapter_scan->isPoweredOn())
        {
            // Doesn't work on all platforms, the status is updated through the host mode change
            m_adapter_scan->getDevice()->powerOn();
        }
    }

    // A running simulator still needs to know about its adapter
    checkAdapter_sim();
    notifyStatus();
}

/* ************************************************************************** */

void AdapterManager::startAdaptersWatcher_bluez()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    m_bluez = new AdapterManagerBluez(this);
    connect(m_bluez, &AdapterManagerBluez::adaptersChanged, this, [this]() { m_adaptersRefreshTimer.start(); });
    connect(m_bluez, &AdapterManagerBluez::pairedDevicesUpdated, this, &AdapterManager::pairedDevicesUpdated_bluez);

    m_bluez->watchAdapters();
#endif
}

void AdapterManager::queryPairedDevices_bluez(const QBluetoothAddress &adapterAddress)
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    if (m_bluez) m_bluez->queryPairedDevices(adapterAddress);
#else
    Q_UNUSED(adapterAddress)
#endif
}

/* ************************************************************************** */
