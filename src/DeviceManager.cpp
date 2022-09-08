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

#include "DeviceManager.h"
#include "DatabaseManager.h"
#include "SettingsManager.h"

#include "adapter.h"
#include "device.h"
#include "device_toolbox.h"

#include "utils_app.h"

#include <QList>
#include <QDateTime>
#include <QDebug>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyConnectionParameters>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

/* ************************************************************************** */

DeviceManager::DeviceManager(bool daemon)
{
    m_daemonMode = daemon;

    // Data model init
    m_devices_model = new DeviceModel(this);
    m_devices_filter = new DeviceFilter(this);
    m_devices_filter->setSourceModel(m_devices_model);

    // BLE init
    startBleAgent();
    enableBluetooth(true); // Enables adapter // ONLY if off and permission given
    checkBluetooth();

    connect(this, &DeviceManager::bluetoothChanged, this, &DeviceManager::bluetoothStatusChanged);

    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db)
    {
        m_dbInternal = db->hasDatabaseInternal();
        m_dbExternal = db->hasDatabaseExternal();
    }

    if (m_dbInternal || m_dbExternal)
    {
        // Load blacklist
        if (!m_daemonMode)
        {
            QSqlQuery queryBlacklist;
            queryBlacklist.exec("SELECT deviceAddr FROM devicesBlacklist");
            while (queryBlacklist.next())
            {
                m_devices_blacklist.push_back(queryBlacklist.value(0).toString());
            }
        }

        // Load cached devices
        QSqlQuery queryDevices;
        queryDevices.exec("SELECT deviceAddr, deviceName FROM devices");
        while (queryDevices.next())
        {
            QString deviceAddr = queryDevices.value(0).toString();
            QString deviceName = queryDevices.value(1).toString();

            DeviceToolBLEx *d = new DeviceToolBLEx(deviceAddr, deviceName, this);
            if (d)
            {
                d->setDeviceColor(getAvailableColor());

                m_devices_model->addDevice(d);
                //qDebug() << "* Device added (from database): " << deviceName << "/" << deviceAddr;
            }
        }
    }
}

DeviceManager::~DeviceManager()
{
    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();

    delete m_bluetoothAdapter;
    delete m_discoveryAgent;
    delete m_ble_params;

    delete m_devices_filter;
    delete m_devices_model;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::hasBluetooth() const
{
    return (m_btA && m_btE);
}

bool DeviceManager::hasBluetoothAdapter() const
{
    return m_btA;
}

bool DeviceManager::hasBluetoothEnabled() const
{
    return m_btE;
}

bool DeviceManager::hasBluetoothPermissions() const
{
    return m_btP;
}

bool DeviceManager::isListening() const
{
    return m_listening;
}

bool DeviceManager::isScanning() const
{
    return m_scanning;
}

bool DeviceManager::isUpdating() const
{
    return false;
}

bool DeviceManager::isSyncing() const
{
    return false;
}

bool DeviceManager::isAdvertising() const
{
    return m_advertising;
}

/* ************************************************************************** */

bool DeviceManager::checkBluetooth()
{
    //qDebug() << "DeviceManager::checkBluetooth()";

#if defined(Q_OS_IOS)
    checkBluetoothIos();
    return true;
#endif

    bool btA_was = m_btA;
    bool btE_was = m_btE;
    bool btP_was = m_btP;

    // Check availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_btA = true;

        if (m_bluetoothAdapter->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            m_btE = true;
        }
        else
        {
            m_btE = false;
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
        }
    }
    else
    {
        m_btA = false;
        m_btE = false;
    }

    checkBluetoothPermissions();

    if (btA_was != m_btA || btE_was != m_btE || btP_was != m_btP)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return (m_btA && m_btE);
}

