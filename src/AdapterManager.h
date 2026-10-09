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

#ifndef ADAPTER_MANAGER_H
#define ADAPTER_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QVariant>
#include <QList>
#include <QHash>
#include <QSet>
#include <QTimer>

#include "AdapterTracker.h"

#include <memory>

#include <QtQml/qqmlregistration.h>

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include <QDBusMessage>
#else
typedef QVariant QDBusMessage;
#endif

class Adapter;
struct AdaptersWatcherWindows;
class QPermission;
class QDBusPendingCallWatcher;
class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The AdapterManager class
 *
 * Owns the list of Bluetooth adapters, the adapter used for scanning, connections and pairing
 * (the "scan" adapter), and the adapter used by the simulator (the "sim" adapter).
 * The scan adapter is kept while it is usable, and replaced by another adapter when unplugged.
 * Going back to the selected adapter only happens through switchAdapter_scan().
 * The sim adapter is held between acquireAdapter_sim() and releaseAdapter_sim().
 *
 * The scan and sim status follow the same pattern:
 * checkAdapterDevice_xxx() reads the adapter state, without notifying,
 * notifyStatus_xxx() emits bluetoothChanged_xxx() if the status changed since the last emission,
 * updateStatus_xxx() does both. The adapters in use are followed through AdapterTracker.
 */
class AdapterManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool hasAdapters READ areAdaptersAvailable NOTIFY adaptersListUpdated)
    Q_PROPERTY(QVariant adaptersList READ getAdapters NOTIFY adaptersListUpdated)
    Q_PROPERTY(int adaptersCount READ getAdaptersCount NOTIFY adaptersListUpdated)

    Q_PROPERTY(bool bluetoothPermission READ hasBluetoothPermission NOTIFY permissionChanged)

    Q_PROPERTY(bool bluetooth_scan READ hasBluetooth_scan NOTIFY bluetoothChanged_scan)
    Q_PROPERTY(bool bluetoothAdapter_scan READ hasBluetoothAdapter_scan NOTIFY bluetoothChanged_scan)
    Q_PROPERTY(bool bluetoothEnabled_scan READ hasBluetoothEnabled_scan NOTIFY bluetoothChanged_scan)

    Q_PROPERTY(bool bluetooth_sim READ hasBluetooth_sim NOTIFY bluetoothChanged_sim)
    Q_PROPERTY(bool bluetoothAdapter_sim READ hasBluetoothAdapter_sim NOTIFY bluetoothChanged_sim)
    Q_PROPERTY(bool bluetoothEnabled_sim READ hasBluetoothEnabled_sim NOTIFY bluetoothChanged_sim)

    // Bluetooth state and permissions

    bool m_blePermission = false;       //!< do we have necessary BLE permission(s)?
    bool m_bleAdapter_scan = false;     //!< do we have a scan adapter?
    bool m_bleEnabled_scan = false;     //!< is the scan adapter enabled?
    bool m_bleAdapter_sim = false;      //!< do we have a simulator adapter?
    bool m_bleEnabled_sim = false;      //!< is the simulator adapter enabled?

    bool m_bleAdapterNotified_scan = false;     //!< m_bleAdapter_scan, as last notified
    bool m_bleEnabledNotified_scan = false;     //!< m_bleEnabled_scan, as last notified
    bool m_blePermissionNotified_scan = false;  //!< m_blePermission, as last notified to the scan status
    bool m_bleAdapterNotified_sim = false;      //!< m_bleAdapter_sim, as last notified
    bool m_bleEnabledNotified_sim = false;      //!< m_bleEnabled_sim, as last notified
    bool m_blePermissionNotified_sim = false;   //!< m_blePermission, as last notified to the simulator status

    /*!
     * \brief Change the permission, without notifying the Bluetooth status, see notifyStatus().
     */
    void setBluetoothPermission(bool perm);
    void requestBluetoothPermission_results(const QPermission &permission);

    /*!
     * \brief Apply a granted Bluetooth permission, then pick and power on the scan adapter.
     *
     * bluetoothChanged_scan() is emitted once, if the permission or the scan adapter status changed.
     */
    void permissionGranted();

    /*!
     * \brief Notify the scan and simulator status, see notifyStatus_scan() and notifyStatus_sim().
     */
    void notifyStatus();

    // Adapters list

    QList <QObject *> m_bluetoothAdapters;

    /*!
     * \brief List the Bluetooth adapters available on the system.
     *
     * New adapters are added to the list, plugged in adapters are checked and updated.
     * Unplugged adapters are kept, as they usually reappear.
     * The default status and the selected adapter are updated too.
     * Adapters without an address are ignored, they cannot be told apart.
     */
    void updateAdapters();

    /*!
     * \brief Update the default (scan and simulator) status of every known adapter, from settings.
     */
    void updateDefaultAdapters();

    // Scanner adapter

    QBluetoothAddress m_adapterSelected_scan;       //!< kept while the adapter is unplugged
    Adapter *m_adapter_scan = nullptr;              //!< adapter used for scanning, owned by m_bluetoothAdapters
    AdapterTracker m_tracker_scan;                  //!< follows m_adapter_scan

    /*!
     * \brief Update the selected adapter.
     *
     * The preferred adapter (from settings) if known, even if unplugged,
     * otherwise the current selection if known, otherwise the first valid adapter.
     */
    void updateAdapterSelected_scan();

    /*!
     * \brief Pick the adapter to use.
     * \return the scan adapter if valid, otherwise the first powered on adapter (the selected one first),
     * otherwise the first valid adapter (the selected one first), otherwise nullptr.
     */
    Adapter *pickAdapter_scan() const;

    /*!
     * \brief Change the scan adapter, and update the in use status of every known adapter.
     * \param adapter: the new scan adapter, or nullptr.
     */
    void setAdapter_scan(Adapter *adapter);

    /*!
     * \brief Update the adapter availability and enabled status from the scan adapter device, without notifying.
     */
    void checkAdapterDevice_scan();

    /*!
     * \brief Update the scan status from the scan adapter device, and notify changes.
     *
     * See checkAdapterDevice_scan() and notifyStatus_scan().
     */
    void updateStatus_scan();

    /*!
     * \brief Emit bluetoothChanged_scan() if the scan status changed since the last emission.
     *
     * The scan status is the scan adapter availability, its enabled status, and the permission.
     * Comparing with the last emission, rather than with the state before a change,
     * lets callers update the permission and the scan adapter first, then notify once.
     */
    void notifyStatus_scan();

    /*!
     * \brief Refresh the adapters list, pick the scan adapter, and power it on if needed.
     *
     * Updates the scan adapter availability and enabled status, without notifying, see notifyStatus_scan().
     * Powering on an adapter doesn't work on all platforms.
     */
    void powerOnAdapter_scan();

    // Simulator adapter

    Adapter *m_adapter_sim = nullptr;               //!< adapter used by the simulator, owned by m_bluetoothAdapters
    AdapterTracker m_tracker_sim;                   //!< follows m_adapter_sim
    Adapter *m_adapterStatus_sim = nullptr;         //!< adapter reported by the simulator status, owned by m_bluetoothAdapters
    AdapterTracker m_trackerStatus_sim;             //!< follows m_adapterStatus_sim

    /*!
     * \brief Pick the adapter for the simulator.
     * \return the preferred simulator adapter (from settings) if powered on,
     * otherwise the adapter used for scanning if powered on, see pickAdapter_scan(),
     * otherwise the preferred simulator adapter if plugged in, otherwise the adapter used for scanning.
     */
    Adapter *pickAdapter_sim() const;

    /*!
     * \brief Update the adapter availability and enabled status from the simulator status adapter, without notifying.
     */
    void checkAdapterDevice_sim();

    /*!
     * \brief Update the simulator status, and notify changes.
     *
     * Reports the simulator adapter while it is held, otherwise the adapter acquireAdapter_sim() would pick.
     * See checkAdapterDevice_sim() and notifyStatus_sim().
     */
    void updateStatus_sim();

    /*!
     * \brief Emit bluetoothChanged_sim() if the simulator status changed since the last emission.
     *
     * Same as notifyStatus_scan(), for the simulator adapter availability, its enabled status, and the permission.
     */
    void notifyStatus_sim();

    /*!
     * \brief Release the simulator adapter if it has been unplugged or powered off, and tell the simulator.
     */
    void checkAdapter_sim();

    /*!
     * \brief Release the simulator adapter, and tell the simulator.
     * \param poweredOff: true if the adapter has been powered off, false if it has been unplugged.
     */
    void loseAdapter_sim(bool poweredOff);

    // Plug / unplug detection

    QTimer m_adaptersRefreshTimer;

    /*!
     * \brief Refresh the adapters list and the scan adapter, after an adapter has been plugged or unplugged,
     * or after the simulator adapter has been powered off.
     *
     * Triggered through m_adaptersRefreshTimer, to coalesce events,
     * and to let QBluetoothLocalDevice instances process the same events first.
     */
    void refreshAdapters();

    QTimer m_adaptersPollTimer;
    static const int s_adaptersPollInterval = 5000; //!< adapters polling interval (ms)
    QSet <quint64> m_adaptersPresent;               //!< adapters listed by the last updateAdapters()

    /*!
     * \brief Poll the adapters list, when the native adapters watcher is unavailable.
     *
     * The adapters are only refreshed if the set of plugged in adapters has changed.
     * Not used on macOS and mobile platforms, which only have their built-in adapter.
     */
    void pollAdapters();

    static const int s_discoveryErrorRecoveryDelay = 1000; //!< delay before recovering from a discovery error (ms)

    /*!
     * \brief Switch to another adapter, after the scan adapter failed to scan.
     *
     * Triggered after a delay by discoveryError(), to let the platform notice an unplugged adapter.
     * Nothing changes if the failing adapter is still the one to use,
     * the error state is kept until the user tries again, avoiding a scan / error loop.
     */
    void recoverFromDiscoveryError();

    // Platform adapters watchers

    /*!
     * \brief Watch BlueZ for adapters being plugged or unplugged.
     *
     * Uses org.freedesktop.DBus.ObjectManager InterfacesAdded / InterfacesRemoved signals,
     * filtered on the org.bluez.Adapter1 interface, and the org.bluez service owner (bluetoothd restarts).
     * Does nothing on other platforms.
     * \return true if BlueZ is watched.
     */
    bool startAdaptersWatcher_bluez();

    friend struct AdaptersWatcherWindows;
    std::shared_ptr <AdaptersWatcherWindows> m_adaptersWatcher_windows;

    /*!
     * \brief Watch Windows for adapters being plugged or unplugged.
     *
     * Uses a WinRT DeviceWatcher on BluetoothAdapter::GetDeviceSelector(),
     * the same selector QBluetoothLocalDevice::allDevices() enumerates. Does nothing on other platforms.
     * \return true if Windows adapters are watched.
     */
    bool startAdaptersWatcher_windows();

    /*!
     * \brief Stop watching Windows adapters, the callbacks will not reach this object anymore.
     */
    void stopAdaptersWatcher_windows();

    /*!
     * \brief Parse the queryPairedDevices_bluez() reply, and emit pairedDevicesUpdated_bluez().
     * \param call: the pending GetManagedObjects call, deleted afterwards.
     */
    void pairedDevicesReply_bluez(QDBusPendingCallWatcher *call);

