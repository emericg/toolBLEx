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
#include "device_toolblex.h"

#include <QCoreApplication>
#include <QStandardPaths>
#include <QPermissions>

#include <QDir>
#include <QList>
#include <QDateTime>
#include <QDebug>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlQuery>
#include <QSqlError>

/* ************************************************************************** */

DeviceManager::DeviceManager(bool daemon)
{
    m_daemonMode = daemon;

    // Data model init (unified)
    m_device_header = new DeviceHeader(this);
    m_devices_model = new DeviceModel(this);
    m_devices_filter = new DeviceFilter(this);
    m_devices_filter->setSourceModel(m_devices_model);
    m_devices_filter->setDynamicSortFilter(true);

    // BLE init
    checkBluetoothPermission();
    enableBluetooth(true); // Enables adapter // ONLY if off and permission given
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
        // Load device blacklist
        if (!m_daemonMode)
        {
            QSqlQuery queryBlacklist;
            queryBlacklist.exec("SELECT deviceAddr FROM devicesBlacklist");
            while (queryBlacklist.next())
            {
                m_devices_blacklist.push_back(queryBlacklist.value(0).toString());
            }
        }

        // Count cached devices
        countDeviceSeenCached();

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
                d->setCached(true);
                d->setDeviceColor(getAvailableColor());

                m_devices_model->addDevice(d);
                //qDebug() << "* Device added (from database): " << deviceName << "/" << deviceAddr;
            }
        }
    }

    // Count device structure cache files
    countDeviceStructureCached();

    // Check if we have Bluetooth classic device paired
    checkPaired();

    // Stats
    countDevices();
    connect(this, &DeviceManager::devicesListUpdated, this, &DeviceManager::countDevices);
    connect(this, &DeviceManager::devicesSeenCacheUpdated, this, &DeviceManager::countDevices);

    // Device colors
    m_colorsLeft = m_colorsAvailable;
}

DeviceManager::~DeviceManager()
{
    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();

    delete m_bluetoothAdapter;
    delete m_bluetoothDiscoveryAgent;

    delete m_device_header;
    delete m_devices_filter;
    delete m_devices_model;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::checkBluetooth()
{
    //qDebug() << "DeviceManager::checkBluetooth()";

    bool btA_was = m_bleAdapter && m_bluetoothAdapter->isValid();
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermission;

    checkBluetoothPermission();

    // Check adapter availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_bleAdapter = true;

        if (m_bluetoothAdapter->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            m_bleEnabled = true;
        }
        else
        {
            m_bleEnabled = false;
            qWarning() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
        }
    }
    else
    {
        m_bleAdapter = false;
        m_bleEnabled = false;
        qWarning() << "Bluetooth adapter INVALID";
    }

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermission)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();

        // let's see if we can turn on the adapter now
        enableBluetooth(true);
    }

    if (m_bluetoothAdapter)
    {
        for (auto a: std::as_const(m_bluetoothAdapters))
        {
            Adapter *adp = qobject_cast<Adapter *>(a);
            if (adp)
            {
                bool inuse = (adp->getAddress() == m_bluetoothAdapter->address().toString());
                int hostmode = (inuse && m_bluetoothAdapter->hostMode());

                adp->update(inuse, hostmode);
            }
        }
    }

    return (m_bleAdapter && m_bleEnabled && m_blePermission);
}