void DeviceManager::enableBluetooth(bool enforceUserPermissionCheck)
{
    //qDebug() << "DeviceManager::enableBluetooth() enforce:" << enforceUserPermissionCheck;

#if defined(Q_OS_IOS)
    checkBluetoothIos();
    return;
#endif

    bool btA_was = m_btA;
    bool btE_was = m_btE;
    bool btP_was = m_btP;

    // Invalid adapter? (ex: plugged off)
    if (m_bluetoothAdapter && !m_bluetoothAdapter->isValid())
    {
        delete m_bluetoothAdapter;
        m_bluetoothAdapter = nullptr;
    }

    // Select an adapter (if none currently selected)
    if (!m_bluetoothAdapter)
    {
        // Correspond to the "first available" or "default" Bluetooth adapter
        m_bluetoothAdapter = new QBluetoothLocalDevice();
        if (m_bluetoothAdapter)
        {
            // Keep us informed of Bluetooth adapter state change
            // On some platform, this can only inform us about disconnection, not reconnection
            connect(m_bluetoothAdapter, &QBluetoothLocalDevice::hostModeStateChanged,
                    this, &DeviceManager::bluetoothHostModeStateChanged);
        }
    }

    // List all Bluetooth adapters
    {
        qDeleteAll(m_bluetoothAdapters);
        m_bluetoothAdapters.clear();

        QList <QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
        if (adaptersList.size() > 0)
        {
            for (const QBluetoothHostInfo &hi: adaptersList)
            {
                bool inuse = false;
                if (m_bluetoothAdapter) inuse = (hi.address() == m_bluetoothAdapter->address());

                Adapter *a = new Adapter(hi, inuse, this);
                m_bluetoothAdapters.push_back(a);
            }
        }
        else
        {
            qWarning() << "> No Bluetooth adapter found...";
        }

        Q_EMIT adaptersListUpdated();
    }

    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_btA = true;

        if (m_bluetoothAdapter->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            m_btE = true; // was already activated

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
            // Already powered on? Power on again anyway. It helps on android...
            //m_bluetoothAdapter->powerOn();
#endif
        }
        else // Try to activate the adapter
        {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
            // mobile? check if we have the user's permission to do so
            if (enforceUserPermissionCheck)
            {
                SettingsManager *sm = SettingsManager::getInstance();
                if (sm && sm->getBluetoothControl())
                {
                    m_bluetoothAdapter->powerOn(); // Doesn't work on all platforms...
                }
            }
            else
#endif
            // desktop (or mobile but with user action)
            {
                Q_UNUSED(enforceUserPermissionCheck)
                m_bluetoothAdapter->powerOn(); // Doesn't work on all platforms...
            }
        }
    }
    else
    {
        m_btA = false;
        m_btE = false;
    }

    checkBluetoothPermissions();

    if (btA_was != m_btA || btE_was != m_btE || btP_was != m_btP)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }
}

bool DeviceManager::checkBluetoothPermissions()
{
    bool btP_was = m_btP;

    UtilsApp *utilsApp = UtilsApp::getInstance();
    m_btP = utilsApp->checkMobileBleLocationPermission();

    if (btP_was != m_btP)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return m_btP;
}

/* ************************************************************************** */

void DeviceManager::bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "DeviceManager::bluetoothHostModeStateChanged() host mode now:" << state;

    if (state > QBluetoothLocalDevice::HostPoweredOff)
    {
        m_btE = true;
    }
    else
    {
        m_btE = false;
    }

    Q_EMIT bluetoothChanged();
}

void DeviceManager::bluetoothStatusChanged()
{
    //qDebug() << "DeviceManager::bluetoothStatusChanged() bt adapter:" << m_btA << " /  bt enabled:" << m_btE;

    if (m_btA && m_btE)
    {
        listenDevices_start();
    }
    else
    {
        // Bluetooth disabled, force disconnection
        listenDevices_stop();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::startBleAgent()
{
    //qDebug() << "DeviceManager::startBleAgent()";

    // BLE discovery agent
    if (!m_discoveryAgent)
    {
        m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent();
        if (m_discoveryAgent)
        {
            connect(m_discoveryAgent, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::errorOccurred),
                    this, &DeviceManager::deviceDiscoveryError, Qt::UniqueConnection);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

void DeviceManager::checkBluetoothIos()
{
    // iOS behave differently than all other platforms; there is no way to check
    // adapter status, only to start a device discovery and check for errors

    //qDebug() << "DeviceManager::checkBluetoothIos()";

    m_btA = true;

    if (m_discoveryAgent)
    {
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::updateBleDevice_simple);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::updateBleDevice);

        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                   this, &DeviceManager::deviceDiscoveryFinished);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                this, &DeviceManager::bluetoothHostModeStateChangedIos, Qt::UniqueConnection);

        m_discoveryAgent->setLowEnergyDiscoveryTimeout(8); // 8ms
        m_discoveryAgent->start();

        if (m_discoveryAgent->isActive())
        {
            qDebug() << "Checking iOS Bluetooth...";
        }
    }
}

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        if (m_btE)
        {
            m_btE = false;
            //refreshDevices_stop();
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        m_btA = false;
        m_btE = false;
        //refreshDevices_stop();
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        m_btA = false;

        if (m_btE)
        {
            m_btE = false;
            //refreshDevices_stop();
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported platform.";

        m_btA = false;
        m_btE = false;
        //refreshDevices_stop();
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";

        m_btE = false;
        m_btP = false;
        //refreshDevices_stop();
        Q_EMIT bluetoothChanged();
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_btA = false;
        m_btE = false;
        //refreshDevices_stop();
        Q_EMIT bluetoothChanged();
    }

    if (m_scanning)
    {
        m_scanning = false;
        Q_EMIT scanningChanged();
    }
}

