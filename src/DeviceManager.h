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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H
/* ************************************************************************** */

#include "DeviceFilter.h"
#include "DeviceHeader.h"

#include <QObject>
#include <QVariant>
#include <QList>
#include <QHash>
#include <QTimer>
#include <QPointer>

#include <QtQml/qqmlregistration.h>

#include <QtGraphs/QLineSeries>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

class QBluetoothDeviceInfo;
class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The DeviceManager class
 */
class DeviceManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    ////////

    Q_PROPERTY(bool hasDevices READ areDevicesAvailable NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceCount READ getDeviceCount NOTIFY devicesListUpdated)
    Q_PROPERTY(DeviceHeader *deviceHeader READ getDeviceHeader NOTIFY deviceHeaderUpdated)
    Q_PROPERTY(DeviceFilter *devicesList READ getDevicesFiltered NOTIFY devicesListUpdated)

    Q_PROPERTY(int deviceSeenCached READ getDeviceSeenCached NOTIFY devicesSeenCacheUpdated)

    Q_PROPERTY(int deviceStructureCached READ getDeviceStructureCached NOTIFY devicesStructureCacheUpdated)

    ////////

    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool scanningPaused READ isScanningPaused NOTIFY scanningChanged)

    Q_PROPERTY(QString orderBy_role READ getOrderByRole NOTIFY filteringChanged)
    Q_PROPERTY(int orderBy_order READ getOrderByOrder NOTIFY filteringChanged)

    Q_PROPERTY(int deviceCountTotal READ getDeviceCount NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceCountFound READ getCountFound NOTIFY statsChanged)
    Q_PROPERTY(int deviceCountShown READ getCountShown NOTIFY statsChanged)
    Q_PROPERTY(int deviceCountHidden READ getCountHidden NOTIFY statsChanged)
    Q_PROPERTY(int deviceCountBlacklisted READ getCountBlacklisted NOTIFY devicesBlacklistUpdated)
    Q_PROPERTY(int deviceCountCached READ getCountCached NOTIFY devicesSeenCacheUpdated)
    Q_PROPERTY(int deviceCountClassic READ getCountClassic NOTIFY statsChanged)
    Q_PROPERTY(int deviceCountBLE READ getCountBLE NOTIFY statsChanged)
    Q_PROPERTY(int deviceCountBeacon READ getCountBeacon NOTIFY statsChanged)

    bool m_dbInternal = false;  //!< do we have an internal SQLite database?
    bool m_dbExternal = false;  //!< do we have a remote MySQL database?

    ////

    QBluetoothDeviceDiscoveryAgent *m_bluetoothDiscoveryAgent = nullptr;

    QPointer <QBluetoothLocalDevice> m_adapterDevice;   //!< scan adapter device, its pairing signals are followed

    QHash <quint64, QBluetoothLocalDevice::Pairing> m_devicesPaired; //!< paired devices, by address
    QString m_pairingPendingAddress;

    ////

    QList <QString> m_devices_blacklist;

    int m_devicesSeenCachedCount = 0;
    int m_devicesStructureCachedCount = 0;

    DeviceModel *m_devices_model = nullptr;
    DeviceFilter *m_devices_filter = nullptr;
    DeviceHeader *m_device_header = nullptr;

    ////

    bool m_scanning = false;
    bool isScanning() const { return m_scanning; }

    bool m_scanning_paused = false;
    bool isScanningPaused() const { return m_scanning_paused; }

    bool m_scanPending = false;     //!< scanning has been requested, it starts once Bluetooth is available

    QTimer m_scanPauseTimer;
    static const int s_scanPauseDelay = 3333;   //!< inactivity delay before pausing the scan (ms)

    void startBleAgent();

    /*!
     * \brief Stop scanning, without changing m_scanPending.
     *
     * Used when scanning is interrupted, scanDevices_stop() is the user request.
     */
    void stopScanning();

    /*!
     * \brief Replace the paired devices, and update the pairing status of every device.
     * \param paired: the paired devices, by address.
     */
    void setDevicesPaired(const QHash <quint64, QBluetoothLocalDevice::Pairing> &paired);

    /*!
     * \brief Query the pairing status of every device known to BlueZ, using a single asynchronous D-Bus call.
     * \param adapterAddress: only report devices known to this adapter.
     *
     * Linux only, see DeviceManager_bluez.cpp.
     * QBluetoothLocalDevice::pairingStatus() does one blocking D-Bus round trip per device known to BlueZ,
     * for every device queried. The result goes to setDevicesPaired(), unless the scan adapter changed meanwhile.
     */
    void queryPairedDevices_bluez(const QBluetoothAddress &adapterAddress);

    QString getOrderByRole() const;
    int getOrderByOrder() const;

    int m_orderBy_role = DeviceModel::Default;
    Qt::SortOrder m_orderBy_order = Qt::AscendingOrder;

    QStringList m_colorsAvailable = {
        "HotPink", "Tomato", "Yellow", "Red", "Orange", "Gold", "LimeGreen", "Green",
        "MediumOrchid", "Purple", "YellowGreen", "LightYellow", "MediumVioletRed", "PeachPuff", "DodgerBlue",
        "Indigo", "DeepSkyBlue", "MistyRose", "DarkBlue", "Black", "OrangeRed",
        "PaleGreen", "Gainsboro", "PaleVioletRed", "Lavender", "Cyan", "MidnightBlue", "LightPink",
        "FireBrick", "Crimson", "DarkMagenta", "SteelBlue", "GreenYellow", "Brown", "DarkOrange",
        "Goldenrod", "DarkSeaGreen", "DarkRed", "LavenderBlush", "Violet", "Maroon", "Khaki",
        "Salmon", "Olive", "Orchid", "Fuchsia", "Pink", "LawnGreen", "Peru",
        "Grey", "Moccasin", "Beige", "Magenta", "DarkOrchid", "RosyBrown",
        "MediumSeaGreen", "LemonChiffon", "Chocolate", "BurlyWood"
    };
    QStringList m_colorsAvailable_toolight = { // too light
        "White", "Ivory", "MintCream", "WhiteSmoke", "GhostWhite", "LightCyan",
    };
    QStringList m_colorsAvailable_toodark = { // too dark
    };
    QStringList m_colorsLeft;
    QString getAvailableColor();

    bool getExportFile(QString &filename) const;

    // stats
    void countDevices();
    int m_countFound = 0;               //!< devices that have been detected
    int m_countShown = 0;               //!< devices shown by the UI
    int m_countHidden = 0;              //!< devices hidden by the UI
    int m_countBlacklisted = 0;         //!< devices in the hidden list
    int m_countCached = 0;              //!< devices in the cache list
    int m_countClassic = 0;             //!< Bluetooth Classic devices
    int m_countBLE = 0;                 //!< Bluetooth LE devices
    int m_countBeacon = 0;              //!< Beacon devices

