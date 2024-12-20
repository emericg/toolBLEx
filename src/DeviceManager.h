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
#include <QTimer>

#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

class QBluetoothDeviceInfo;
class QLowEnergyController;

/* ************************************************************************** */

/*!
 * \brief The DeviceManager class
 */
class DeviceManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool hasAdapters READ areAdaptersAvailable NOTIFY adaptersListUpdated)
    Q_PROPERTY(QVariant adaptersList READ getAdapters NOTIFY adaptersListUpdated)
    Q_PROPERTY(int adaptersCount READ getAdaptersCount NOTIFY adaptersListUpdated)

    Q_PROPERTY(bool hasDevices READ areDevicesAvailable NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceCount READ getDeviceCount NOTIFY devicesListUpdated)
    Q_PROPERTY(DeviceHeader *deviceHeader READ getDeviceHeader NOTIFY deviceHeaderUpdated)
    Q_PROPERTY(DeviceFilter *devicesList READ getDevicesFiltered NOTIFY devicesListUpdated)

    Q_PROPERTY(int deviceSeenCached READ getDeviceSeenCached NOTIFY devicesSeenCacheUpdated)

    Q_PROPERTY(int deviceStructureCached READ getDeviceStructureCached NOTIFY devicesStructureCacheUpdated)

    ////////

    Q_PROPERTY(bool advertising READ isAdvertising NOTIFY advertisingChanged)
    Q_PROPERTY(bool listening READ isListening NOTIFY listeningChanged)
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool scanningPaused READ isScanningPaused NOTIFY scanningChanged)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY updatingChanged)
    Q_PROPERTY(bool syncing READ isSyncing NOTIFY syncingChanged)

    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothAdapter READ hasBluetoothAdapter NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothEnabled READ hasBluetoothEnabled NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothPermissions READ hasBluetoothPermissions NOTIFY bluetoothChanged)

    Q_PROPERTY(bool permissionOS READ hasPermissionOS NOTIFY permissionsChanged)
    Q_PROPERTY(bool permissionLocationBLE READ hasPermissionLocationBLE NOTIFY permissionsChanged)
    Q_PROPERTY(bool permissionLocationBackground READ hasPermissionLocationBackground NOTIFY permissionsChanged)
    Q_PROPERTY(bool permissionLocationGPS READ hasPermissionGPS NOTIFY permissionsChanged)

    Q_PROPERTY(int bluetoothHostMode READ getBluetoothHostMode NOTIFY hostModeChanged)

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

    bool m_daemonMode = false;  //!< did we start without UI?

    bool m_bleAdapter = false;      //!< do we have a BLE adapter?
    bool m_bleEnabled = false;      //!< is the BLE adapter enabled?
    bool m_blePermissions = false;  //!< do we have necessary BLE permissions? (brings together all other permsissions)

    bool m_permOS = false;          //!< do we have OS permissions for BLE? (macOS, iOS, Android)
    bool m_permLocationBLE = false; //!< do we location permission? (Android)
    bool m_permLocationBKG = false; //!< do we background location permission? (Android)
    bool m_permGPS = false;         //!< is the GPS enabled? (Android)

    QBluetoothLocalDevice *m_bluetoothAdapter = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent = nullptr;
    QBluetoothLocalDevice::HostMode m_ble_hostmode = QBluetoothLocalDevice::HostPoweredOff;

    QList <QObject *> m_bluetoothAdapters;

    QList <QString> m_devices_blacklist;

    int m_devicesSeenCachedCount = 0;
    int m_devicesStructureCachedCount = 0;

    DeviceModel *m_devices_model = nullptr;
    DeviceFilter *m_devices_filter = nullptr;
    DeviceHeader *m_device_header = nullptr;

    bool m_advertising = false;
    bool isAdvertising() const { return m_advertising; }

    bool m_listening = false;
    bool isListening() const { return m_listening; }

    bool m_scanning = false;
    bool isScanning() const { return m_scanning; }

    bool m_scanning_paused = false;
    bool isScanningPaused() const { return m_scanning_paused; }

    bool m_updating = false;
    bool isUpdating() const { return m_updating; }

    bool m_syncing = false;
    bool isSyncing() const { return m_syncing; }

    bool hasBluetooth() const { return (m_bleAdapter && m_bleEnabled && m_blePermissions); }
    bool hasBluetoothAdapter() const { return m_bleAdapter; }
    bool hasBluetoothEnabled() const { return m_bleEnabled; }
    bool hasBluetoothPermissions() const { return m_blePermissions; }

    bool hasPermissionOS() const { return m_permOS; }
    bool hasPermissionLocationBLE() const { return m_permLocationBLE; }
    bool hasPermissionLocationBackground() const { return m_permLocationBKG; }
    bool hasPermissionGPS() const { return m_permGPS; }

    int getBluetoothHostMode() const { return m_ble_hostmode; }

    void startBleAgent();

    void checkBluetoothIOS();
    bool m_checking_ios_ble = false;
    QTimer m_checking_ios_timer;

    QString getOrderByRole() const;
    int getOrderByOrder() const;

    int m_orderBy_role;
    Qt::SortOrder m_orderBy_order;

    QStringList m_colorsAvailable = {
            "HotPink", "White", "Tomato", "Yellow", "Red", "Orange", "Gold", "LimeGreen", "Green",
            "MediumOrchid", "Purple", "YellowGreen", "LightYellow", "MediumVioletRed", "PeachPuff", "DodgerBlue",
            "Indigo", "Ivory", "DeepSkyBlue", "MistyRose", "DarkBlue", "MintCream", "Black", "OrangeRed",
            "PaleGreen", "Gainsboro", "PaleVioletRed", "Lavender", "Cyan", "MidnightBlue", "LightPink",
            "FireBrick", "Crimson", "DarkMagenta", "SteelBlue", "GreenYellow", "Brown", "DarkOrange",
            "Goldenrod", "DarkSeaGreen", "DarkRed", "LavenderBlush", "Violet", "Maroon", "Khaki",
            "WhiteSmoke", "Salmon", "Olive", "Orchid", "Fuchsia", "Pink", "LawnGreen", "Peru",
            "Grey", "Moccasin", "Beige", "Magenta", "DarkOrchid", "LightCyan", "RosyBrown", "GhostWhite",
            "MediumSeaGreen", "LemonChiffon", "Chocolate", "BurlyWood"
    };
    QStringList m_colorsLeft;
    QString getAvailableColor();

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
    void bluetoothChanged();
    void hostModeChanged();
    void permissionsChanged();

    void adaptersListUpdated();

    void deviceHeaderUpdated();
    void devicesListUpdated();
    void devicesSeenCacheUpdated();
    void devicesStructureCacheUpdated();
    void devicesBlacklistUpdated();

    void advertisingChanged();
    void listeningChanged();
    void scanningChanged();
    void updatingChanged();
    void syncingChanged();

    void filteringChanged();

    void statsChanged();