bool DeviceManager::enableBluetooth(bool enforceUserPermissionCheck)
{
    //qDebug() << "DeviceManager::enableBluetooth() enforce:" << enforceUserPermissionCheck;

    bool btA_was = m_bleAdapter && m_bluetoothAdapter->isValid();
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermission;

    // Invalid adapter? (ex: plugged off)
    if (m_bluetoothAdapter && !m_bluetoothAdapter->isValid())
    {
        qDebug() << "DeviceManager::enableBluetooth() deleting current adapter";
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

        const QList <QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
        if (adaptersList.size() > 0)
        {
            for (const QBluetoothHostInfo &hi: adaptersList)
            {
                bool inuse = (m_bluetoothAdapter && hi.address() == m_bluetoothAdapter->address());
                int hostmode = (inuse && m_bluetoothAdapter->hostMode());

                Adapter *a = new Adapter(hi, inuse, hostmode, this);
                m_bluetoothAdapters.push_back(a);
            }
        }
        else
        {
            qWarning() << "> No Bluetooth adapter found...";
        }

        Q_EMIT adaptersListUpdated();
    }

    // Check adapter availability
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid())
    {
        m_bleAdapter = true;

        if (m_bluetoothAdapter->hostMode() > QBluetoothLocalDevice::HostMode::HostPoweredOff)
        {
            // Was already activated
            m_bleEnabled = true;
        }
        else
        {
            // Try to activate the adapter

            Q_UNUSED(enforceUserPermissionCheck)
            m_bluetoothAdapter->powerOn(); // Doesn't work on all platforms...
        }

        checkPaired();
    }
    else
    {
        qWarning() << "DeviceManager::enableBluetooth() we have an invalid adapter";
        m_bleAdapter = false;
        m_bleEnabled = false;
    }

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermission)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    //qDebug() << "DeviceManager::enableBluetooth() >> RECAP";
    //qDebug() << " - bluetooth" << hasBluetooth();
    //qDebug() << " - bleAdapter" << m_bleAdapter;
    //qDebug() << " - bleEnabled" << m_bleEnabled;
    //qDebug() << " - blePermission" << m_blePermission;

    return (m_bleAdapter && m_bleEnabled && m_blePermission);
}

/* ************************************************************************** */

bool DeviceManager::requestBluetoothPermission()
{
    //qDebug() << "DeviceManager::requestBluetoothPermission()";

    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        setBluetoothPermission(true);
        enableBluetooth(true);
        break;
    case Qt::PermissionStatus::Denied:
    case Qt::PermissionStatus::Undetermined:
        qDebug() << "Requesting BLUETOOTH permission...";
        qApp->requestPermission(bluetoothPermission, this, &DeviceManager::requestBluetoothPermission_results);
        break;
    }

    return m_blePermission;
}

void DeviceManager::requestBluetoothPermission_results(const QPermission &permission)
{
    // evaluate the results
    switch (permission.status())
    {
    case Qt::PermissionStatus::Granted:
        setBluetoothPermission(true);
        enableBluetooth(true);
        break;
    case Qt::PermissionStatus::Denied:
    case Qt::PermissionStatus::Undetermined:
        setBluetoothPermission(false);
        break;
    }
}

bool DeviceManager::checkBluetoothPermission()
{
    QBluetoothPermission bluetoothPermission;
    bluetoothPermission.setCommunicationModes(QBluetoothPermission::Default);

    switch (qApp->checkPermission(bluetoothPermission))
    {
    case Qt::PermissionStatus::Granted:
        setBluetoothPermission(true);
        enableBluetooth(true);
        break;
    case Qt::PermissionStatus::Denied:
        setBluetoothPermission(false);
        break;
    case Qt::PermissionStatus::Undetermined:
        break;
    }

    return m_blePermission;
}

void DeviceManager::setBluetoothPermission(bool perm)
{
    if (m_blePermission != perm)
    {
        m_blePermission = perm;
        Q_EMIT permissionChanged();
    }
}

/* ************************************************************************** */

void DeviceManager::bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode state)
{
    //qDebug() << "DeviceManager::bluetoothHostModeStateChanged() host mode now:" << state;

    if (state != m_bluetoothHostMode)
    {
        m_bluetoothHostMode = state;
        Q_EMIT hostModeChanged();
    }

    if (state > QBluetoothLocalDevice::HostPoweredOff)
    {
        m_bleEnabled = true;

        checkPaired();
    }
    else
    {
        m_bleEnabled = false;
    }

    Q_EMIT bluetoothChanged();
}

void DeviceManager::bluetoothStatusChanged()
{
    //qDebug() << "DeviceManager::bluetoothStatusChanged() bt adapter:" << m_bleAdapter << " /  bt enabled:" << m_bleEnabled;

    if (m_bleAdapter && m_bleEnabled)
    {
        // Bluetooth enabled, re/start listening
        scanDevices_start();
    }
    else
    {
        // Bluetooth disabled, force disconnection
        scanDevices_stop();
    }
}

