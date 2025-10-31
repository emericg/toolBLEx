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

#ifndef DEVICE_H
#define DEVICE_H
/* ************************************************************************** */

#include "device_utils.h"

#include <QObject>
#include <QList>
#include <QTimer>
#include <QDate>
#include <QDateTime>
#include <QByteArray>
#include <QJsonObject>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief The Device class
 */
class Device: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int deviceType READ getDeviceType CONSTANT)
    Q_PROPERTY(int deviceBluetoothMode READ getBluetoothMode CONSTANT)
    Q_PROPERTY(int deviceCapabilities READ getDeviceCapabilities NOTIFY capabilitiesUpdated)
    Q_PROPERTY(int deviceSensors READ getDeviceSensors NOTIFY sensorsUpdated)

    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceModel READ getModel NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceModelID READ getModelID NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceManufacturer READ getManufacturer NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddressMAC READ getAddressMAC WRITE setAddressMAC NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceBattery READ getBatteryLevel NOTIFY batteryUpdated)

    Q_PROPERTY(bool hasBluetoothConnection READ hasBluetoothConnection CONSTANT)
    Q_PROPERTY(bool hasBluetoothAdvertisement READ hasBluetoothAdvertisement CONSTANT)

    // BLE

    Q_PROPERTY(int mtu READ getMTU NOTIFY mtuUpdated)
    Q_PROPERTY(int rssi READ getRssi NOTIFY rssiUpdated)
    Q_PROPERTY(int rssiMean READ getRssiMean NOTIFY rssiMeanUpdated)
    Q_PROPERTY(bool available READ isAvailable NOTIFY rssiUpdated)

    Q_PROPERTY(int minorClass READ getMinorClass NOTIFY advertisementUpdated)
    Q_PROPERTY(int majorClass READ getMajorClass NOTIFY advertisementUpdated)
    Q_PROPERTY(int serviceClass READ getServiceClass NOTIFY advertisementUpdated)
    Q_PROPERTY(int bluetoothConfiguration READ getBluetoothConfiguration NOTIFY advertisementUpdated)

    Q_PROPERTY(int status READ getStatus NOTIFY statusUpdated)
    Q_PROPERTY(int action READ getAction NOTIFY actionUpdated)

    Q_PROPERTY(bool enabled READ isEnabled NOTIFY statusUpdated)
    Q_PROPERTY(bool disconnecting READ isDisconnecting NOTIFY statusUpdated)
    Q_PROPERTY(bool connecting READ isConnecting NOTIFY statusUpdated)
    Q_PROPERTY(bool connected READ isConnected NOTIFY statusUpdated)
    Q_PROPERTY(bool working READ isWorking NOTIFY statusUpdated)
    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)
    Q_PROPERTY(bool errored READ isErrored NOTIFY statusUpdated)

    Q_PROPERTY(int lastUpdateMin READ getLastUpdateInt NOTIFY lastUpdated)
    Q_PROPERTY(QString lastUpdateStr READ getLastUpdateString NOTIFY lastUpdated)

    // UI state(s)

    Q_PROPERTY(bool selected READ isSelected WRITE setSelected NOTIFY selectionUpdated)
    bool selected = false;
    bool isSelected() const { return selected; }
    void setSelected(bool value) { selected = value; Q_EMIT selectionUpdated(); }

Q_SIGNALS:
    void connected();
    void disconnected();

    void deviceUpdated(Device *d);
    void deviceSynced(Device *d);

    void sensorUpdated();
    void sensorsUpdated();
    void capabilitiesUpdated();
    void connectivityUpdated();
    void settingsUpdated();
    void selectionUpdated();

    void mtuUpdated();
    void rssiUpdated();
    void rssiMeanUpdated();

    void batteryUpdated();
    void statusUpdated();
    void actionUpdated();
    void uptimeUpdated();
    void lastUpdated();
    void dataUpdated();
    void dataAvailableUpdated();
    void advertisementUpdated();
    void refreshUpdated();  // sent when a manual refresh is successful
    void historyUpdated();  // sent when history sync is successful
    void realtimeUpdated(); // sent when a realtime update is received

