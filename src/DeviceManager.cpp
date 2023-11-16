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

#include <QList>
#include <QDateTime>
#include <QDebug>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#if defined(Q_OS_MACOS) || defined(Q_OS_IOS)
#if QT_CONFIG(permissions)
#include <QGuiApplication>
#include <QPermissions>
#endif
#endif

/* ************************************************************************** */

DeviceManager::DeviceManager(bool daemon)
{
    m_daemonMode = daemon;

    // Data model init
    m_device_header = new DeviceHeader(this);
    m_devices_model = new DeviceModel(this);
    m_devices_filter = new DeviceFilter(this);
    m_devices_filter->setSourceModel(m_devices_model);
    m_devices_filter->setDynamicSortFilter(true);

    // BLE init
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

        // Count saved devices
        countDeviceCached();

        // Load saved devices
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

    // Check if we have Bluetooth classic device paired
    checkPaired();

    // Device colors
    m_colorsLeft = m_colorsAvailable;
}

DeviceManager::~DeviceManager()
{
    qDeleteAll(m_bluetoothAdapters);
    m_bluetoothAdapters.clear();

    delete m_bluetoothAdapter;
    delete m_discoveryAgent;

    delete m_device_header;
    delete m_devices_filter;
    delete m_devices_model;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::checkBluetooth()
{
    //qDebug() << "DeviceManager::checkBluetooth()";

#if defined(Q_OS_IOS)
    // at this point we don't actually try to use checkBluetoothIOS() or we will
    // be caugth in a loop with the OS notifying the user that BLE wants to start
    // but is off, then giving back the focus to the app, thus calling checkBluetooth()...
    return m_bleEnabled;
#endif

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermissions;

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
            qDebug() << "Bluetooth adapter host mode:" << m_bluetoothAdapter->hostMode();
        }
    }
    else
    {
        m_bleAdapter = false;
        m_bleEnabled = false;
    }

    // Check OS permissions
    checkBluetoothPermissions();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermissions)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
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

    return (m_bleAdapter && m_bleEnabled && m_blePermissions);
}

bool DeviceManager::enableBluetooth(bool enforceUserPermissionCheck)
{
    //qDebug() << "DeviceManager::enableBluetooth() enforce:" << enforceUserPermissionCheck;

#if defined(Q_OS_IOS)
    checkBluetoothIOS();
    return false;
#endif

    bool btA_was = m_bleAdapter;
    bool btE_was = m_bleEnabled;
    bool btP_was = m_blePermissions;

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

        QList <QBluetoothHostInfo> adaptersList = QBluetoothLocalDevice::allDevices();
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

        checkPaired();
    }
    else
    {
        m_bleAdapter = false;
        m_bleEnabled = false;
    }

    // Check OS permissions
    checkBluetoothPermissions();

    if (btA_was != m_bleAdapter || btE_was != m_bleEnabled || btP_was != m_blePermissions)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return (m_bleAdapter && m_bleEnabled && m_blePermissions);
}

bool DeviceManager::checkBluetoothPermissions()
{
    //qDebug() << "DeviceManager::checkBluetoothPermissions()";

#if !defined(Q_OS_MACOS) && !defined(Q_OS_IOS)
    m_permOS = true;
#endif

#if !defined(Q_OS_ANDROID)
    m_permLocationBLE = true;
    m_permLocationBKG = true;
    m_permGPS = true;
#endif

    bool os_was = m_permOS;
    bool loc_was = m_permLocationBLE;
    bool loc_bg_was = m_permLocationBKG;
    bool gps_was = m_permGPS;
    bool btP_was = m_blePermissions;

#if defined(Q_OS_ANDROID)

    m_permLocationBLE = UtilsApp::checkMobileBleLocationPermission();
    m_permLocationBKG = UtilsApp::checkMobileBackgroundLocationPermission();
    m_permGPS = UtilsApp::isMobileGpsEnabled();

    // set m_permLocationBLE as primary
    // we will check for GPS or background location permissions explicitely if we need them
    m_blePermissions = m_permLocationBLE;

#elif defined(Q_OS_MACOS) || defined(Q_OS_IOS)
#if QT_CONFIG(permissions)

    if (qApp)
    {
        QBluetoothPermission blePermission;
        switch (qApp->checkPermission(blePermission))
        {
        case Qt::PermissionStatus::Undetermined:
            qApp->requestPermission(blePermission, this, &DeviceManager::checkBluetoothPermissions);
            return false;
        case Qt::PermissionStatus::Denied:
            m_permOS = false;
            m_blePermissions = m_permOS;
            break;
        case Qt::PermissionStatus::Granted:
            m_permOS = true;
            m_blePermissions = m_permOS;
            break;
        }
    }

#endif // QT_CONFIG(permissions)
#else

    // Linux and Windows don't have required BLE permissions
    m_blePermissions = true;

#endif

    if (os_was != m_permOS || gps_was != m_permGPS ||
        loc_was != m_permLocationBLE || loc_bg_was != m_permLocationBKG)
    {
        // this function did change the Bluetooth permission
        Q_EMIT permissionsChanged();
    }
    if (btP_was != m_blePermissions)
    {
        // this function did changed the Bluetooth adapter status
        Q_EMIT bluetoothChanged();
    }

    return m_blePermissions;
}