void DeviceManager::deviceDiscoveryFinished()
{
    //qDebug() << "DeviceManager::deviceDiscoveryFinished()";

    if (m_scanning)
    {
        m_scanning = false;
        Q_EMIT scanningChanged();
    }
}

void DeviceManager::deviceDiscoveryStopped()
{
    //qDebug() << "DeviceManager::deviceDiscoveryStopped()";

    if (m_scanning)
    {
        m_scanning = false;
        Q_EMIT scanningChanged();
    }
}

void DeviceManager::bluetoothHostModeStateChangedIos()
{
    //qDebug() << "DeviceManager::bluetoothHostModeStateChangedIos()";

    if (!m_btE)
    {
        m_btA = true;
        m_btE = true;
        Q_EMIT bluetoothChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::listenDevices_start()
{
    //qDebug() << "DeviceManager::listenDevices_start()";

    if (hasBluetooth())
    {
        if (!m_discoveryAgent)
        {
            startBleAgent();
        }

        if (m_discoveryAgent && !m_discoveryAgent->isActive())
        {
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                       this, &DeviceManager::addBleDevice);
            disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                       this, &DeviceManager::deviceDiscoveryFinished);

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

            //connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            //        this, &DeviceManager::updateBleDevice_simple, Qt::UniqueConnection);
            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::updateBleDevice, Qt::UniqueConnection);

            int scanningDuration = 0;
            int scanningMethod = QBluetoothDeviceDiscoveryAgent::ClassicMethod | QBluetoothDeviceDiscoveryAgent::LowEnergyMethod;

            SettingsManager *sm = SettingsManager::getInstance();
            if (sm)
            {
                scanningDuration = sm->getScanTimeout() * 60 * 1000;
            }

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(scanningDuration);

            if (hasBluetoothPermissions())
            {
                //NoMethod = 0x0 // ClassicMethod = 0x01 // LowEnergyMethod = 0x02,
                m_discoveryAgent->start(static_cast<QBluetoothDeviceDiscoveryAgent::DiscoveryMethod>(scanningMethod));

                if (m_discoveryAgent->isActive())
                {
                    m_scanning = true;
                    Q_EMIT scanningChanged();
                    qDebug() << "Listening for BLE advertisement devices...";
                }
            }
            else
            {
                qWarning() << "Cannot scan or listen without related Android permissions";
            }
        }
    }
}