Q_SIGNALS:
    void adaptersListUpdated();
    void permissionChanged();
    void bluetoothChanged_scan();
    void bluetoothChanged_sim();
    void permissionRequestFinished(bool granted);
    void adapterChanged_scan();
    void adapterLost_sim(bool poweredOff);

    /*!
     * \brief Forwarded from the scan adapter device, see QBluetoothLocalDevice::pairingFinished().
     */
    void pairingFinished_scan(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing);

    /*!
     * \brief Forwarded from the scan adapter device, see QBluetoothLocalDevice::errorOccurred().
     *
     * Not only pairing errors, but every device error ends a pending pairing request.
     */
    void pairingError_scan(QBluetoothLocalDevice::Error error);

    /*!
     * \brief Emitted with the result of queryPairedDevices_bluez().
     * \param adapterAddress: the adapter the query was made for.
     * \param paired: the paired devices, by address.
     * Empty if the query failed, or if the adapter is unknown to BlueZ.
     */
    void pairedDevicesUpdated_bluez(const QBluetoothAddress &adapterAddress,
                                    const QHash <quint64, QBluetoothLocalDevice::Pairing> &paired);

private slots:
    /*!
     * \brief Check the Bluetooth permission when the application becomes active.
     * \param state: the new application state.
     *
     * Qt has no notification for permission changes,
     * but changing a permission from the OS settings means leaving the application.
     */
    void applicationStateChanged(Qt::ApplicationState state);

    void preferredAdapterChanged();

    void hostModeChanged_scan(QBluetoothLocalDevice::HostMode state);

    void deviceChanged_sim();
    void hostModeChanged_sim(QBluetoothLocalDevice::HostMode state);

    void interfacesAdded_bluez(const QDBusMessage &msg);
    void interfacesRemoved_bluez(const QDBusMessage &msg);

