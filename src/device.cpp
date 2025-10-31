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

#include "device.h"
#include "DatabaseManager.h"
#include "VendorsDatabase.h"

#include <cstdlib>
#include <cmath>

#include <QBluetoothUuid>
#include <QBluetoothAddress>
#include <QBluetoothServiceInfo>
#include <QLowEnergyService>
#include <QLowEnergyConnectionParameters>

#include <QJsonDocument>
#include <QSqlQuery>
#include <QSqlError>

#include <QDateTime>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

Device::Device(const QString &deviceAddr, const QString &deviceName, QObject *parent) : QObject(parent)
{
#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    if (deviceAddr.size() != 38)
        qWarning() << "Device() '" << deviceAddr << "' is an invalid UUID...";

    QBluetoothUuid bleAddr(deviceAddr);
#else
    if (deviceAddr.size() != 17)
        qWarning() << "Device() '" << deviceAddr << "' is an invalid MAC address...";

    QBluetoothAddress bleAddr(deviceAddr);
#endif

    m_bleDevice = QBluetoothDeviceInfo(bleAddr, deviceName, 0);
    m_deviceAddress = deviceAddr;
    m_deviceName = deviceName;

    // Check address validity
    if (m_bleDevice.isValid() == false)
    {
        qWarning() << "Device() '" << getAddress() << "' is an invalid QBluetoothDeviceInfo...";
    }

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    // Vendor database
    VendorsDatabase *vdb = VendorsDatabase::getInstance();
    vdb->getVendor(m_deviceAddress, m_deviceManufacturer);

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::actionTimedOut);

    // Configure RSSI timer
    m_rssiTimer.setSingleShot(true);
    m_rssiTimer.setInterval(s_rssiTimeoutInterval*1000);
    connect(&m_rssiTimer, &QTimer::timeout, this, &Device::cleanRssi);
}

Device::Device(const QBluetoothDeviceInfo &d, QObject *parent) : QObject(parent)
{
    m_bleDevice = d;
    m_deviceName = m_bleDevice.name();

    m_major = d.majorDeviceClass();
    m_minor = d.minorDeviceClass();
    m_service = d.serviceClasses();

    setRssi(d.rssi());

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
    m_deviceAddress = m_bleDevice.deviceUuid().toString();
#else
    m_deviceAddress = m_bleDevice.address().toString();

    VendorsDatabase *vdb = VendorsDatabase::getInstance();
    vdb->getVendor(d.address().toString(), m_deviceManufacturer);
#endif

    // Check address validity
    if (m_bleDevice.isValid() == false)
    {
        qWarning() << "Device() '" << getAddress() << "' is an invalid QBluetoothDeviceInfo...";
    }

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    // Configure timeout timer
    m_timeoutTimer.setSingleShot(true);
    m_timeoutTimer.setInterval(s_timeoutInterval*1000);
    connect(&m_timeoutTimer, &QTimer::timeout, this, &Device::actionTimedOut);

    // Configure RSSI timer
    m_rssiTimer.setSingleShot(true);
    m_rssiTimer.setInterval(s_rssiTimeoutInterval*1000);
    connect(&m_rssiTimer, &QTimer::timeout, this, &Device::cleanRssi);
}

