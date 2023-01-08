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

#include <QObject>
#include <QVariant>
#include <QList>
#include <QTimer>

#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
QT_FORWARD_DECLARE_CLASS(QBluetoothDeviceInfo)
QT_FORWARD_DECLARE_CLASS(QLowEnergyController)
QT_FORWARD_DECLARE_CLASS(QLowEnergyConnectionParameters)

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
    Q_PROPERTY(DeviceFilter *devicesList READ getDevicesFiltered NOTIFY devicesListUpdated)
    Q_PROPERTY(int deviceCount READ getDeviceCount NOTIFY devicesListUpdated)

    Q_PROPERTY(bool listening READ isListening NOTIFY listeningChanged)
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(bool scanningPaused READ isScanningPaused NOTIFY scanningChanged)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY updatingChanged)
    Q_PROPERTY(bool syncing READ isSyncing NOTIFY syncingChanged)
    Q_PROPERTY(bool advertising READ isAdvertising NOTIFY advertisingChanged)

    Q_PROPERTY(bool bluetooth READ hasBluetooth NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothAdapter READ hasBluetoothAdapter NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothEnabled READ hasBluetoothEnabled NOTIFY bluetoothChanged)
    Q_PROPERTY(bool bluetoothPermissions READ hasBluetoothPermissions NOTIFY bluetoothChanged)
    Q_PROPERTY(int bluetoothHostMode READ getBluetoothHostMode NOTIFY hostModeChanged)

    Q_PROPERTY(QString orderBy_role READ getOrderByRole NOTIFY filteringChanged)
    Q_PROPERTY(int orderBy_order READ getOrderByOrder NOTIFY filteringChanged)

    bool m_dbInternal = false;
    bool m_dbExternal = false;

    bool m_daemonMode = false;

    bool m_btA = false;
    bool m_btE = false;
    bool m_btP = true;

    QBluetoothLocalDevice *m_bluetoothAdapter = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent = nullptr;
    QLowEnergyConnectionParameters *m_ble_params = nullptr;
    QBluetoothLocalDevice::HostMode m_ble_hostmode = QBluetoothLocalDevice::HostPoweredOff;

    QList <QObject *> m_bluetoothAdapters;

    QList <QString> m_devices_blacklist;

    DeviceModel *m_devices_model = nullptr;
    DeviceFilter *m_devices_filter = nullptr;

    bool m_listening = false;
    bool isListening() const;

    bool m_scanning = false;
    bool isScanning() const;

    bool m_scanning_paused = false;
    bool isScanningPaused() const;

    bool m_updating = false;
    bool isUpdating() const;

    bool m_syncing = false;
    bool isSyncing() const;

    bool m_advertising = false;
    bool isAdvertising() const;

    int getBluetoothHostMode() const { return m_ble_hostmode; }

    bool hasBluetooth() const;
    bool hasBluetoothAdapter() const;
    bool hasBluetoothEnabled() const;
    bool hasBluetoothPermissions() const;

    void checkBluetoothIos();
    void startBleAgent();

    QString getOrderByRole() const;
    int getOrderByOrder() const;

    int m_orderBy_role;
    Qt::SortOrder m_orderBy_order;

    QStringList m_availableColors = {"HotPink", "White", "Tomato", "Yellow", "Red", "Orange", "Gold", "LimeGreen", "Green",
            "MediumOrchid", "Purple", "YellowGreen", "LightYellow", "MediumVioletRed", "PeachPuff", "DodgerBlue",
            "Indigo", "Ivory", "DeepSkyBlue", "MistyRose", "DarkBlue", "MintCream", "Black", "OrangeRed",
            "PaleGreen", "Gainsboro", "PaleVioletRed", "Lavender", "Cyan", "MidnightBlue", "LightPink",
            "FireBrick", "Crimson", "DarkMagenta", "SteelBlue", "GreenYellow", "Brown", "DarkOrange",
            "Goldenrod", "DarkSeaGreen", "DarkRed", "LavenderBlush", "Violet", "Maroon", "Khaki",
            "WhiteSmoke", "Salmon", "Olive", "Orchid", "Fuchsia", "Pink", "LawnGreen", "Peru",
            "Grey", "Moccasin", "Beige", "Magenta", "DarkOrchid", "LightCyan", "RosyBrown", "GhostWhite",
            "MediumSeaGreen", "LemonChiffon", "Chocolate", "BurlyWood"};
    QString getAvailableColor();