void DeviceManager::listenDevices_stop()
{
    //qDebug() << "DeviceManager::listenDevices_stop()";

    if (hasBluetooth())
    {
        if (m_discoveryAgent)
        {
            if (m_discoveryAgent->isActive())
            {
                m_discoveryAgent->stop();

                m_scanning = false;
                Q_EMIT scanningChanged();
                qDebug() << "Listening for BLE advertisement devices...";
            }
        }
    }

    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device *>(d);
        if (dd) dd->cleanRssi();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::addBleDevice(const QBluetoothDeviceInfo &info)
{
    //qDebug() << "DeviceManager::addBleDevice()" << " > NAME" << info.name() << " > RSSI" << info.rssi();

    // Is the device is already in the UI?
    for (auto ed: qAsConst(m_devices_model->m_devices)) // device is already in the UI
    {
        Device *edd = qobject_cast<Device *>(ed);
        if (edd && (edd->getAddress() == info.address().toString() ||
                    edd->getAddress() == info.deviceUuid().toString()))
        {
            return;
        }
    }

    // Create the device
    DeviceToolBLEx *d = new DeviceToolBLEx(info, this);
    if (d)
    {
        if (info.name().replace('-', ':') == info.address().toString()) d->setBeacon(true);
        if (info.isCached() || info.rssi() == 0) d->setCached(true);
        if (m_devices_blacklist.contains(info.address().toString())) d->setBlacklisted(true);

        // Get a random color
        d->setDeviceColor(getAvailableColor());

        // Add it to the UI
        m_devices_model->addDevice(d);
        Q_EMIT devicesListUpdated();

        // Add it to the cache? But not if it's a beacon...
        SettingsManager *sm = SettingsManager::getInstance();
        if (sm->getScanCacheAuto() && !d->isBeacon())
        {
            cacheDevice(info.address().toString());
        }

        //qDebug() << "Device added (from BLE discovery): " << d->getName() << "/" << d->getAddress();
    }
}

void DeviceManager::disconnectDevices()
{
    //qDebug() << "DeviceManager::disconnectDevices()";

    for (auto d: qAsConst(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device *>(d);
        dd->deviceDisconnect();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::blacklistDevice(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        // if
        QSqlQuery queryDevice;
        queryDevice.prepare("SELECT deviceAddr FROM devicesBlacklist WHERE deviceAddr = :deviceAddr");
        queryDevice.bindValue(":deviceAddr", addr);
        queryDevice.exec();

        // then
        if (queryDevice.last() == false)
        {
            qDebug() << "+ Blacklisting device: " << addr;

            QSqlQuery blacklistDevice;
            blacklistDevice.prepare("INSERT INTO devicesBlacklist (deviceAddr) VALUES (:deviceAddr)");
            blacklistDevice.bindValue(":deviceAddr", addr);

            if (blacklistDevice.exec() == true)
            {
                m_devices_blacklist.push_back(addr);
                Q_EMIT devicesBlacklistUpdated();
            }
        }
    }
}

void DeviceManager::whitelistDevice(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        qDebug() << "+ Whitelisting device: " << addr;

        QSqlQuery whitelistDevice;
        whitelistDevice.prepare("DELETE FROM devicesBlacklist WHERE deviceAddr = :deviceAddr");
        whitelistDevice.bindValue(":deviceAddr", addr);

        if (whitelistDevice.exec() == true)
        {
            m_devices_blacklist.removeAll(addr);
            Q_EMIT devicesBlacklistUpdated();
        }
    }
}

/* ************************************************************************** */

void DeviceManager::cacheDevice(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
            if (dd->getAddress() == addr)
            {
                // if
                QSqlQuery queryDevice;
                queryDevice.prepare("SELECT deviceName FROM devices WHERE deviceAddr = :deviceAddr");
                queryDevice.bindValue(":deviceAddr", addr);
                queryDevice.exec();

                // then
                if (queryDevice.last() == false)
                {
                    //qDebug() << "+ Caching device: " << dd->getName() << "/" << dd->getAddress() << "to local database";

                    QString deviceClass;
                    if (dd->getMajorClass() && dd->getMinorClass())
                    {
                        deviceClass = QString::number(dd->getMajorClass()) + "-" +
                                      QString::number(dd->getMinorClass()) + "-" +
                                      QString::number(dd->getServiceClass());
                    }

                    QSqlQuery cacheDevice;
                    cacheDevice.prepare("INSERT INTO devices (deviceAddr, deviceName, deviceManufacturer, deviceCoreConfig, deviceClass, firstSeen) VALUES (:deviceAddr, :deviceName, :deviceManufacturer, :deviceCoreConfig, :deviceClass, :firstSeen)");
                    cacheDevice.bindValue(":deviceAddr", dd->getAddress());
                    cacheDevice.bindValue(":deviceName", dd->getName());
                    cacheDevice.bindValue(":deviceManufacturer", dd->getManufacturer());
                    cacheDevice.bindValue(":deviceCoreConfig", dd->getBluetoothConfiguration());
                    cacheDevice.bindValue(":deviceClass", deviceClass);
                    cacheDevice.bindValue(":firstSeen", dd->getFirstSeen());

                    if (cacheDevice.exec() == false)
                    {
                        qWarning() << "> cacheDevice.exec() ERROR"
                                   << cacheDevice.lastError().type() << ":" << cacheDevice.lastError().text();
                    }
                }
            }
        }
    }
}