Q_SIGNALS:
    void deviceHeaderUpdated();
    void devicesListUpdated();
    void devicesSeenCacheUpdated();
    void devicesStructureCacheUpdated();
    void devicesBlacklistUpdated();

    void scanningChanged();

    void filteringChanged();

    void statsChanged();

private slots:
    /*!
     * \brief Pause scanning while the application is inactive, and resume it when active again.
     * \param state: the new application state.
     *
     * The scan is only paused after s_scanPauseDelay, short inactive periods are ignored,
     * and only if enabled in the settings, see scanDevices_pause().
     */
    void applicationStateChanged(Qt::ApplicationState state);

    // AdapterManager related
    void bluetoothStatusChanged();
    void adapterChanged_scan();

    // QBluetoothLocalDevice related, from the scan adapter device
    void bluetoothPairingFinished(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing);

    /*!
     * \brief End the pending pairing request, if any.
     * \param error: the scan adapter device error, not only pairing errors.
     */
    void bluetoothPairingError(QBluetoothLocalDevice::Error error);

    // QBluetoothDeviceDiscoveryAgent related
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);
    void deviceDiscoveryFinished();
    void deviceDiscoveryStopped();

    //
    void addBleDevice(const QBluetoothDeviceInfo &info);
    void bleDevice_discovered(const QBluetoothDeviceInfo &info);
    void bleDevice_updated(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);

private:
    DeviceManager(QObject *parent);
    ~DeviceManager();

