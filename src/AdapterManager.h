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
#include <QTimer>

#include <QtQml/qqmlregistration.h>

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

class Adapter;
class AdapterManagerBluez;
struct AdaptersWatcherWindows;

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The AdapterManager class
 *
 * Owns the list of Bluetooth adapters, the adapter used for scanning, connections and pairing
 * (the "scan" adapter), and the adapter used by the simulator (the "sim" adapter).
 * Both adapters are kept while plugged in, even if powered off, and replaced by another adapter when unplugged.
 * The preferred adapters (from settings) are only picked up when a scan or the simulator starts,
 * see switchAdapter_scan() and acquireAdapter_sim(), and pickAdapter() for the rules.
 * The sim adapter is held (in use) between acquireAdapter_sim() and releaseAdapter_sim().
 *
 * The scan and sim status are read from the adapters on demand, see notifyStatus().
 * Every known adapter is followed, its device being replaced when re-plugged, see connectAdapter().
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

    // Bluetooth state and permissions /////////////////////////////////////////

    bool m_blePermission = false;       //!< do we have necessary BLE permission(s)?

    /*!
     * \brief Bluetooth status of the scan or simulator adapter, as notified to QML.
     */
    struct Status
    {
        bool adapter = false;
        bool enabled = false;
        bool permission = false;

        bool operator!=(const Status &other) const
        {
            return adapter != other.adapter || enabled != other.enabled || permission != other.permission;
        }
    };

    Status m_statusNotified_scan;       //!< scan status, as last notified
    Status m_statusNotified_sim;        //!< simulator status, as last notified

    /*!
     * \brief Change the permission, without notifying the Bluetooth status, see notifyStatus().
     */
    void setBluetoothPermission(bool perm);

    /*!
     * \brief Apply a granted Bluetooth permission, then pick the scan adapter, see refreshAdapters().
     * \param powerOn: power on the scan adapter if needed, only on user request.
     */
    void permissionGranted(bool powerOn);

    /*!
     * \brief Emit bluetoothChanged_scan() and bluetoothChanged_sim() if their status changed since the last emission.
     *
     * Comparing with the last emission, rather than with the state before a change,
     * lets callers update the permission and the adapters first, then notify once.
     */
    void notifyStatus();

    // Adapters list ///////////////////////////////////////////////////////////

    QList <Adapter *> m_bluetoothAdapters;

    /*!
     * \brief List the Bluetooth adapters available on the system.
     *
     * New adapters are added to the list, plugged in adapters are checked and updated.
     * Unplugged adapters are kept, as they usually reappear.
     * The default status is updated too.
     * Adapters without an address are ignored, they cannot be told apart.
     */
    void updateAdapters();

    /*!
     * \brief Follow a new adapter, for as long as it is known.
     *
     * Host mode changes update the status, and release the simulator adapter once powered off.
     * A new device resets the scan adapter (see adapterChanged_scan()), and releases the simulator adapter.
     * Pairing signals are only forwarded from the scan adapter.
     */
    void connectAdapter(Adapter *adapter);

    /*!
     * \brief Update the default (scan and simulator) status of every known adapter, from settings.
     */
    void updateDefaultAdapters();

    /*!
     * \brief Pick an adapter, for the scanner or the simulator.
     * \param current: the adapter currently used, or nullptr.
     * \param preferred: the preferred adapter address (from settings), or an empty string.
     * \return the preferred adapter if powered on, otherwise the current adapter if plugged in (even if powered off),
     * otherwise the preferred adapter if plugged in, otherwise the first powered on adapter,
     * otherwise the first plugged in adapter, otherwise nullptr.
     */
    Adapter *pickAdapter(Adapter *current, const QString &preferred) const;

    // Scanner adapter /////////////////////////////////////////////////////////

    Adapter *m_adapter_scan = nullptr;              //!< adapter used for scanning, owned by m_bluetoothAdapters

    /*!
     * \brief Why the scan adapter cannot be used, despite its state.
     *
     * Set from discovery errors, cleared by a new scan adapter or device, a host mode change,
     * or a user request, see enableBluetooth_scan(). Avoids a scan / error loop.
     */
    enum class ScanFailure { None, Disabled, Unusable };
    ScanFailure m_scanFailure = ScanFailure::None;

    /*!
     * \brief Change the scan adapter, and update the in use status of every known adapter.
     * \param adapter: the new scan adapter, or nullptr.
     */
    void setAdapter_scan(Adapter *adapter);

    // Simulator adapter ///////////////////////////////////////////////////////

    Adapter *m_adapter_sim = nullptr;               //!< adapter last used by the simulator, owned by m_bluetoothAdapters
    bool m_held_sim = false;                        //!< m_adapter_sim is in use, see acquireAdapter_sim()

    /*!
     * \brief Pick the adapter for the simulator, see pickAdapter().
     *
     * The current adapter is the simulator adapter, or the scan adapter if the simulator has none.
     */
    Adapter *pickAdapter_sim() const;

    /*!
     * \brief Get the adapter reported by the simulator status.
     * \return the simulator adapter while it is held, otherwise the adapter acquireAdapter_sim() would pick.
     */
    Adapter *getAdapterStatus_sim() const;

    /*!
     * \brief Check the simulator adapter, after a refresh.
     *
     * An unplugged adapter is forgotten, the simulator moves to another adapter on its next start.
     * A powered off adapter is kept. In both cases, a held adapter is released, see loseAdapter_sim().
     */
    void checkAdapter_sim();

    /*!
     * \brief Release the simulator adapter if held, and tell the simulator.
     * \param poweredOff: true if the adapter has been powered off, false if it has been unplugged.
     */
    void loseAdapter_sim(bool poweredOff);

    // Plug / unplug detection /////////////////////////////////////////////////

    QTimer m_adaptersRefreshTimer;                  //!< coalesces refreshAdapters() calls from events

    /*!
     * \brief Refresh the adapters list, pick the scan adapter, check the simulator adapter, and notify the status.
     * \param powerOn: power on the scan adapter if needed, only on user request.
     *
     * Triggered through m_adaptersRefreshTimer after an adapter has been plugged or unplugged,
     * after the simulator adapter has been powered off, or after a discovery error.
     * The timer coalesces events, and lets QBluetoothLocalDevice instances process the same events first.
     * The scan adapter is kept while plugged in, even if powered off.
     * Powering on an adapter doesn't work on all platforms.
     */
    void refreshAdapters(bool powerOn = false);

    // Platform adapters watchers //////////////////////////////////////////////

    AdapterManagerBluez *m_bluez = nullptr;         //!< BlueZ adapters watcher and queries, Linux only

    /*!
     * \brief Watch BlueZ for adapters being plugged or unplugged, see AdapterManagerBluez::watchAdapters().
     *
     * Does nothing on other platforms.
     */
    void startAdaptersWatcher_bluez();

    friend struct AdaptersWatcherWindows;
    std::shared_ptr <AdaptersWatcherWindows> m_adaptersWatcher_windows;

    /*!
     * \brief Watch Windows for adapters being plugged or unplugged.
     *
     * Uses a WinRT DeviceWatcher on BluetoothAdapter::GetDeviceSelector(),
     * the same selector QBluetoothLocalDevice::allDevices() enumerates. Does nothing on other platforms.
     */
    void startAdaptersWatcher_windows();

    /*!
     * \brief Stop watching Windows adapters, the callbacks will not reach this object anymore.
     */
    void stopAdaptersWatcher_windows();

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