private slots:
    // QBluetoothLocalDevice related
    void bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode);
    void bluetoothStatusChanged();
    void bluetoothPermissionsChanged();

    // QBluetoothDeviceDiscoveryAgent related
    void addBleDevice(const QBluetoothDeviceInfo &info);
    void updateBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);
    void updateBleDevice_simple(const QBluetoothDeviceInfo &info);
    void updateBleDevice_discovery(const QBluetoothDeviceInfo &info);
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);
    void deviceDiscoveryErrorIOS();
    void deviceDiscoveryFinished();
    void deviceDiscoveryStopped();

public:
    DeviceManager(bool daemon = false);
    ~DeviceManager();

    bool isDaemon() const { return m_daemonMode; }

    // Adapters management
    Q_INVOKABLE bool areAdaptersAvailable() const { return m_bluetoothAdapters.size(); }
    QVariant getAdapters() const { return QVariant::fromValue(m_bluetoothAdapters); }
    int getAdaptersCount() const { return m_bluetoothAdapters.size(); }

    // Bluetooth management
    Q_INVOKABLE bool checkBluetooth();
    Q_INVOKABLE bool checkBluetoothPermissions();
    Q_INVOKABLE bool enableBluetooth(bool enforceUserPermissionCheck = false);
    Q_INVOKABLE bool requestBluetoothPermissions();
    void requestBluetoothPermissions_results();

    // Scanning management
    static int getLastRun();

    Q_INVOKABLE void advertise_start();
    Q_INVOKABLE void advertise_stop();

    Q_INVOKABLE void scanDevices_start();
    Q_INVOKABLE void scanDevices_stop();

    Q_INVOKABLE void scanDevices_pause();
    Q_INVOKABLE void scanDevices_resume();

    Q_INVOKABLE void checkPaired();

    Q_INVOKABLE void clearResults();

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

    void blacklistDevice(const QString &addr);
    void whitelistDevice(const QString &addr);
    bool isDeviceBlacklisted(const QString &addr);

    // Devices list management
    Q_INVOKABLE bool areDevicesAvailable() const { return m_devices_model->hasDevices(); }
    Q_INVOKABLE bool areDevicesConnected() const;
    Q_INVOKABLE void disconnectDevices() const;

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
    Q_INVOKABLE void getRssiGraphAxis(QDateTimeAxis *axis);
    Q_INVOKABLE void getRssiGraphData(QLineSeries *serie, int index);
};

/* ************************************************************************** */
#endif // DEVICE_MANAGER_H