Q_SIGNALS:
    void bluetoothChanged();
    void filteringChanged();

    void adaptersListUpdated();

    void devicesListUpdated();
    void devicesBlacklistUpdated();

    void listeningChanged();
    void scanningChanged();
    void updatingChanged();
    void syncingChanged();
    void advertisingChanged();
    void hostModeChanged();

private slots:
    // QBluetoothLocalDevice related
    void bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode);
    void bluetoothStatusChanged();

    // QBluetoothDeviceDiscoveryAgent related
    void addBleDevice(const QBluetoothDeviceInfo &info);
    void updateBleDevice(const QBluetoothDeviceInfo &info, QBluetoothDeviceInfo::Fields updatedFields);
    void updateBleDevice_simple(const QBluetoothDeviceInfo &info);
    void updateBleDevice_discovery(const QBluetoothDeviceInfo &info);
    void deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error);
    void deviceDiscoveryFinished();
    void deviceDiscoveryStopped();

public:
    DeviceManager(bool daemon = false);
    ~DeviceManager();

    // Adapters management
    Q_INVOKABLE bool areAdaptersAvailable() const { return m_bluetoothAdapters.size(); }
    QVariant getAdapters() const { return QVariant::fromValue(m_bluetoothAdapters); }
    int getAdaptersCount() const { return m_bluetoothAdapters.size(); }

    // Bluetooth management
    Q_INVOKABLE bool checkBluetooth();
    Q_INVOKABLE bool checkBluetoothPermissions();
    Q_INVOKABLE void enableBluetooth(bool enforceUserPermissionCheck = false);

    // Scanning management
    static int getLastRun();

    Q_INVOKABLE void scanDevices_start();
    Q_INVOKABLE void scanDevices_pause();
    Q_INVOKABLE void scanDevices_resume();
    Q_INVOKABLE void scanDevices_stop();

    Q_INVOKABLE void disconnectDevices();

    Q_INVOKABLE void checkPaired();

    // Device management

    // RSSI graph
    Q_INVOKABLE void getRssiGraphAxis(QDateTimeAxis *axis);
    Q_INVOKABLE void getRssiGraphData(QLineSeries *serie, int index);

    // Devices list management
    Q_INVOKABLE bool areDevicesAvailable() const { return m_devices_model->hasDevices(); }
    DeviceFilter *getDevicesFiltered() const { return m_devices_filter; }
    int getDeviceCount() const { return m_devices_model->getDeviceCount(); }

    void blacklistDevice(const QString &addr);
    void whitelistDevice(const QString &addr);
    bool isDeviceBlacklisted(const QString &addr);

    void cacheDevice(const QString &addr);
    void uncacheDevice(const QString &addr);
    bool isDeviceCached(const QString &addr);

    Q_INVOKABLE void orderby_address();
    Q_INVOKABLE void orderby_name();
    Q_INVOKABLE void orderby_manufacturer();
    Q_INVOKABLE void orderby_rssi();
    Q_INVOKABLE void orderby_interval();
    Q_INVOKABLE void orderby_firstseen();
    Q_INVOKABLE void orderby_lastseen();
    Q_INVOKABLE void orderby_model();
    void orderby(int role, Qt::SortOrder order);

    Q_INVOKABLE void setFilterString(const QString &str);
    Q_INVOKABLE void updateBoolFilters();

    Q_INVOKABLE QVariant getDeviceByProxyIndex(const int index) const
    {
        QModelIndex proxyIndex = m_devices_filter->index(index, 0);
        return QVariant::fromValue(m_devices_filter->data(proxyIndex, DeviceModel::PointerRole));
    }

    void invalidate();
};

/* ************************************************************************** */
#endif // DEVICE_MANAGER_H