void DeviceManager::bluetoothPermissionChanged()
{
    //qDebug() << "DeviceManager::bluetoothPermissionChanged()";

    if (m_bleAdapter && m_bleEnabled)
    {
        checkBluetooth();
    }
    else
    {
        enableBluetooth();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::startBleAgent()
{
    //qDebug() << "DeviceManager::startBleAgent()";

    // BLE discovery agent
    if (!m_bluetoothDiscoveryAgent)
    {
        m_bluetoothDiscoveryAgent = new QBluetoothDeviceDiscoveryAgent();
        if (m_bluetoothDiscoveryAgent)
        {
            //qDebug() << "Scanning method supported:" << m_bluetoothDiscoveryAgent->supportedDiscoveryMethods();

            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
                    this, &DeviceManager::deviceDiscoveryError);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error <= QBluetoothDeviceDiscoveryAgent::NoError) return;

    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError)
    {
        qWarning() << "The Bluetooth adaptor is powered off, power it on before doing discovery.";

        if (m_bleEnabled)
        {
            m_bleEnabled = false;
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError)
    {
        qWarning() << "deviceDiscoveryError() Writing or reading from the device resulted in an error.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::InvalidBluetoothAdapterError)
    {
        qWarning() << "deviceDiscoveryError() Invalid Bluetooth adapter.";

        m_bleAdapter = false;

        if (m_bleEnabled)
        {
            m_bleEnabled = false;
            Q_EMIT bluetoothChanged();
        }
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedPlatformError)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Platform.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::UnsupportedDiscoveryMethod)
    {
        qWarning() << "deviceDiscoveryError() Unsupported Discovery Method.";

        m_bleEnabled = false;
        m_blePermission = false;
        Q_EMIT bluetoothChanged();
        Q_EMIT permissionChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_bleEnabled = false;
        m_blePermission = false;
        Q_EMIT bluetoothChanged();
        Q_EMIT permissionChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        m_bleEnabled = false;
        m_blePermission = false;
        Q_EMIT bluetoothChanged();
        Q_EMIT permissionChanged();
    }
    else
    {
        qWarning() << "An unknown error has occurred.";

        m_bleAdapter = false;
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
    }

    scanDevices_stop();

    if (m_scanning)
    {
        m_scanning = false;
        Q_EMIT scanningChanged();
    }
    if (m_listening)
    {
        m_listening = false;
        Q_EMIT listeningChanged();
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
    if (m_listening)
    {
        m_listening = false;
        Q_EMIT listeningChanged();
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
    if (m_listening)
    {
        m_listening = false;
        Q_EMIT listeningChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::advertise_start()
{
    //qDebug() << "DeviceManager::advertise_start()";
}

void DeviceManager::advertise_stop()
{
    //qDebug() << "DeviceManager::advertise_stop()";
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::scanDevices_start()
{
    //qDebug() << "DeviceManager::scanDevices_start()";

    if (hasBluetooth() && hasBluetoothPermission())
    {
        if (!m_bluetoothDiscoveryAgent)
        {
            startBleAgent();
        }

        if (m_bluetoothDiscoveryAgent && !m_bluetoothDiscoveryAgent->isActive())
        {
            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryFinished, Qt::UniqueConnection);
            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::bleDevice_discovered, Qt::UniqueConnection);
            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::bleDevice_updated, Qt::UniqueConnection);

            m_bluetoothDiscoveryAgent->setLowEnergyDiscoveryTimeout(0);
            m_bluetoothDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::ClassicMethod |
                                             QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

            if (m_bluetoothDiscoveryAgent->isActive())
            {
                m_scanning = true;
                Q_EMIT scanningChanged();
                qDebug() << "Listening for BLE advertisement devices...";
            }
        }
    }
    else
    {
        qWarning() << "Cannot scan or listen without BLE adapter or BLE permission";
    }
}

void DeviceManager::scanDevices_pause()
{
    //qDebug() << "DeviceManager::scanDevices_pause()";

    if (!SettingsManager::getInstance()->getScanPause()) return;

    if (hasBluetooth())
    {
        if (m_bluetoothDiscoveryAgent)
        {
            if (m_bluetoothDiscoveryAgent->isActive())
            {
                m_bluetoothDiscoveryAgent->stop();

                m_scanning = true;
                m_scanning_paused = true;
                Q_EMIT scanningChanged();
            }
        }
    }

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device *>(d);
        if (dd) dd->cleanRssi();
    }
}

void DeviceManager::scanDevices_resume()
{
    //qDebug() << "DeviceManager::scanDevices_resume()";

    // Are we really paused?
    if (!m_scanning_paused) return;
    if (!SettingsManager::getInstance()->getScanPause()) return;

    if (hasBluetooth() && hasBluetoothPermission())
    {
        if (!m_bluetoothDiscoveryAgent)
        {
            startBleAgent();
        }

        if (m_bluetoothDiscoveryAgent && !m_bluetoothDiscoveryAgent->isActive())
        {
            m_bluetoothDiscoveryAgent->setLowEnergyDiscoveryTimeout(0);
            m_bluetoothDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::ClassicMethod |
                                             QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);

            if (m_bluetoothDiscoveryAgent->isActive())
            {
                m_scanning = true;
                m_scanning_paused = false;
                Q_EMIT scanningChanged();
            }
        }
    }
    else
    {
        qWarning() << "Cannot scan or listen without BLE adapter or BLE permission";
    }
}

void DeviceManager::scanDevices_stop()
{
    //qDebug() << "DeviceManager::scanDevices_stop()";

    if (m_bluetoothDiscoveryAgent)
    {
        if (m_bluetoothDiscoveryAgent->isActive() && m_scanning)
        {
            m_bluetoothDiscoveryAgent->stop();
            m_scanning = false;
            Q_EMIT scanningChanged();
        }
    }

    for (auto d: std::as_const(m_devices_model->m_devices))
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
    for (auto ed: std::as_const(m_devices_model->m_devices)) // device is already in the UI
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
        if (info.isCached() || info.rssi() == 0) d->setCached(true);
        //if (info.name().isEmpty()) d->setBeacon(true);
        //if (info.name().replace('-', ':') == d->getAddress()) d->setBeacon(true);
        //if (info.name() == "Bluetooth " + d->getAddress().toLower()) d->setBeacon(true);
        if (m_devices_blacklist.contains(d->getAddress())) d->setBlacklisted(true);

        // Get a random color
        d->setDeviceColor(getAvailableColor());

        // Add it to the UI
        m_devices_model->addDevice(d);
        Q_EMIT devicesListUpdated();

        // Add it to the cache? But not if it's a beacon...
        SettingsManager *sm = SettingsManager::getInstance();
        if (sm->getScanCacheAuto() && !d->isBeacon())
        {
            cacheDeviceSeen(d->getAddress());
            d->setCached(true);
        }

        //qDebug() << "Device added (from BLE discovery): " << d->getName() << "/" << d->getAddress();
    }
}

bool DeviceManager::areDevicesConnected() const
{
    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);
        if (dd && dd->isConnected())
        {
            return true;
        }
    }

    return false;
}