protected:
    int m_deviceType = 0;           //!< See DeviceUtils::DeviceType enum
    int m_deviceCapabilities = 0;   //!< See DeviceUtils::DeviceCapabilities enum
    int m_deviceSensors = 0;        //!< See DeviceUtils::DeviceSensors enum
    int m_deviceBluetoothMode = 0;  //!< See DeviceUtils::BluetoothMode enum

    // Device data
    QString m_deviceAddress;
    QString m_deviceAddressMAC;     //!< Used only on macOS and iOS, mostly to interact with other platforms
    QString m_deviceManufacturer;
    QString m_deviceModelID;
    QString m_deviceModel;
    QString m_deviceName;

    QString m_deviceFirmware = "UNKN";
    int m_deviceBattery = -1;

    // Db availability shortcuts
    bool m_dbInternal = false;
    bool m_dbExternal = false;

    // Device settings
    bool m_isEnabled = true;
    QJsonObject m_additionalSettings;

    // Status
    int m_ble_status = 0;           //!< See DeviceStatus enum
    int m_ble_action = 0;           //!< See DeviceActions enum

    QDateTime m_lastUpdate;
    QDateTime m_lastUpdateDatabase;
    QDateTime m_lastError;

    QTimer m_updateTimer;
    void setUpdateTimer(int updateInterval_m = 0);

    QTimer m_timeoutTimer;
    const static int s_timeoutInterval = 12;
    void setTimeoutTimer(int time_s = s_timeoutInterval);

    QTimer m_keepaliveTimer;
    const static int s_keepaliveInterval = 1;
    void setKeepaliveTimer(int time_s = s_keepaliveInterval);

    bool m_stayConnected = false;
    int m_retry = 0;
    const static int s_retryCount = 999;

    // Device time
    int64_t m_device_time = -1;
    int64_t m_device_wall_time = -1;

    // BLE
    QBluetoothDeviceInfo m_bleDevice;
    QLowEnergyController *m_bleController = nullptr;

    int m_bluetoothCoreConfiguration = 0; //!< See QBluetoothDeviceInfo::CoreConfiguration enum
    int m_mtu = -1;
    int m_major = 0;
    int m_minor = 0;
    int m_service = 0;

    int m_rssi = 0;
    int m_rssiMin = 0;
    int m_rssiMax = -100;

    QList <int> m_rssis;
    const static int s_rssis_window = 16;

    QTimer m_rssiTimer;
    const static int s_rssiTimeoutInterval = 16;

    virtual void deviceConnected();
    virtual void deviceDisconnected();
    virtual void deviceErrored(QLowEnergyController::Error error);
    virtual void deviceStateChanged(QLowEnergyController::ControllerState state);
    virtual void deviceMtuChanged(int mtu);
    virtual void deviceRssiChanged(qint16 rssi);
    virtual void deviceConnParamChanged(const QLowEnergyConnectionParameters &newParameters);

    virtual void addLowEnergyService(const QBluetoothUuid &uuid);
    virtual void serviceScanDone();
    virtual void serviceDiscoveryDone();

    virtual void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

    virtual void actionStarted(int action = 0);
    virtual void actionFinished();
    virtual void actionErrored();
    virtual void actionCanceled();
    virtual void actionTimedOut();
    virtual void actionKeepAlive();

    virtual bool getSqlDeviceInfos();

    // helpers
    void setModel(const QString &model);
    void setModelID(const QString &modelID);
    void setBattery(const int battery);
    void setBatteryFirmware(const int battery, const QString &firmware);
    void setFirmware(const QString &firmware);