/* ************************************************************************** */

void DeviceManager::bluetoothHostModeStateChanged(QBluetoothLocalDevice::HostMode state)
{
    qDebug() << "DeviceManager::bluetoothHostModeStateChanged() host mode now:" << state;

    if (state != m_ble_hostmode)
    {
        m_ble_hostmode = state;
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
            //qDebug() << "Scanning method supported:" << m_discoveryAgent->supportedDiscoveryMethods();

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
                    this, &DeviceManager::deviceDiscoveryError);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

void DeviceManager::checkBluetoothIOS()
{
    //qDebug() << "DeviceManager::checkBluetoothIOS()";

    // iOS behave differently than all other platforms; there is no way to check
    // adapter status, we can only to start a device discovery and check if it fails

    // the thing is, when the discovery is started with the BLE adapter turned off,
    // it will actually take up to 30s to report that fact... so after a short while,
    // we check on our own if the discovery agent is still running or not using a timer

    // when the BLE adapter is turned off while the discovery is already running,
    // the error is reported instantly though

    m_bleAdapter = true; // there is no iOS device without a BLE adapter

    m_permOS = true; // TODO
    m_blePermissions = m_permOS;

    // not necessary on iOS // set everything to true
    m_permLocationBLE = true;
    m_permLocationBKG = true;
    m_permGPS = true;

    if (!m_discoveryAgent)
    {
        startBleAgent();
    }
    if (m_discoveryAgent)
    {
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::addBleDevice);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                   this, &DeviceManager::updateBleDevice_simple);
        disconnect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                   this, &DeviceManager::updateBleDevice);

        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                this, &DeviceManager::deviceDiscoveryFinished, Qt::UniqueConnection);
        connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

        m_discoveryAgent->setLowEnergyDiscoveryTimeout(8); // 8ms
        m_discoveryAgent->start();

        if (m_discoveryAgent->isActive())
        {
            qDebug() << "Checking iOS Bluetooth...";

            // this ensure no other function will be able to use the discovery agent while this check is running
            m_checking_ios_ble = true;
            m_bleEnabled = false;

            // this ensure that we catch error as soon as possible (~333ms) and not ~30s later when the OS think we should know
            connect(&m_checking_ios_timer, &QTimer::timeout, this,
                    &DeviceManager::deviceDiscoveryErrorIOS, Qt::UniqueConnection);
            m_checking_ios_timer.setSingleShot(true);
            m_checking_ios_timer.start(333);
        }
    }
}