void DeviceManager::disconnectDevices() const
{
    //qDebug() << "DeviceManager::disconnectDevices()";

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device *>(d);
        dd->deviceDisconnect();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::checkPaired()
{
    if (m_bluetoothAdapter && m_bluetoothAdapter->isValid() && m_devices_model->hasDevices())
    {
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);

            if (!dd->isBeacon() && dd->isBluetoothClassic()) // ?
            {
                //qDebug() << dd->getName() << m_bluetoothAdapter->pairingStatus(QBluetoothAddress(dd->getAddress()));
                dd->setPairingStatus(m_bluetoothAdapter->pairingStatus(QBluetoothAddress(dd->getAddress())));
            }
        }
    }
}

void DeviceManager::countDevices()
{
    SettingsManager *sm = SettingsManager::getInstance();
    bool filterShowBeacon = sm->getScanShowBeacon();
    bool filterShowBlacklisted = sm->getScanShowBlacklisted();
    bool filterShowCached = sm->getScanShowCached();
    bool filterShowBluetoothClassic = sm->getScanShowClassic();
    bool filterShowBluetoothLowEnergy = sm->getScanShowLowEnergy();

    m_countFound = 0;
    m_countShown = 0;
    m_countHidden = 0;
    m_countClassic = 0;
    m_countBLE = 0;
    m_countBeacon = 0;

    m_countBlacklisted = m_devices_blacklist.count();
    m_countCached = m_devicesSeenCachedCount;

    for (auto dd: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *d = qobject_cast<DeviceToolBLEx *>(dd);
        if (d)
        {
            bool accepted = true;

            if (!filterShowBluetoothClassic && !filterShowBluetoothLowEnergy) accepted = false;
            else if (!filterShowBluetoothClassic && d->isBluetoothClassic() && !d->isBluetoothLowEnergy()) accepted = false;
            else if (!filterShowBluetoothLowEnergy && d->isBluetoothLowEnergy() && !d->isBluetoothClassic()) accepted = false;
            else if (!filterShowBeacon && d->isBeacon()) accepted = false;
            else if (!filterShowBlacklisted && d->isBlacklisted()) accepted = false;
            else if (!filterShowCached && d->isCached() && d->getRssi() == 0) accepted = false;

            if (d->isBluetoothClassic() != 0) m_countClassic++;
            if (d->isBluetoothLowEnergy() != 0) m_countBLE++;
            if (d->isBeacon() != 0) m_countBeacon++;

            if (d->getRssi() != 0) m_countFound++;
            if (accepted) m_countShown++;
            else m_countHidden++;
        }
    }

    Q_EMIT statsChanged();
}