public:
    static DeviceManager *getInstance();
    static DeviceManager *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    // Scanning management
    Q_INVOKABLE void scanDevices_start();
    Q_INVOKABLE void scanDevices_stop();
    Q_INVOKABLE void scanDevices_restart(bool clear = false);

    Q_INVOKABLE void scanDevices_pause();
    Q_INVOKABLE void scanDevices_resume();

    Q_INVOKABLE void checkPaired();

    /*!
     * \brief Ask the local Bluetooth adapter to change the pairing status of a device.
     * \param address: the remote device MAC address.
     * \param pairing: the requested pairing status.
     * \return false if the request cannot be made (no adapter, invalid address, request pending).
     *
     * Only one request can be pending at a time, the device is notified of the result.
     */
    bool requestPairing(const QString &address, QBluetoothLocalDevice::Pairing pairing);

    Q_INVOKABLE void clearResults();
    Q_INVOKABLE bool exportResults(const QString &filename, int exportMode,
                                   bool withManuf, bool withComment, bool withSeen,
                                   const QString &comment = QString());

    // Device saved
    int getDeviceSeenCached() const { return m_devicesSeenCachedCount; }
    void cacheDeviceSeen(const QString &addr);
    void uncacheDeviceSeen(const QString &addr);
    bool isDeviceSeenCached(const QString &addr);
    Q_INVOKABLE void clearDeviceSeenCache();
    Q_INVOKABLE int countDeviceSeenCached();

    int getDeviceStructureCached() const { return m_devicesStructureCachedCount; }
    Q_INVOKABLE QString getDeviceStructureDirectory() const;
    Q_INVOKABLE void clearDeviceStructureCache();
    Q_INVOKABLE int countDeviceStructureCached();

    Q_INVOKABLE void blacklistBleDevice(const QString &addr);
    Q_INVOKABLE void whitelistBleDevice(const QString &addr);
    Q_INVOKABLE bool isBleDeviceBlacklisted(const QString &addr);

    // Devices list management
    Q_INVOKABLE bool areDevicesAvailable() const { return m_devices_model->hasDevices(); }
    Q_INVOKABLE bool areDevicesConnected() const;
    Q_INVOKABLE void disconnectDevices() const;
    Q_INVOKABLE void disconnectAndExit() const;

    int getDeviceCount() const { return m_devices_model->getDeviceCount(); }
    DeviceFilter *getDevicesFiltered() const { return m_devices_filter; }
    DeviceHeader *getDeviceHeader() const { return m_device_header; }

    // UI stats
    int getCountFound() const { return m_countFound; }
    int getCountShown() const { return m_countShown; }
    int getCountHidden() const { return m_countHidden; }
    int getCountBlacklisted() const { return m_devices_blacklist.count(); }
    int getCountCached() const { return m_devicesSeenCachedCount; }
    int getCountClassic() const { return m_countClassic; }
    int getCountBLE() const { return m_countBLE; }
    int getCountBeacon() const { return m_countBeacon; }

    // Sorting and filtering
    Q_INVOKABLE void orderby_default();
    Q_INVOKABLE void orderby_address();
    Q_INVOKABLE void orderby_name();
    Q_INVOKABLE void orderby_model();
    Q_INVOKABLE void orderby_manufacturer();
    Q_INVOKABLE void orderby_rssi();
    Q_INVOKABLE void orderby_interval();
    Q_INVOKABLE void orderby_firstseen();
    Q_INVOKABLE void orderby_lastseen();
    void orderby(int role, Qt::SortOrder order);

    Q_INVOKABLE void setFilterString(const QString &str);
    Q_INVOKABLE void updateBoolFilters();

    Q_INVOKABLE QVariant getDeviceByProxyIndex(const int index) const {
        QModelIndex proxyIndex = m_devices_filter->index(index, 0);
        return QVariant::fromValue(m_devices_filter->data(proxyIndex, DeviceModel::PointerRole));
    }

    void invalidate();
    void invalidateFilter();

    // RSSI graph

    /*!
     * \brief Fill a line series with the RSSI history of a device.
     * \param serie: The series to fill. Its previous content is replaced.
     * \param index: The device index in the device model.
     * \param refTimeMs: Reference time (ms since epoch) used as x = 0.
     * \param windowMs: Visible time window (ms) before refTimeMs.
     *
     * Points are placed at their age relative to refTimeMs, in (negative) seconds.
     * Only points within the window are kept, plus the last one before it,
     * so the line reaches the left edge of the graph.
     */
    Q_INVOKABLE void getRssiGraphData(QLineSeries *serie, int index, qint64 refTimeMs, qint64 windowMs);
};

/* ************************************************************************** */
#endif // DEVICE_MANAGER_H