public:
    Device(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    Device(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    virtual ~Device();

    void setName(const QString &name);
    virtual void setDeviceClass(const int major, const int minor, const int service);
    virtual void setCoreConfiguration(const int bleconf);

    // Device infos
    QString getModel() const { return m_deviceModel; }
    QString getModelID() const { return m_deviceModelID; }
    QString getName() const { return m_deviceName; }
    QString getAddress() const { return m_deviceAddress; }
    QString getManufacturer() const { return m_deviceManufacturer; }
    QString getFirmware() const { return m_deviceFirmware; }
    int getBatteryLevel() const { return m_deviceBattery; }

    bool hasAddressMAC() const;
    QString getAddressMAC() const;
    void setAddressMAC(const QString &mac);
    bool hasAddressUUID() const;
    QString getAddressUUID() const;
    void setAddressUUID(const QString &uuid);

    // Device type, capabilities and sensors
    int getDeviceType() const { return m_deviceType; }
    int getDeviceCapabilities() const { return m_deviceCapabilities; }
    int getDeviceSensors() const { return m_deviceSensors; }

    int getBluetoothConfiguration() const { return m_bluetoothCoreConfiguration; }
    int getBluetoothMode() const { return m_deviceBluetoothMode; }
    bool hasBluetoothConnection() const { return (m_deviceBluetoothMode & DeviceUtils::DEVICE_BLE_CONNECTION); }
    bool hasBluetoothAdvertisement() const { return (m_deviceBluetoothMode & DeviceUtils::DEVICE_BLE_ADVERTISEMENT); }

    bool hasBatteryLevel() const { return (m_deviceCapabilities & DeviceUtils::DEVICE_BATTERY); }

    // Device RSSI
    bool isAvailable() const { return (m_rssi < 0); }
    int getRssi() const { return m_rssi; }
    int getRssiMean() const;
    int getRssiMin() const { return m_rssiMin; }
    int getRssiMax() const { return m_rssiMax; }
    void setRssi(const int rssi);
    void cleanRssi();

    int getMTU() const { return m_mtu; }
    int getMinorClass() const { return m_minor; }
    int getMajorClass() const { return m_major; }
    int getServiceClass() const { return m_service; }

    // Device status
    int getAction() const { return m_ble_action; }
    int getStatus() const { return m_ble_status; }
    bool isDisconnecting() const;       //!< Is disconnecting
    bool isConnecting() const;          //!< Is connecting
    bool isConnected() const;           //!< Is currently connected
    bool isWorking() const;             //!< Is currently working? doing/trying something?
    bool isUpdating() const;            //!< Is currently being updated?
    bool isErrored() const;             //!< Has emitted a BLE error

    QDateTime getLastUpdate() const;
    QString getLastUpdateString() const;
    int getLastUpdateInt() const;
    int getLastUpdateDbInt() const;
    int getLastErrorInt() const;

    // Device associated data
    bool isEnabled() const { return m_isEnabled; }
    void setEnabled(const bool enabled);

    // Device additional settings
    Q_INVOKABLE bool hasSetting(const QString &key) const;
    Q_INVOKABLE QVariant getSetting(const QString &key) const;
    Q_INVOKABLE bool setSetting(const QString &key, QVariant value);

    // BLE lifecycle
    virtual void deviceConnect(const bool stayConnected = false); //!< Initiate a BLE connection with a device
    virtual void deviceReconnect();
    virtual void deviceDisconnect(const bool stayConnected = false);
    virtual void deviceDisconnect_temporary();

    // BLE advertisement
    virtual void parseAdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QByteArray &data);

    // BLE generic actions
    Q_INVOKABLE virtual void actionConnect(const bool stayConnected = false);
    Q_INVOKABLE virtual void actionDisconnect(const bool stayConnected = false);
    Q_INVOKABLE virtual void actionScan();
    Q_INVOKABLE virtual void actionScanWithValues();
};

/* ************************************************************************** */
#endif // DEVICE_H