void DeviceManager::clearResults()
{
    qDebug() << "DeviceManager::clearResults()";

    if (m_devices_model /*&& !m_scanning*/)
    {
        m_devices_model->clearDevices();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::blacklistBleDevice(const QString &addr)
{
    qDebug() << "DeviceManager::blacklistBleDevice(" << addr << ")";

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

void DeviceManager::whitelistBleDevice(const QString &addr)
{
    qDebug() << "DeviceManager::whitelistBleDevice(" << addr << ")";

    if (m_dbInternal || m_dbExternal)
    {
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

bool DeviceManager::isBleDeviceBlacklisted(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        // if
        QSqlQuery queryDevice;
        queryDevice.prepare("SELECT deviceAddr FROM devicesBlacklist WHERE deviceAddr = :deviceAddr");
        queryDevice.bindValue(":deviceAddr", addr);
        queryDevice.exec();

        // then
        return queryDevice.last();
    }

    return false;
}

/* ************************************************************************** */

void DeviceManager::cacheDeviceSeen(const QString &addr)
{
    //qDebug() << "cacheDeviceSeen(" << addr << ")";

    if (m_dbInternal || m_dbExternal)
    {
        for (auto d: std::as_const(m_devices_model->m_devices))
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

                    if (cacheDevice.exec())
                    {
                        m_devicesSeenCachedCount++;
                        Q_EMIT devicesSeenCacheUpdated();
                    }
                    else
                    {
                        qWarning() << "> cacheDevice.exec() ERROR"
                                   << cacheDevice.lastError().type() << ":" << cacheDevice.lastError().text();
                    }
                }
                else
                {
                    qWarning() << "> queryDevice.exec() CAN't";
                }
            }
        }
    }
}

void DeviceManager::uncacheDeviceSeen(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
            if (dd->getAddress() == addr)
            {
                //qDebug() << "+ Uncaching device: " << addr;

                QSqlQuery uncacheDevice;
                uncacheDevice.prepare("DELETE FROM devices WHERE deviceAddr = :deviceAddr");
                uncacheDevice.bindValue(":deviceAddr", addr);

                if (uncacheDevice.exec())
                {
                    m_devicesSeenCachedCount--;
                    Q_EMIT devicesSeenCacheUpdated();
                }
                else
                {
                    qWarning() << "> uncacheDevice.exec() ERROR"
                               << uncacheDevice.lastError().type() << ":" << uncacheDevice.lastError().text();
                }

                break;
            }
        }
    }
}