private:
    AdapterManager(QObject *parent);
    ~AdapterManager();

public:
    static AdapterManager *getInstance();
    static AdapterManager *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    /// Bluetooth states and permissions ///////////////////////////////////////

    bool hasBluetoothPermission() const { return m_blePermission; }

    bool hasBluetoothAdapter_scan() const { return m_bleAdapter_scan; }
    bool hasBluetoothEnabled_scan() const { return m_bleEnabled_scan; }
    bool hasBluetooth_scan() const { return (m_bleAdapter_scan && m_bleEnabled_scan && m_blePermission); }

    bool hasBluetoothAdapter_sim() const { return m_bleAdapter_sim; }
    bool hasBluetoothEnabled_sim() const { return m_bleEnabled_sim; }
    bool hasBluetooth_sim() const { return (m_bleAdapter_sim && m_bleEnabled_sim && m_blePermission); }

    Q_INVOKABLE bool checkBluetoothPermission();
    Q_INVOKABLE bool requestBluetoothPermission();

    Q_INVOKABLE bool enableBluetooth_scan();

    /*!
     * \brief Power on the simulator adapter, see updateStatus_sim().
     * \return true if the simulator adapter is usable.
     *
     * Powering on an adapter doesn't work on all platforms.
     */
    Q_INVOKABLE bool enableBluetooth_sim();

    /*!
     * \brief Update the Bluetooth status from a discovery agent error.
     * \param error: the error reported by the discovery agent.
     */
    void discoveryError(QBluetoothDeviceDiscoveryAgent::Error error);

    // Adapters list ///////////////////////////////////////////////////////////

    bool areAdaptersAvailable() const { return m_bluetoothAdapters.size(); }

    QVariant getAdapters() const { return QVariant::fromValue(m_bluetoothAdapters); }
    int getAdaptersCount() const { return m_bluetoothAdapters.size(); }

    /*!
     * \brief Get an adapter by address.
     * \return the adapter, or nullptr if unknown.
     */
    Adapter *getAdapter(const QBluetoothAddress &address) const;

    // Scanner adapter /////////////////////////////////////////////////////////

    /*!
     * \brief Get the device of the scan adapter.
     * \return the device, or nullptr if there is no scan adapter.
     *
     * The device is owned by its Adapter, and replaced when the adapter is re-plugged.
     * Do not keep this pointer, see adapterChanged_scan().
     */
    QBluetoothLocalDevice *getAdapterDevice_scan() const;

    /*!
     * \brief Get the address of the scan adapter.
     * \return the address, or a null address if there is no scan adapter.
     */
    QBluetoothAddress getAdapterAddress_scan() const;

    /*!
     * \brief Make the selected adapter the scan adapter, if it is plugged in and powered on.
     * \return true if the scan adapter has changed.
     *
     * The adapters list and the selection are refreshed first.
     */
    bool switchAdapter_scan();

    // Simulator adapter ///////////////////////////////////////////////////////

    /*!
     * \brief Get the address of the simulator adapter.
     * \return the address, or a null address if the simulator has no adapter (or uses the system default).
     */
    QBluetoothAddress getAdapterAddress_sim() const;

    /*!
     * \brief Pick the adapter for the simulator, and mark it as used by the simulator.
     * \return the adapter address, or a null address to use the system default adapter.
     *
     * See pickAdapter_sim(), the adapter may be powered off if no other adapter is usable.
     * The adapter is kept until releaseAdapter_sim(),
     * or until it is unplugged or powered off (see adapterLost_sim()).
     */
    QBluetoothAddress acquireAdapter_sim();

    /*!
     * \brief Release the simulator adapter, if any.
     */
    void releaseAdapter_sim();

    // Platform specific / tools ///////////////////////////////////////////////

    /*!
     * \brief Get the pairing status of every device known to BlueZ, using a single D-Bus call.
     * \param adapterAddress: only report devices known to this adapter.
     * \return the paired devices, by address.
     *
     * QBluetoothLocalDevice::pairingStatus() does one D-Bus round trip per device known to BlueZ,
     * for every device queried.
     */
    QHash <quint64, QBluetoothLocalDevice::Pairing> getPairedDevices_bluez(const QBluetoothAddress &adapterAddress) const;
};

/* ************************************************************************** */
#endif // ADAPTER_MANAGER_H
