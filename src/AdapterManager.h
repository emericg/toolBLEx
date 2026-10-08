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

#include <memory>

#include <QtQml/qqmlregistration.h>

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include <QDBusMessage>
#else
class QDBusMessage;
#endif

class Adapter;
struct AdaptersWatcherWindows;
class QPermission;
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
 */
class AdapterManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool hasAdapters READ areAdaptersAvailable NOTIFY adaptersListUpdated)
    Q_PROPERTY(QVariant adaptersList READ getAdapters NOTIFY adaptersListUpdated)
    Q_PROPERTY(int adaptersCount READ getAdaptersCount NOTIFY adaptersListUpdated)

    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothAdapter READ hasBluetoothAdapter NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothEnabled READ hasBluetoothEnabled NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothPermission READ hasBluetoothPermission NOTIFY permissionChanged)

    // Bluetooth state and permission

    bool m_bleAdapter = false;      //!< do we have a BLE adapter?
    bool m_bleEnabled = false;      //!< is the BLE adapter enabled?
    bool m_blePermission = false;   //!< do we have necessary BLE permission(s)?

    void setBluetoothPermission(bool perm);
    void requestBluetoothPermission_results(const QPermission &permission);

    // Adapters list

    QList <QObject *> m_bluetoothAdapters;

    Adapter *getAdapter(const QBluetoothAddress &address) const;

    /*!
     * \brief List the Bluetooth adapters available on the system.
     *
     * New adapters are added to the list, plugged in adapters are checked and updated.
     * Unplugged adapters are kept, as they usually reappear.
     * The default status and the selected adapter are updated too.
     */
    void updateAdapters();

    /*!
     * \brief Check every known adapter, and update their default status.
     */
    void checkAdapters();

    /*!
     * \brief Update the default (scan and simulator) status of every known adapter, from settings.
     */
    void updateDefaultAdapters();

    // Scan adapter

    QBluetoothAddress m_adapterSelected_scan;       //!< kept while the adapter is unplugged
    Adapter *m_adapter_scan = nullptr;              //!< adapter used for scanning, owned by m_bluetoothAdapters

    /*!
     * \brief Update the selected adapter.
     *
     * The preferred adapter (from settings) if known, even if unplugged,
     * otherwise the current selection if known, otherwise the first valid adapter.
     */
    void updateAdapterSelected_scan();

    /*!
     * \brief Pick the adapter to use.
     * \return the scan adapter if valid, otherwise the selected adapter if valid,
     * otherwise the first valid adapter, otherwise nullptr.
     */
    Adapter *pickAdapter_scan() const;

    /*!
     * \brief Change the scan adapter, and update the in use status of every known adapter.
     * \param adapter: the new scan adapter, or nullptr.
     */
    void setAdapter_scan(Adapter *adapter);

    /*!
     * \brief Update the adapter availability and enabled status from the scan adapter device.
     */
    void checkAdapterDevice_scan();

    // Sim adapter

    Adapter *m_adapter_sim = nullptr;               //!< adapter used by the simulator, owned by m_bluetoothAdapters

    /*!
     * \brief Release the simulator adapter if it has been unplugged, and tell the simulator.
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
     * \brief Refresh the adapters list and the scan adapter, after an adapter has been plugged or unplugged.
     *
     * Triggered through m_adaptersRefreshTimer, to coalesce events,
     * and to let QBluetoothLocalDevice instances process the same events first.
     */
    void refreshAdapters();

    QTimer m_adaptersPollTimer;
    static const int s_adaptersPollInterval = 5000; //!< adapters polling interval (ms)
    QSet <quint64> m_adaptersPresent;               //!< adapters listed by the last updateAdapters()

    /*!
     * \brief Poll the adapters list, on platforms without a native adapters watcher.
     *
     * The adapters are only refreshed if the set of plugged in adapters has changed.
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
     * filtered on the org.bluez.Adapter1 interface. Does nothing on other platforms.
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

Q_SIGNALS:
    void bluetoothChanged();
    void permissionChanged();

    /*!
     * \brief Emitted after requestBluetoothPermission(), once the permission status is known.
     * \param granted: true if the Bluetooth permission is granted.
     */
    void permissionRequestFinished(bool granted);

    void adaptersListUpdated();

    /*!
     * \brief Emitted when the scan adapter changes, or when its device has been replaced.
     *
     * Users of getAdapterDevice_scan() must drop anything bound to the previous device.
     */
    void adapterChanged_scan();

    /*!
     * \brief Emitted when the simulator adapter has been unplugged or powered off, it has been released.
     * \param poweredOff: true if the adapter has been powered off, false if it has been unplugged.
     */
    void adapterLost_sim(bool poweredOff);

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

    void deviceChanged_scan();
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

    // Bluetooth state and permission

    bool hasBluetoothAdapter() const { return m_bleAdapter; }
    bool hasBluetoothEnabled() const { return m_bleEnabled; }
    bool hasBluetoothPermission() const { return m_blePermission; }
    bool hasBluetooth() const { return (m_bleAdapter && m_bleEnabled && m_blePermission); }

    Q_INVOKABLE bool checkBluetooth();
    Q_INVOKABLE bool enableBluetooth();

    Q_INVOKABLE bool checkBluetoothPermission();
    Q_INVOKABLE bool requestBluetoothPermission();

    /*!
     * \brief Update the Bluetooth status from a discovery agent error.
     * \param error: the error reported by the discovery agent.
     */
    void discoveryError(QBluetoothDeviceDiscoveryAgent::Error error);

    // Adapters list

    Q_INVOKABLE bool areAdaptersAvailable() const { return m_bluetoothAdapters.size(); }

    QVariant getAdapters() const { return QVariant::fromValue(m_bluetoothAdapters); }
    int getAdaptersCount() const { return m_bluetoothAdapters.size(); }

    // Scan adapter

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

    // Sim adapter

    /*!
     * \brief Get the address of the simulator adapter.
     * \return the address, or a null address if the simulator has no adapter (or uses the system default).
     */
    QBluetoothAddress getAdapterAddress_sim() const;

    /*!
     * \brief Pick the adapter for the simulator, and mark it as used by the simulator.
     * \return the adapter address, or a null address to use the system default adapter.
     *
     * The preferred simulator adapter (from settings) if plugged in,
     * otherwise the adapter used for scanning, see pickAdapter_scan().
     * The adapter is kept until releaseAdapter_sim(),
     * or until it is unplugged or powered off (see adapterLost_sim()).
     */
    QBluetoothAddress acquireAdapter_sim();

    /*!
     * \brief Release the simulator adapter, if any.
     */
    void releaseAdapter_sim();

    // Platform specific

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