bool DeviceManager::isDeviceSeenCached(const QString &addr)
{
    if (m_dbInternal || m_dbExternal)
    {
        // if
        QSqlQuery queryDevice;
        queryDevice.prepare("SELECT deviceAddr FROM devices WHERE deviceAddr = :deviceAddr");
        queryDevice.bindValue(":deviceAddr", addr);
        queryDevice.exec();

        // then
        return queryDevice.last();
    }

    return false;
}

void DeviceManager::clearDeviceSeenCache()
{
    // Remove every device in the list but not currently scanned
    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
        if (dd->isCached() && !dd->isAvailable())
        {
            m_devices_model->removeDevice(dd);
            Q_EMIT devicesListUpdated();
        }
    }

    // Clear persistent cache
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery clearDeviceSeenCache;
        clearDeviceSeenCache.prepare("DELETE FROM devices");
        if (clearDeviceSeenCache.exec())
        {
            m_devicesSeenCachedCount = 0;
            Q_EMIT devicesSeenCacheUpdated();
        }
        else
        {
            qWarning() << "> clearDeviceSeenCache.exec() ERROR"
                       << clearDeviceSeenCache.lastError().type() << ":" << clearDeviceSeenCache.lastError().text();
        }
    }
}

int DeviceManager::countDeviceSeenCached()
{
    // Count device cached
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery countDeviceSeenCached;
        countDeviceSeenCached.prepare("SELECT COUNT(*) FROM devices");
        if (countDeviceSeenCached.exec() == false)
        {
            qWarning() << "> countDeviceSeenCached.exec() ERROR"
                       << countDeviceSeenCached.lastError().type() << ":" << countDeviceSeenCached.lastError().text();
        }
        else
        {
            if (countDeviceSeenCached.first())
            {
                m_devicesSeenCachedCount = countDeviceSeenCached.value(0).toInt();
                Q_EMIT devicesSeenCacheUpdated();
            }
        }
    }

    return m_devicesSeenCachedCount;
}

/* ************************************************************************** */

QString DeviceManager::getDeviceStructureDirectory() const
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/devices/";
}

int DeviceManager::countDeviceStructureCached()
{
    QDir cacheFolder = getDeviceStructureDirectory();
    QStringList filters("*.cache");
    QStringList files = cacheFolder.entryList(filters, QDir::Files);

    m_devicesStructureCachedCount = files.count();
    Q_EMIT devicesStructureCacheUpdated();

    return m_devicesStructureCachedCount;
}

void DeviceManager::clearDeviceStructureCache()
{
    QString cacheDirPath = getDeviceStructureDirectory();
    if (cacheDirPath.isEmpty()) return;

    QDir cacheFolder = cacheDirPath;
    const QStringList filters("*.cache");
    const QStringList files = cacheFolder.entryList(filters, QDir::Files);
    for (const auto &file: files)
    {
        if (!file.isEmpty())
        {
            //qDebug() << "REMOVING FILE" << cacheDirPath + file;
            QFile::remove(cacheDirPath + file);
        }
    }

    countDeviceStructureCached();
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::invalidate()
{
    m_devices_filter->invalidate();
}

void DeviceManager::invalidateFilter()
{
    m_devices_filter->invalidatefilter();
}

QString DeviceManager::getOrderByRole() const
{
    if (m_orderBy_role == DeviceModel::DeviceColorRole) return "color";
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
    //m_devices_filter->invalidate();
}

void DeviceManager::orderby_default()
{
    orderby(DeviceModel::Default, Qt::AscendingOrder);
}

void DeviceManager::orderby_address()
{
    orderby(DeviceModel::DeviceAddressRole, m_orderBy_order);
}

void DeviceManager::orderby_name()
{
    orderby(DeviceModel::DeviceNameRole, m_orderBy_order);
}

void DeviceManager::orderby_model()
{
    orderby(DeviceModel::DeviceModelRole, m_orderBy_order);
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

void DeviceManager::setFilterString(const QString &str)
{
    m_devices_filter->setFilterString(str);
    m_devices_filter->invalidate();
}

void DeviceManager::updateBoolFilters()
{
    m_devices_filter->updateBoolFilters();
    m_devices_filter->invalidatefilter();

    countDevices(); // stats
}

/* ************************************************************************** */