private:
    AdapterManager(QObject *parent);
    ~AdapterManager();

public:
    static AdapterManager *getInstance();
    static AdapterManager *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    // Bluetooth states and permissions ////////////////////////////////////////

    bool hasBluetoothPermission() const { return m_blePermission; }

    /*!
     * \brief Check if the scan adapter is valid, a powered off adapter is still available.
     */
    bool hasBluetoothAdapter_scan() const;
    bool hasBluetoothEnabled_scan() const;
    bool hasBluetooth_scan() const { return (hasBluetoothEnabled_scan() && m_blePermission); }

    /*!
     * \brief Check if the simulator adapter is valid, see getAdapterStatus_sim().
     */
    bool hasBluetoothAdapter_sim() const;
    bool hasBluetoothEnabled_sim() const;
    bool hasBluetooth_sim() const { return (hasBluetoothEnabled_sim() && m_blePermission); }

    Q_INVOKABLE bool checkBluetoothPermission();

    /*!
     * \brief Request the Bluetooth permission, if not granted already.
     * \param powerOn: also power on the scan adapter once granted, only on user request.
     * \return true if the permission is granted already.
     *
     * The answer also comes through permissionRequestFinished(), synchronously if already granted.
     */
    Q_INVOKABLE bool requestBluetoothPermission(bool powerOn = false);

    /*!
     * \brief Pick the scan adapter, and power it on, see refreshAdapters().
     * \return true if the scan adapter is usable.
     */
    Q_INVOKABLE bool enableBluetooth_scan();

    /*!
     * \brief Power on the simulator adapter, see getAdapterStatus_sim().
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

    /*!
     * \brief Get the adapters list, for QML.
     * \return the adapters, as a QList<QObject *>.
     */
    QVariant getAdapters() const;
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
     * \brief Pick the scan adapter again, when a scan starts, see pickAdapter().
     * \return true if the scan adapter has changed.
     *
     * Switches to the preferred scan adapter if it is powered on. The adapters list is refreshed first.
     */
    bool switchAdapter_scan();

    // Simulator adapter ///////////////////////////////////////////////////////

    /*!
     * \brief Get the device of the simulator adapter, while it is held.
     * \return the device, or nullptr if the simulator holds no adapter.
     *
     * The device is owned by its Adapter, and replaced when the adapter is re-plugged.
     * Do not keep this pointer, see adapterLost_sim().
     */
    QBluetoothLocalDevice *getAdapterDevice_sim() const;

    /*!
     * \brief Get the address of the simulator adapter, while it is held.
     * \return the address, or a null address if the simulator holds no adapter.
     */
    QBluetoothAddress getAdapterAddress_sim() const;

    /*!
     * \brief Pick the adapter for the simulator, and mark it as used by the simulator.
     *
     * The adapter is then available through getAdapterDevice_sim(),
     * no adapter is held if none is known, the system default adapter is then used.
     * See pickAdapter_sim(), the adapter may be powered off.
     * The adapter is kept until releaseAdapter_sim(),
     * or until it is unplugged or powered off (see adapterLost_sim()).
     */
    void acquireAdapter_sim();

    /*!
     * \brief Release the simulator adapter, if held. It stays the simulator adapter for the next start.
     */
    void releaseAdapter_sim();

    // Platform specific / tools ///////////////////////////////////////////////

    /*!
     * \brief Query the pairing status of every device known to BlueZ, see AdapterManagerBluez::queryPairedDevices().
     * \param adapterAddress: only report devices known to this adapter.
     *
     * The result comes through pairedDevicesUpdated_bluez(). Does nothing on other platforms.
     */
    void queryPairedDevices_bluez(const QBluetoothAddress &adapterAddress);
};

/* ************************************************************************** */
#endif // ADAPTER_MANAGER_H