Device::~Device()
{
    if (m_bleController)
    {
        delete m_bleController;
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

/*!
 * \brief Device::deviceConnect
 * \return false means immediate error, true means connection process started
 */
void Device::deviceConnect(const bool stayConnected)
{
    //qDebug() << "Device::deviceConnect()" << getAddress() << getName();

    if (!m_bleController)
    {
        m_bleController = m_bleController->createCentral(m_bleDevice);
        if (m_bleController)
        {
            if (m_bleController->role() == QLowEnergyController::CentralRole)
            {
                m_bleController->setRemoteAddressType(QLowEnergyController::PublicAddress);

                m_mtu = m_bleController->mtu();
                Q_EMIT mtuUpdated();

                // Connecting signals and slots for connecting to LE services.
                connect(m_bleController, &QLowEnergyController::connected, this, &Device::deviceConnected);
                connect(m_bleController, &QLowEnergyController::disconnected, this, &Device::deviceDisconnected);
                connect(m_bleController, &QLowEnergyController::serviceDiscovered, this, &Device::addLowEnergyService, Qt::QueuedConnection);
                connect(m_bleController, &QLowEnergyController::discoveryFinished, this, &Device::serviceScanDone, Qt::QueuedConnection); // Windows hack, see: QTBUG-80770 and QTBUG-78488

                connect(m_bleController, QOverload<QLowEnergyController::Error>::of(&QLowEnergyController::errorOccurred), this, &Device::deviceErrored);
                connect(m_bleController, &QLowEnergyController::stateChanged, this, &Device::deviceStateChanged);
                connect(m_bleController, &QLowEnergyController::mtuChanged, this, &Device::deviceMtuChanged);

                connect(m_bleController, &QLowEnergyController::mtuChanged, this, &Device::deviceMtuChanged);
                connect(m_bleController, &QLowEnergyController::rssiRead, this, &Device::deviceRssiChanged);
                connect(m_bleController, &QLowEnergyController::connectionUpdated, this, &Device::deviceConnParamChanged);
            }
            else
            {
                qWarning() << "BLE controller doesn't have the QLowEnergyController::CentralRole";
            }
        }
        else
        {
            qWarning() << "Unable to create BLE controller";
        }
    }

    // Start the actual connection process
    if (m_bleController && m_bleController->state() == QLowEnergyController::UnconnectedState)
    {
        if (m_ble_status <= DeviceUtils::DEVICE_AVAILABLE)
        {
            m_stayConnected = stayConnected ? true : false;
            m_retry = stayConnected ? 0 : 999;

            m_ble_status = DeviceUtils::DEVICE_CONNECTING;
            Q_EMIT statusUpdated();

            m_bleController->connectToDevice();
            setTimeoutTimer();
        }
    }
}

void Device::deviceReconnect()
{
    if (m_ble_status != DeviceUtils::DEVICE_AVAILABLE) return; // then we can't reconnect

    //qDebug() << "Device::deviceReconnect(retry" << m_retry << "/" << s_retryCount << ")"
    //         << "[" << getAddress() << getName() << "] { status:" << m_ble_status << "}";

    if (m_bleController && m_bleController->state() == QLowEnergyController::UnconnectedState)
    {
        if (m_retry > s_retryCount)
        {
            qWarning() << "Device::deviceReconnect(retry" << m_retry << "/" << s_retryCount << ")" << getAddress() << getName();

            m_stayConnected = false;
            m_retry = 0;
        }
        else
        {
            qDebug() << "Device::deviceReconnect(retry" << m_retry << "/" << s_retryCount << ")" << getAddress() << getName();

            m_retry++;

            m_ble_status = DeviceUtils::DEVICE_CONNECTING;
            Q_EMIT statusUpdated();

            m_bleController->connectToDevice();
            setTimeoutTimer();
        }
    }
}

void Device::deviceDisconnect(const bool stayConnected)
{
    qDebug() << "Device::deviceDisconnect()" << getAddress() << getName();

    m_stayConnected = stayConnected;
    m_retry = s_retryCount;

    if (m_bleController && m_bleController->state() != QLowEnergyController::UnconnectedState)
    {
        if (m_ble_status >= DeviceUtils::DEVICE_CONNECTED)
        {
            m_ble_status = DeviceUtils::DEVICE_DISCONNECTING;
            Q_EMIT statusUpdated();

            m_bleController->disconnectFromDevice();
        }
    }
}

void Device::deviceDisconnect_temporary()
{
    qDebug() << "Device::deviceDisconnect_temporary()" << getAddress() << getName();

    m_stayConnected = true; // that is the difference
    m_retry = s_retryCount;

    if (m_bleController && m_bleController->state() != QLowEnergyController::UnconnectedState)
    {
        if (m_ble_status >= DeviceUtils::DEVICE_CONNECTED)
        {
            m_ble_status = DeviceUtils::DEVICE_DISCONNECTING;
            Q_EMIT statusUpdated();

            m_bleController->disconnectFromDevice();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::actionConnect(const bool stayConnected)
{
    if ((m_ble_status <= DeviceUtils::DEVICE_AVAILABLE))
    {
        qDebug() << "Device::actionConnect()" << getAddress() << getName();

        actionStarted(DeviceUtils::ACTION_CONNECT);
        deviceConnect(stayConnected);
    }
    else
    {
        qWarning() << "Device::actionConnect() status: " << m_ble_status;
    }
}

void Device::actionDisconnect(const bool stayConnected)
{
    if ((m_ble_status >= DeviceUtils::DEVICE_CONNECTED))
    {
        qDebug() << "Device::actionDisconnect()" << getAddress() << getName();

        actionStarted(DeviceUtils::ACTION_DISCONNECT);
        deviceDisconnect(stayConnected);
    }
    else
    {
        qWarning() << "Device::actionDisconnect() status: " << m_ble_status;
    }
}

/* ************************************************************************** */

void Device::actionScan()
{
    //qDebug() << "Device::actionScan()" << getAddress() << getName();

    if (!isWorking())
    {
        actionStarted(DeviceUtils::ACTION_SCAN);
        deviceConnect();
    }
}

void Device::actionScanWithValues()
{
    //qDebug() << "Device::actionScanWithValues()" << getAddress() << getName();

    if (!isWorking())
    {
        actionStarted(DeviceUtils::ACTION_SCAN_WITH_VALUES);
        deviceConnect();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::actionStarted(int action)
{
    qDebug() << "Device::actionStarted()" << getAddress() << getName() << "> action:" << action;

    if (m_ble_action != action)
    {
        m_ble_action = action;
        Q_EMIT actionUpdated();
    }

    if (m_ble_action == DeviceUtils::ACTION_REBOOT || m_ble_action == DeviceUtils::ACTION_SHUTDOWN ||
        m_ble_action == DeviceUtils::ACTION_CONNECT || m_ble_action == DeviceUtils::ACTION_RECONNECT ||
        m_ble_action == DeviceUtils::ACTION_DISCONNECT || m_ble_action == DeviceUtils::ACTION_DISCONNECT_FORNOW)
    {
        // don't change the status
    }
    else if (m_ble_status == DeviceUtils::DEVICE_CONNECTED)
    {
        m_ble_status = DeviceUtils::DEVICE_WORKING;
        Q_EMIT statusUpdated();
    }
}

void Device::actionFinished()
{
    qDebug() << "Device::actionFinished()" << getAddress() << getName() << "> action:" << m_ble_action;

    if (m_ble_action != DeviceUtils::ACTION_IDLE)
    {
        m_ble_action = DeviceUtils::ACTION_IDLE;
        Q_EMIT actionUpdated();
    }

    if (m_ble_status > DeviceUtils::DEVICE_CONNECTED)
    {
        m_ble_status = DeviceUtils::DEVICE_CONNECTED;
        Q_EMIT statusUpdated();
    }
}

void Device::actionErrored()
{
    qWarning() << "Device::actionErrored()" << getAddress() << getName() << "> action:" << m_ble_action;

    if (m_ble_action != DeviceUtils::ACTION_IDLE)
    {
        m_ble_action = DeviceUtils::ACTION_IDLE;
        Q_EMIT actionUpdated();
    }

    if (m_ble_status > DeviceUtils::DEVICE_CONNECTED)
    {
        m_ble_status = DeviceUtils::DEVICE_CONNECTED;
        Q_EMIT statusUpdated();
    }
}

void Device::actionCanceled()
{
    qWarning() << "Device::actionCanceled()" << getAddress() << getName() << "> action:" << m_ble_action;

    if (m_ble_action != DeviceUtils::ACTION_IDLE)
    {
        m_ble_action = DeviceUtils::ACTION_IDLE;
        Q_EMIT actionUpdated();
    }

    if (m_ble_status > DeviceUtils::DEVICE_CONNECTED)
    {
        m_ble_status = DeviceUtils::DEVICE_CONNECTED;
        Q_EMIT statusUpdated();
    }

    deviceDisconnect();
}

void Device::actionTimedOut()
{
    qWarning() << "Device::actionTimedOut()" << getAddress() << getName() << "> action:" << m_ble_action;

    if (m_ble_action != DeviceUtils::ACTION_IDLE)
    {
        m_ble_action = DeviceUtils::ACTION_IDLE;
        Q_EMIT actionUpdated();
    }

    if (m_ble_status > DeviceUtils::DEVICE_CONNECTED)
    {
        m_ble_status = DeviceUtils::DEVICE_CONNECTED;
        Q_EMIT statusUpdated();
    }
    else if (m_ble_status < DeviceUtils::DEVICE_CONNECTED)
    {
        m_ble_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

void Device::actionKeepAlive()
{
    //qDebug() << "Device::actionKeepAlive()";
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::setTimeoutTimer(int)
{
    // toolBLEx doesn't use a timeout timer
    //m_timeoutTimer.setInterval(time_s*1000);
    //m_timeoutTimer.start();
}

void Device::setKeepaliveTimer(int time_s)
{
    // toolBLEx doesn't use a keepalive timer
    //m_keepaliveTimer.setInterval(time_s*1000);
    //m_keepaliveTimer.start();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::getSqlDeviceInfos()
{
    //qDebug() << "Device::getSqlDeviceInfos(" << getAddress() << ")";
    return false;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Device::isDisconnecting() const
{
    return (m_ble_status == DeviceUtils::DEVICE_DISCONNECTING);
}

bool Device::isConnecting() const
{
    return (m_ble_status == DeviceUtils::DEVICE_CONNECTING);
}

bool Device::isConnected() const
{
    return (m_ble_status >= DeviceUtils::DEVICE_CONNECTED);
}

bool Device::isWorking() const
{
    return (m_ble_status >= DeviceUtils::DEVICE_WORKING);
}

bool Device::isUpdating() const
{
    return (m_ble_status >= DeviceUtils::DEVICE_UPDATING);
}

bool Device::isErrored() const
{
    return (getLastErrorInt() >= 0 && getLastErrorInt() <= 5);
}

/* ************************************************************************** */

int Device::getLastUpdateInt() const
{
    int mins = -1;

    if (m_lastUpdate.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastUpdate.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two updates...
            qWarning() << "getLastUpdateInt() has a negative value (" << mins << "). Clock mismatch?";

            // TODO start by a modulo 60?
            mins = std::abs(mins);
        }
    }

    return mins;
}

QString Device::getLastUpdateString() const
{
    QString lastUpdate;

    if (m_lastUpdate.isValid())
    {
        // Return timestamp (HH:MM) of last update
        //lastUpdate = m_lastUpdate.toString("HH:MM");

        // Return number of hours or minutes since last update
        int mins = getLastUpdateInt();
        if (mins > 0)
        {
            if (mins < 60) {
                lastUpdate = tr("%n minute(s)", "", mins);
            } else {
                lastUpdate = tr("%n hour(s)", "", std::floor(mins / 60.0));
            }
        }
    }

    return lastUpdate;
}

int Device::getLastUpdateDbInt() const
{
    int mins = -1;

    if (m_lastUpdateDatabase.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastUpdateDatabase.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two updates...
            qWarning() << "getLastUpdateDbInt() has a negative value (" << mins << ") for device" << m_deviceName << ". Clock mismatch?";

            // TODO start by a modulo 60?
            mins = std::abs(mins);
        }
    }

    return mins;
}

int Device::getLastErrorInt() const
{
    int mins = -1;

    if (m_lastError.isValid())
    {
        mins = static_cast<int>(std::floor(m_lastError.secsTo(QDateTime::currentDateTime()) / 60.0));

        if (mins < 0)
        {
            // this can happen if the computer clock is changed between two errors...
            qWarning() << "getLastErrorInt() has a negative value (" << mins << ") for device" << m_deviceName << ". Clock mismatch?";

            // TODO start by a modulo 60?
            mins = std::abs(mins);
        }
    }

    return mins;
}

/* ************************************************************************** */

bool Device::hasAddressMAC() const
{
    if (m_deviceAddressMAC.size() == 17) return true;
    if (m_deviceAddress.size() == 17) return true;

    return false;
}

QString Device::getAddressMAC() const
{
    if (m_deviceAddressMAC.size() == 17) return m_deviceAddressMAC;
    if (m_deviceAddress.size() == 17) return m_deviceAddress;

    return QString();
}

void Device::setAddressMAC(const QString &mac)
{
    //qDebug() << "setAddressMAC(" << mac << ")";

    if (mac.size() == 17)
    {
        if (m_deviceAddressMAC != mac)
        {
            m_deviceAddressMAC = mac;
            Q_EMIT sensorUpdated();
        }
    }
}

bool Device::hasAddressUUID() const
{
    return (m_deviceAddress.size() == 38);
}

QString Device::getAddressUUID() const
{
    if (m_deviceAddress.size() == 38) return m_deviceAddress;

    return QString();
}

void Device::setAddressUUID(const QString &uuid)
{
    //qDebug() << "setAddressUUID(" << uuid << ")";

    if (uuid.size() == 38)
    {
        if (m_deviceAddress.isEmpty() || m_deviceAddress.size() == 38)
        {
            if (m_deviceAddress != uuid)
            {
                m_deviceAddress = uuid;
                Q_EMIT sensorUpdated();
            }
        }
    }
}

/* ************************************************************************** */

bool Device::hasSetting(const QString &key) const
{
    //qDebug() << "Device::hasSetting(" << key << ")";

    return !m_additionalSettings.value(key).isUndefined();
}

QVariant Device::getSetting(const QString &key) const
{
    //qDebug() << "Device::getSetting(" << key << ")";

    return m_additionalSettings.value(key);
}

bool Device::setSetting(const QString &key, QVariant value)
{
    //qDebug() << "Device::setSetting(" << key << value << ")";
    bool status = false;

    if (m_additionalSettings.value(key) != value)
    {
        m_additionalSettings.insert(key, value.toString());
        Q_EMIT settingsUpdated();

        if (m_dbInternal || m_dbExternal)
        {
            QJsonDocument json(m_additionalSettings);
            QString json_str = QString(json.toJson());

            QSqlQuery updateSettings;
            updateSettings.prepare("UPDATE devices SET settings = :settings WHERE deviceAddr = :deviceAddr");
            updateSettings.bindValue(":settings", json_str);
            updateSettings.bindValue(":deviceAddr", getAddress());

            status = updateSettings.exec();
            if (!status)
            {
                qWarning() << "> updateSettings.exec() ERROR"
                           << updateSettings.lastError().type() << ":" << updateSettings.lastError().text();
            }
        }
    }

    return status;
}

/* ************************************************************************** */

void Device::setName(const QString &name)
{
    if (!name.isEmpty())
    {
        if (m_deviceName != name)
        {
            m_deviceName = name;
            Q_EMIT sensorUpdated();
        }
    }
}

void Device::setModel(const QString &model)
{
    if (!model.isEmpty() && m_deviceModel != model)
    {
        m_deviceModel = model;
        Q_EMIT sensorUpdated();
    }
}

void Device::setModelID(const QString &modelID)
{
    if (!modelID.isEmpty() && m_deviceModel != modelID)
    {
        m_deviceModelID = modelID;
        Q_EMIT sensorUpdated();
    }
}

void Device::setFirmware(const QString &firmware)
{
    //qDebug() << "Device::setFirmware(" << firmware << ")";

    if (!firmware.isEmpty() && m_deviceFirmware != firmware)
    {
        m_deviceFirmware = firmware;
        Q_EMIT sensorUpdated();
    }
}

void Device::setBattery(const int battery)
{
    //qDebug() << "Device::setBattery(" << battery << ")";

    if (battery > 0 && battery <= 100)
    {
        if (!hasBatteryLevel())
        {
            m_deviceCapabilities |= DeviceUtils::DEVICE_BATTERY;
            Q_EMIT capabilitiesUpdated();
        }

        if (m_deviceBattery != battery)
        {
            m_deviceBattery = battery;
            Q_EMIT batteryUpdated();
        }
    }
}

void Device::setBatteryFirmware(const int battery, const QString &firmware)
{
    bool changes = false;

    if (battery > 0 && battery <= 100 && m_deviceBattery != battery)
    {
        m_deviceBattery = battery;
        Q_EMIT batteryUpdated();
        changes = true;
    }
    if (!firmware.isEmpty() && m_deviceFirmware != firmware)
    {
        m_deviceFirmware = firmware;
        Q_EMIT sensorUpdated();
        changes = true;
    }

    if ((m_dbInternal || m_dbExternal) && changes)
    {
        QSqlQuery setBatteryFirmware;
        setBatteryFirmware.prepare("UPDATE devices SET deviceBattery = :battery, deviceFirmware = :firmware WHERE deviceAddr = :deviceAddr");
        setBatteryFirmware.bindValue(":battery", m_deviceBattery);
        setBatteryFirmware.bindValue(":firmware", m_deviceFirmware);
        setBatteryFirmware.bindValue(":deviceAddr", getAddress());

        if (setBatteryFirmware.exec() == false)
        {
            qWarning() << "> setBatteryFirmware.exec() ERROR"
                       << setBatteryFirmware.lastError().type() << ":" << setBatteryFirmware.lastError().text();
        }
    }
}

/* ************************************************************************** */

void Device::setCoreConfiguration(const int bleconf)
{
    //qDebug() << "Device::setCoreConfiguration(" << bleconf << ")";

    if (bleconf > 0)
    {
        if (m_bluetoothCoreConfiguration != bleconf && m_bluetoothCoreConfiguration != 3)
        {
            if (m_bluetoothCoreConfiguration == 1 && bleconf == 2) m_bluetoothCoreConfiguration = 3;
            else if (m_bluetoothCoreConfiguration == 2 && bleconf == 1) m_bluetoothCoreConfiguration = 3;
            else m_bluetoothCoreConfiguration = bleconf;

            Q_EMIT advertisementUpdated();
        }
    }
}

void Device::setDeviceClass(const int major, const int minor, const int service)
{
    //qDebug() << "Device::setDeviceClass() " << getName() << getAddress() << major << minor << service;

    if (m_major != major || m_minor != minor || m_service != service)
    {
        m_major = major;
        m_minor = minor;
        m_service = service;

        Q_EMIT advertisementUpdated();
    }
}

/* ************************************************************************** */

void Device::setRssi(const int rssi)
{
    if (m_rssiMin > rssi)
    {
        m_rssiMin = rssi;
    }
    if (m_rssiMax < rssi)
    {
        m_rssiMax = rssi;
    }

    if (m_rssi != rssi)
    {
        m_rssi = rssi;
        Q_EMIT rssiUpdated();
    }

    if (s_rssis_window > 0)
    {
        m_rssis.push_back(rssi);
        while (m_rssis.size() < s_rssis_window) m_rssis.push_front(rssi); // init
        if (m_rssis.size() > s_rssis_window) m_rssis.pop_front();
        Q_EMIT rssiMeanUpdated();
    }

    if (s_rssiTimeoutInterval > 0)
    {
        m_rssiTimer.start();
    }

    if (m_rssi < 0 && m_ble_status == DeviceUtils::DEVICE_OFFLINE)
    {
        m_ble_status = DeviceUtils::DEVICE_AVAILABLE;
        Q_EMIT statusUpdated();
    }

    if (m_stayConnected)
    {
        deviceReconnect();
    }
}

int Device::getRssiMean() const
{
    float rssiMean = 0.f;
    for (auto v: m_rssis) rssiMean += v;
    return (rssiMean / s_rssis_window);
}

void Device::cleanRssi()
{
    m_rssi = std::abs(m_rssi);
    Q_EMIT rssiUpdated();

    if (m_ble_status == DeviceUtils::DEVICE_AVAILABLE)
    {
        m_ble_status = DeviceUtils::DEVICE_OFFLINE;
        Q_EMIT statusUpdated();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void Device::deviceConnected()
{
    qDebug() << "Device::deviceConnected(" << getAddress() << ")";

    m_ble_status = DeviceUtils::DEVICE_CONNECTED;

    if (m_mtu != m_bleController->mtu())
    {
        m_mtu = m_bleController->mtu();
        Q_EMIT mtuUpdated();
    }

    if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME ||
        m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        // Keep screen on
        UtilsScreen *utilsScreen = UtilsScreen::getInstance();
        if (utilsScreen) utilsScreen->keepScreenOn(true);
#endif
        // Stop timeout timer, we'll be long...
        m_timeoutTimer.stop();
    }
    else if (m_ble_action == DeviceUtils::ACTION_IDLE)
    {
        // Stop timeout timer, we'll stay connected...
        m_timeoutTimer.stop();
    }
    else
    {
        // Restart for an additional 10s+?
        setTimeoutTimer();
    }

    if (m_ble_action == DeviceUtils::ACTION_UPDATE)
    {
        m_ble_status = DeviceUtils::DEVICE_UPDATING;
    }
    else if (m_ble_action == DeviceUtils::ACTION_UPDATE_REALTIME)
    {
        m_ble_status = DeviceUtils::DEVICE_UPDATING_REALTIME;
    }
    else if (m_ble_action == DeviceUtils::ACTION_UPDATE_HISTORY)
    {
        m_ble_status = DeviceUtils::DEVICE_UPDATING_HISTORY;
    }
    else if (m_ble_action == DeviceUtils::ACTION_SCAN ||
             m_ble_action == DeviceUtils::ACTION_SCAN_WITH_VALUES ||
             m_ble_action == DeviceUtils::ACTION_SCAN_WITHOUT_VALUES)
    {
        m_ble_status = DeviceUtils::DEVICE_WORKING;
    }

    Q_EMIT connected();
    Q_EMIT statusUpdated();

    //QLowEnergyConnectionParameters params;
    //params.setIntervalRange(7.5, 10);
    //params.setLatency(0);
    //params.setSupervisionTimeout(1000);
    //m_bleController->requestConnectionUpdate(params);

    m_bleController->discoverServices();
}

void Device::deviceDisconnected()
{
    qDebug() << "Device::deviceDisconnected(" << getAddress() << ")";

    m_timeoutTimer.stop();
    m_keepaliveTimer.stop();

    m_ble_status = DeviceUtils::DEVICE_OFFLINE;
    Q_EMIT statusUpdated();

    Q_EMIT disconnected();
}

void Device::deviceErrored(QLowEnergyController::Error error)
{
    if (error <= QLowEnergyController::NoError) return;
    qWarning() << "Device::deviceErrored(" << getAddress() << ") error:" << error;
/*
    QLowEnergyController::NoError	0	No error has occurred.
    QLowEnergyController::UnknownError	1	An unknown error has occurred.
    QLowEnergyController::UnknownRemoteDeviceError	2	The remote Bluetooth Low Energy device with the address passed to the constructor of this class cannot be found.
    QLowEnergyController::NetworkError	3	The attempt to read from or write to the remote device failed.
    QLowEnergyController::InvalidBluetoothAdapterError	4	The local Bluetooth device with the address passed to the constructor of this class cannot be found or there is no local Bluetooth device.
    QLowEnergyController::ConnectionError (since Qt 5.5)	5	The attempt to connect to the remote device failed.
    QLowEnergyController::AdvertisingError (since Qt 5.7)	6	The attempt to start advertising failed.
    QLowEnergyController::RemoteHostClosedError (since Qt 5.10)	7	The remote device closed the connection.
    QLowEnergyController::AuthorizationError (since Qt 5.14)	8	The local Bluetooth device closed the connection due to insufficient authorization.
    QLowEnergyController::MissingPermissionsError (since Qt 6.4)	9	The operating system requests permissions which were not granted by the user.
*/
    m_timeoutTimer.stop();
    m_keepaliveTimer.stop();

    m_lastError = QDateTime::currentDateTime();
    Q_EMIT lastUpdated();
}

void Device::deviceStateChanged(QLowEnergyController::ControllerState)
{
    //qDebug() << "Device::deviceStateChanged(" << getAddress() << ") state:" << state;
}

void Device::deviceMtuChanged(int mtu)
{
    qDebug() << "Device::deviceMtuChanged(" << getAddress() << ") MTU:" << mtu;

    if (m_mtu != mtu)
    {
        m_mtu = mtu;
        Q_EMIT mtuUpdated();
    }
}

void Device::deviceRssiChanged(qint16 rssi)
{
    qDebug() << "Device::deviceRssiChanged(" << getAddress() << ") RSSI:" << rssi;

    if (m_rssi != rssi)
    {
        m_rssi = rssi;
        Q_EMIT rssiUpdated();
    }
}

void Device::deviceConnParamChanged(const QLowEnergyConnectionParameters &newParameters)
{
    qDebug() << "Device::deviceConnParamChanged(" << getAddress() << ")";
    qDebug() << "- latency: " << newParameters.latency();
    qDebug() << "- minimumInterval: " << newParameters.minimumInterval();
    qDebug() << "- maximumInterval: " << newParameters.maximumInterval();
    qDebug() << "- supervisionTimeout: " << newParameters.supervisionTimeout();
}

/* ************************************************************************** */

void Device::addLowEnergyService(const QBluetoothUuid &)
{
    //qDebug() << "Device::addLowEnergyService(" << uuid.toString() << ")";
}

void Device::serviceScanDone()
{
    //qDebug() << "Device::serviceScanDone(" << getAddress() << ")";
}

void Device::serviceDiscoveryDone()
{
    //qDebug() << "Device::serviceDiscoveryDone(" << getAddress() << ")";
}

/* ************************************************************************** */

void Device::bleWriteDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleWriteDone(" << getAddress() << ")";
}

void Device::bleReadDone(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleReadDone(" << getAddress() << ")";
}

void Device::bleReadNotify(const QLowEnergyCharacteristic &, const QByteArray &)
{
    //qDebug() << "Device::bleReadNotify(" << getAddress() << ")";
}

/* ************************************************************************** */

void Device::parseAdvertisementData(const uint16_t, const uint16_t, const QByteArray &)
{
    //qDebug() << "Device::parseAdvertisementData(" << m_deviceName << getAddress() << ")";
}

/* ************************************************************************** */