void DeviceManager::uncacheDevice(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        for (auto d: qAsConst(m_devices_model->m_devices))
        {
            DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
            if (dd->getAddress() == addr)
            {
                //qDebug() << "+ Uncaching device: " << addr;

                QSqlQuery uncacheDevice;
                uncacheDevice.prepare("DELETE FROM devices WHERE deviceAddr = :deviceAddr");
                uncacheDevice.bindValue(":deviceAddr", addr);

                if (uncacheDevice.exec() == false)
                {
                    qWarning() << "> uncacheDevice.exec() ERROR"
                               << uncacheDevice.lastError().type() << ":" << uncacheDevice.lastError().text();
                }
            }

            break;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::invalidate()
{
    m_devices_filter->invalidate();
}

QString DeviceManager::getOrderByRole() const
{
    if (m_orderBy_role == DeviceModel::DeviceAddressRole) return "address";
    if (m_orderBy_role == DeviceModel::DeviceNameRole) return "name";
    if (m_orderBy_role == DeviceModel::DeviceManufacturerRole) return "manufacturer";
    if (m_orderBy_role == DeviceModel::DeviceRssiRole) return "rssi";
    if (m_orderBy_role == DeviceModel::DeviceIntervalRole) return "interval";
    if (m_orderBy_role == DeviceModel::DeviceFirstSeenRole) return "firstseen";
    if (m_orderBy_role == DeviceModel::DeviceLastSeenRole) return "lastseen";
    if (m_orderBy_role == DeviceModel::DeviceModelRole) return "model";
    return "";
}

int DeviceManager::getOrderByOrder() const
{
    // AscendingOrder // DescendingOrder
    return static_cast<int>(m_orderBy_order);
}

void DeviceManager::orderby(int role, Qt::SortOrder order)
{
    if (m_orderBy_role != role)
    {
        m_orderBy_role = role;
        m_orderBy_order = order;
    }
    else
    {
        if (m_orderBy_order == Qt::AscendingOrder)
            m_orderBy_order = Qt::DescendingOrder;
        else
            m_orderBy_order = Qt::AscendingOrder;
    }

    Q_EMIT filteringChanged();

    m_devices_filter->setSortRole(m_orderBy_role);
    m_devices_filter->sort(0, m_orderBy_order);
    m_devices_filter->invalidate();
}

void DeviceManager::orderby_address()
{
    orderby(DeviceModel::DeviceAddressRole, m_orderBy_order);
}

void DeviceManager::orderby_name()
{
    orderby(DeviceModel::DeviceNameRole, m_orderBy_order);
}

void DeviceManager::orderby_manufacturer()
{
    orderby(DeviceModel::DeviceManufacturerRole, m_orderBy_order);
}

void DeviceManager::orderby_rssi()
{
    orderby(DeviceModel::DeviceRssiRole, m_orderBy_order);
}

void DeviceManager::orderby_interval()
{
    orderby(DeviceModel::DeviceIntervalRole, m_orderBy_order);
}

void DeviceManager::orderby_firstseen()
{
    orderby(DeviceModel::DeviceFirstSeenRole, m_orderBy_order);
}

void DeviceManager::orderby_lastseen()
{
    orderby(DeviceModel::DeviceLastSeenRole, m_orderBy_order);
}

void DeviceManager::orderby_model()
{
    orderby(DeviceModel::DeviceModelRole, m_orderBy_order);
}

void DeviceManager::setFilterString(const QString &str)
{
    m_devices_filter->setFilterString(str);
    m_devices_filter->invalidate();
}

void DeviceManager::updateBoolFilters()
{
    m_devices_filter->updateBoolFilters();
    m_devices_filter->invalidate();
}

/* ************************************************************************** */