void DeviceManager::deviceDiscoveryErrorIOS()
{
    //qDebug() << "DeviceManager::deviceDiscoveryErrorIOS()";

    if (m_discoveryAgent) m_discoveryAgent->stop();
    m_checking_ios_ble = false;

    if (m_bleEnabled)
    {
        m_bleEnabled = false;
        Q_EMIT bluetoothChanged();
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
        m_blePermissions = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::LocationServiceTurnedOffError)
    {
        qWarning() << "deviceDiscoveryError() Location Service Turned Off Error.";

        m_bleEnabled = false;
        m_blePermissions = false;
        Q_EMIT bluetoothChanged();
    }
    else if (error == QBluetoothDeviceDiscoveryAgent::MissingPermissionsError)
    {
        qWarning() << "deviceDiscoveryError() Missing Permissions Error.";

        m_bleEnabled = false;
        m_blePermissions = false;
        Q_EMIT bluetoothChanged();
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

#if defined(Q_OS_IOS)
    if (m_checking_ios_ble)
    {
        m_checking_ios_ble = false;
        m_checking_ios_timer.stop();

        if (!m_bleEnabled)
        {
            m_bleEnabled = true;
            Q_EMIT bluetoothChanged();
        }
    }
#endif

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

void DeviceManager::scanDevices_start()
{
    //qDebug() << "DeviceManager::scanDevices_start()";

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

            connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::updateBleDevice_discovery, Qt::UniqueConnection);
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

void DeviceManager::scanDevices_pause()
{
    //qDebug() << "DeviceManager::scanDevices_pause()";

    if (!SettingsManager::getInstance()->getScanPause()) return;

    if (hasBluetooth())
    {
        if (m_discoveryAgent)
        {
            if (m_discoveryAgent->isActive())
            {
                m_discoveryAgent->stop();

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

    if (hasBluetooth())
    {
        if (!m_discoveryAgent)
        {
            startBleAgent();
        }

        if (m_discoveryAgent && !m_discoveryAgent->isActive())
        {
            int scanningDuration = SettingsManager::getInstance()->getScanTimeout() * 60 * 1000;
            int scanningMethod = QBluetoothDeviceDiscoveryAgent::ClassicMethod | QBluetoothDeviceDiscoveryAgent::LowEnergyMethod;

            m_discoveryAgent->setLowEnergyDiscoveryTimeout(scanningDuration);

            if (hasBluetoothPermissions())
            {
                m_discoveryAgent->start(static_cast<QBluetoothDeviceDiscoveryAgent::DiscoveryMethod>(scanningMethod));

                if (m_discoveryAgent->isActive())
                {
                    m_scanning = true;
                    m_scanning_paused = false;
                    Q_EMIT scanningChanged();
                }
            }
        }
    }

}

void DeviceManager::scanDevices_stop()
{
    //qDebug() << "DeviceManager::scanDevices_stop()";

#if defined(Q_OS_ANDROID)
    // An Android service won't be able to scan/listen in the background without the associated permission
    if (m_daemonMode && !m_permLocationBKG) return;
#endif

    if (hasBluetooth())
    {
        if (!m_discoveryAgent)
        {
            startBleAgent();
        }
        if (m_discoveryAgent)
        {
            if (m_discoveryAgent->isActive() && m_scanning)
            {
                m_discoveryAgent->stop();
                m_scanning = false;
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
        if (info.name().isEmpty()) d->setBeacon(true);
        if (info.name().replace('-', ':') == d->getAddress()) d->setBeacon(true);
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
            cacheDevice(d->getAddress());
        }

        //qDebug() << "Device added (from BLE discovery): " << d->getName() << "/" << d->getAddress();
    }
}

void DeviceManager::disconnectDevices()
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

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::blacklistDevice(const QString &addr)
{
    qDebug() << "DeviceManager::blacklistDevice(" << addr << ")";

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
    qDebug() << "DeviceManager::whitelistDevice(" << addr << ")";

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

bool DeviceManager::isDeviceBlacklisted(const QString &addr)
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

void DeviceManager::cacheDevice(const QString &addr)
{
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
                        m_devicesCachedCount++;
                        Q_EMIT devicesCacheUpdated();
                    }
                    else
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
                    m_devicesCachedCount--;
                    Q_EMIT devicesCacheUpdated();
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

bool DeviceManager::isDeviceCached(const QString &addr)
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

void DeviceManager::clearDeviceCache()
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
        QSqlQuery clearDeviceCache;
        clearDeviceCache.prepare("DELETE FROM devices");
        if (clearDeviceCache.exec())
        {
            m_devicesCachedCount = 0;
            Q_EMIT devicesCacheUpdated();
        }
        else
        {
            qWarning() << "> clearDeviceCache.exec() ERROR"
                       << clearDeviceCache.lastError().type() << ":" << clearDeviceCache.lastError().text();
        }
    }
}

int DeviceManager::countDeviceCached()
{
    // Count device cached
    if (m_dbInternal || m_dbExternal)
    {
        QSqlQuery countDeviceCached;
        countDeviceCached.prepare("SELECT COUNT(*) FROM devices");
        if (countDeviceCached.exec() == false)
        {
            qWarning() << "> countDeviceCached.exec() ERROR"
                       << countDeviceCached.lastError().type() << ":" << countDeviceCached.lastError().text();
        }
        else
        {
            if (countDeviceCached.first())
            {
                m_devicesCachedCount = countDeviceCached.value(0).toInt();
                Q_EMIT devicesCacheUpdated();
            }
        }
    }

    return m_devicesCachedCount;
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
}

/* ************************************************************************** */
