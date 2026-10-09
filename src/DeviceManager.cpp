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

#include "AdapterManager.h"
#include "device.h"
#include "device_toolblex.h"

#include <thread>
#include <chrono>

#include <QCoreApplication>
#include <QGuiApplication>
#include <QJSEngine>
#include <QStandardPaths>

#include <QDir>
#include <QList>
#include <QDateTime>
#include <QDebug>

#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

#include <QSqlQuery>
#include <QSqlError>

/* ************************************************************************** */
/* ************************************************************************** */

DeviceManager *DeviceManager::getInstance()
{
    static DeviceManager *instance = new DeviceManager(QCoreApplication::instance());
    return instance;
}

DeviceManager *DeviceManager::create(QQmlEngine *, QJSEngine *)
{
    DeviceManager *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

DeviceManager::DeviceManager(QObject *parent) : QObject(parent)
{
    // Data model init (unified)
    m_device_header = new DeviceHeader(this);
    m_devices_model = new DeviceModel(this);
    m_devices_filter = new DeviceFilter(this);
    m_devices_filter->setSourceModel(m_devices_model);
    m_devices_filter->setDynamicSortFilter(true);

    // Bluetooth adapter
    AdapterManager *am = AdapterManager::getInstance();
    connect(am, &AdapterManager::bluetoothChanged_scan,
            this, &DeviceManager::bluetoothStatusChanged);
    connect(am, &AdapterManager::adapterChanged_scan,
            this, &DeviceManager::adapterChanged_scan);
    adapterChanged_scan();

    // Scan pause while the application is inactive
    m_scanPauseTimer.setSingleShot(true);
    m_scanPauseTimer.setInterval(s_scanPauseDelay);
    connect(&m_scanPauseTimer, &QTimer::timeout, this, &DeviceManager::scanDevices_pause);

    if (auto *app = qobject_cast<QGuiApplication *>(QCoreApplication::instance()))
    {
        connect(app, &QGuiApplication::applicationStateChanged,
                this, &DeviceManager::applicationStateChanged);
    }

    // Device colors
    m_colorsLeft = m_colorsAvailable;

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
        QSqlQuery queryBlacklist;
        queryBlacklist.exec("SELECT deviceAddr FROM devicesBlacklist");
        while (queryBlacklist.next())
        {
            m_devices_blacklist.push_back(queryBlacklist.value(0).toString());
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

    // Check if we have devices paired
    checkPaired();

    // Stats
    countDevices();
    connect(this, &DeviceManager::devicesListUpdated, this, &DeviceManager::countDevices);
    connect(this, &DeviceManager::devicesSeenCacheUpdated, this, &DeviceManager::countDevices);
}

DeviceManager::~DeviceManager()
{
    delete m_bluetoothDiscoveryAgent;

    delete m_device_header;
    delete m_devices_filter;
    delete m_devices_model;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DeviceManager::areDevicesConnected() const
{
    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        if (d && (d->getStatus() >= DeviceUtils::DEVICE_DISCONNECTING))
        {
            //qDebug() << "DeviceManager::areDevicesConnected() TRUE";
            return true;
        }
    }

    //qDebug() << "DeviceManager::areDevicesConnected() FALSE";

    return false;
}

void DeviceManager::disconnectDevices() const
{
    qDebug() << "DeviceManager::disconnectDevices()";

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device*>(d);
        dd->actionDisconnect();
    }
}

void DeviceManager::disconnectAndExit() const
{
    if (areDevicesConnected())
    {
        qDebug() << "DeviceManager::disconnectAndExit()";

        disconnectDevices();

        int timeout = 60;

        while (areDevicesConnected() && timeout > 0)
        {
            qApp->processEvents();
            std::this_thread::sleep_for(std::chrono::milliseconds(33));
            timeout--;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::applicationStateChanged(Qt::ApplicationState state)
{
    if (state == Qt::ApplicationInactive)
    {
        m_scanPauseTimer.start();
    }
    else if (state == Qt::ApplicationActive)
    {
        m_scanPauseTimer.stop();
        scanDevices_resume();
    }
}

/* ************************************************************************** */

void DeviceManager::adapterChanged_scan()
{
    //qDebug() << "DeviceManager::adapterChanged_scan()";

    // Drop everything bound to the previous adapter
    bool wasScanning = (m_scanning && !m_scanning_paused);

    if (m_bluetoothDiscoveryAgent)
    {
        // A paused scan stays paused, and resumes on the new adapter
        if (!m_scanning_paused) stopScanning();

        delete m_bluetoothDiscoveryAgent;
        m_bluetoothDiscoveryAgent = nullptr;
    }

    if (!m_pairingPendingAddress.isEmpty()) bluetoothPairingError(QBluetoothLocalDevice::UnknownError);

    checkPaired();

    // The Bluetooth status may not change, restart scanning on the new adapter ourselves
    if (wasScanning)
    {
        QMetaObject::invokeMethod(this, &DeviceManager::scanDevices_start, Qt::QueuedConnection);
    }
}

void DeviceManager::bluetoothStatusChanged()
{
    //qDebug() << "DeviceManager::bluetoothStatusChanged()";

    AdapterManager *am = AdapterManager::getInstance();
    if (am->hasBluetooth_scan())
    {
        checkPaired();

        // Bluetooth enabled, start listening if it has been requested
        if (m_scanPending) scanDevices_start();
    }
    else
    {
        // Bluetooth disabled, scanning resumes once it is back
        if (m_scanning || m_scanning_paused) m_scanPending = true;
        stopScanning();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::startBleAgent()
{
    //qDebug() << "DeviceManager::startBleAgent()";

    AdapterManager *am = AdapterManager::getInstance();

    // No agent, create one
    if (!m_bluetoothDiscoveryAgent)
    {
        m_bluetoothDiscoveryAgent = new QBluetoothDeviceDiscoveryAgent(am->getAdapterAddress_scan());
        if (m_bluetoothDiscoveryAgent)
        {
            //qDebug() << "Scanning method supported:" << m_bluetoothDiscoveryAgent->supportedDiscoveryMethods();

            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
                    this, &DeviceManager::deviceDiscoveryFinished, Qt::UniqueConnection);
            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
                    this, &DeviceManager::deviceDiscoveryStopped, Qt::UniqueConnection);

            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
                    this, &DeviceManager::bleDevice_discovered, Qt::UniqueConnection);
            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceUpdated,
                    this, &DeviceManager::bleDevice_updated, Qt::UniqueConnection);

            connect(m_bluetoothDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
                    this, &DeviceManager::deviceDiscoveryError);
        }
        else
        {
            qWarning() << "Unable to create BLE discovery agent...";
        }
    }
}

/* ************************************************************************** */

void DeviceManager::deviceDiscoveryError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error <= QBluetoothDeviceDiscoveryAgent::NoError) return;

    AdapterManager::getInstance()->discoveryError(error);

    stopScanning();

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

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::scanDevices_start()
{
    //qDebug() << "DeviceManager::scanDevices_start()";

    // Handled here, switchAdapter_scan() may change the Bluetooth status, see bluetoothStatusChanged()
    m_scanPending = false;

    // Starting a new scan session, go back to the selected adapter (the agent is deleted if it changes)
    if (!m_scanning) AdapterManager::getInstance()->switchAdapter_scan();

    if (AdapterManager::getInstance()->hasBluetooth_scan())
    {
        startBleAgent();

        if (m_bluetoothDiscoveryAgent && !m_bluetoothDiscoveryAgent->isActive())
        {
            int timeout = SettingsManager::getInstance()->getScanTimeout_ms();
            int methods = SettingsManager::getInstance()->getScanMethods();

            m_bluetoothDiscoveryAgent->setLowEnergyDiscoveryTimeout(timeout);
            m_bluetoothDiscoveryAgent->start(static_cast<QBluetoothDeviceDiscoveryAgent::DiscoveryMethod>(methods));

            if (m_bluetoothDiscoveryAgent->isActive())
            {
                m_scanning = true;
                m_scanning_paused = false;
                Q_EMIT scanningChanged();
                qDebug() << "Listening for BLE advertisement devices...";
            }
        }
    }
    else
    {
        qWarning() << "Cannot scan or listen without BLE adapter or BLE permission, scanning when available";
        m_scanPending = true;
    }
}

void DeviceManager::scanDevices_pause()
{
    //qDebug() << "DeviceManager::scanDevices_pause()";

    if (!SettingsManager::getInstance()->getScanPause()) return;

    if (AdapterManager::getInstance()->hasBluetooth_scan())
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

    // Are we really paused? (the pause setting may have been disabled since)
    if (!m_scanning_paused) return;

    if (AdapterManager::getInstance()->hasBluetooth_scan())
    {
        startBleAgent();

        if (m_bluetoothDiscoveryAgent && !m_bluetoothDiscoveryAgent->isActive())
        {
            int timeout = SettingsManager::getInstance()->getScanTimeout_ms();
            int methods = SettingsManager::getInstance()->getScanMethods();

            m_bluetoothDiscoveryAgent->setLowEnergyDiscoveryTimeout(timeout);
            m_bluetoothDiscoveryAgent->start(static_cast<QBluetoothDeviceDiscoveryAgent::DiscoveryMethod>(methods));

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
        qWarning() << "Cannot scan or listen without BLE adapter or BLE permission, scanning when available";
        m_scanPending = true;
        stopScanning();
    }
}

void DeviceManager::scanDevices_stop()
{
    //qDebug() << "DeviceManager::scanDevices_stop()";

    m_scanPending = false;
    stopScanning();
}

void DeviceManager::stopScanning()
{
    if (m_bluetoothDiscoveryAgent && m_bluetoothDiscoveryAgent->isActive())
    {
        m_bluetoothDiscoveryAgent->stop();
    }

    // A paused scan has no active agent, but still needs to be stopped
    if (m_scanning || m_scanning_paused)
    {
        m_scanning = false;
        m_scanning_paused = false;
        Q_EMIT scanningChanged();
    }

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        Device *dd = qobject_cast<Device *>(d);
        if (dd) dd->cleanRssi();
    }
}

void DeviceManager::scanDevices_restart(bool clear)
{
    //qDebug() << "DeviceManager::scanDevices_restart()";

    scanDevices_stop();
    if (clear) clearResults();
    scanDevices_start();
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
            countDevices();
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

        d->setPairingStatus(m_devicesPaired.value(info.address().toUInt64(), QBluetoothLocalDevice::Unpaired));

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

/* ************************************************************************** */
/* ************************************************************************** */

void DeviceManager::checkPaired()
{
    QBluetoothLocalDevice *adapter = AdapterManager::getInstance()->getAdapterDevice_scan();
    if (!adapter || !adapter->isValid()) return;

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    m_devicesPaired = AdapterManager::getInstance()->getPairedDevices_bluez(m_bluetoothAdapter->address());
#else
    m_devicesPaired.clear();
    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
        if (dd && !dd->isBeacon())
        {
            QBluetoothAddress addr(dd->getAddress());
            if (addr.isNull()) continue;

            QBluetoothLocalDevice::Pairing p = adapter->pairingStatus(addr);
            if (p != QBluetoothLocalDevice::Unpaired) paired.insert(addr.toUInt64(), p);
        }
    }
#endif

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
        if (dd)
        {
            dd->setPairingStatus(m_devicesPaired.value(QBluetoothAddress(dd->getAddress()).toUInt64(),
                                                       QBluetoothLocalDevice::Unpaired));
        }
    }
}

bool DeviceManager::requestPairing(const QString &address, QBluetoothLocalDevice::Pairing pairing)
{
    QBluetoothLocalDevice *adapter = AdapterManager::getInstance()->getAdapterDevice_scan();
    if (!adapter || !adapter->isValid()) return false;
    if (!m_pairingPendingAddress.isEmpty()) return false;

    QBluetoothAddress addr(address);
    if (addr.isNull()) return false;

    m_pairingPendingAddress = address;
    adapter->requestPairing(addr, pairing);

    return true;
}

void DeviceManager::bluetoothPairingFinished(const QBluetoothAddress &address,
                                             QBluetoothLocalDevice::Pairing pairing)
{
    //qDebug() << "DeviceManager::bluetoothPairingFinished()" << address << pairing;

    if (QBluetoothAddress(m_pairingPendingAddress) == address) m_pairingPendingAddress.clear();

    if (pairing == QBluetoothLocalDevice::Unpaired) m_devicesPaired.remove(address.toUInt64());
    else m_devicesPaired.insert(address.toUInt64(), pairing);

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
        if (dd && QBluetoothAddress(dd->getAddress()) == address)
        {
            dd->pairingFinished(pairing);
            break;
        }
    }
}

void DeviceManager::bluetoothPairingError(QBluetoothLocalDevice::Error error)
{
    qWarning() << "DeviceManager::bluetoothPairingError()" << m_pairingPendingAddress << error;

    if (m_pairingPendingAddress.isEmpty()) return;

    for (auto d: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
        if (dd && dd->getAddress() == m_pairingPendingAddress)
        {
            dd->pairingErrored(error);
            break;
        }
    }

    m_pairingPendingAddress.clear();
}

void DeviceManager::countDevices()
{
    //qDebug() << "DeviceManager::countDevices()";

    SettingsManager *sm = SettingsManager::getInstance();
    bool filterShowBeacon = sm->getScanShowBeacon();
    bool filterShowBlacklisted = sm->getScanShowBlacklisted();
    bool filterShowCached = sm->getScanShowCached();
    bool filterShowBluetoothClassic = sm->getScanShowClassic();
    bool filterShowBluetoothLowEnergy = sm->getScanShowLowEnergy();

    const QString filterString = m_devices_filter->getFilterString();

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

            if (accepted && !filterString.isEmpty())
            {
                if (!d->getAddress().contains(filterString, Qt::CaseInsensitive) &&
                    !d->getName().contains(filterString, Qt::CaseInsensitive) &&
                    !d->getManufacturer().contains(filterString, Qt::CaseInsensitive))
                {
                    accepted = false;
                    //qDebug() << "> REJECTED > (" << filterString << ") >" << d->getAddress() << d->getName() << d->getManufacturer();
                }
            }

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

/* ************************************************************************** */

void DeviceManager::clearResults()
{
    qDebug() << "DeviceManager::clearResults()";

    //if (!m_scanning)
    {
        m_devices_model->clearDevices();
    }

    Q_EMIT devicesListUpdated();
}

bool DeviceManager::exportResults(const QString &filename, int exportMode,
                                  bool withManuf, bool withComment, bool withSeen,
                                  const QString &comment)
{
    bool status = false;

    // Create export string

    QString exportString;
    QString sep = QChar(',');
    QString sep_replace = QChar(' ');
    QString endl = QChar('\n');

    // Capture comment, as commented out lines above the CSV content

    if (!comment.trimmed().isEmpty())
    {
        exportString += "# Capture comment:" + endl;
        const QStringList lines = comment.trimmed().split(QChar('\n'));
        for (const auto &line: lines)
        {
            exportString += "# " + line.trimmed() + endl;
        }
    }

    // Legend

    exportString += "Device Address" + sep + "Device Name";
    if (withManuf) exportString += sep + "Device Manufacturer";
    if (withComment) exportString += sep + "User Comment";
    if (withSeen) exportString += sep + "First Seen" + sep + "Last Seen";
    exportString += endl;

    // Device list /////////////////////////////////////////////////////////////

    SettingsManager *sm = SettingsManager::getInstance();
    bool filterShowBeacon = sm->getScanShowBeacon();
    bool filterShowBlacklisted = sm->getScanShowBlacklisted();
    bool filterShowCached = sm->getScanShowCached();
    bool filterShowBluetoothClassic = sm->getScanShowClassic();
    bool filterShowBluetoothLowEnergy = sm->getScanShowLowEnergy();

    const QString filterString = m_devices_filter->getFilterString();

    for (auto dd: std::as_const(m_devices_model->m_devices))
    {
        DeviceToolBLEx *d = qobject_cast<DeviceToolBLEx *>(dd);
        if (d)
        {
            bool accepted = true;

            if (exportMode == 2)
            {
                // Device currently shown on the list

                if (!filterShowBluetoothClassic && !filterShowBluetoothLowEnergy) accepted = false;
                else if (!filterShowBluetoothClassic && d->isBluetoothClassic() && !d->isBluetoothLowEnergy()) accepted = false;
                else if (!filterShowBluetoothLowEnergy && d->isBluetoothLowEnergy() && !d->isBluetoothClassic()) accepted = false;
                else if (!filterShowBeacon && d->isBeacon()) accepted = false;
                else if (!filterShowBlacklisted && d->isBlacklisted()) accepted = false;
                else if (!filterShowCached && d->isCached() && d->getRssi() == 0) accepted = false;

                if (accepted && !filterString.isEmpty())
                {
                    if (!d->getAddress().contains(filterString, Qt::CaseInsensitive) &&
                        !d->getName().contains(filterString, Qt::CaseInsensitive) &&
                        !d->getManufacturer().contains(filterString, Qt::CaseInsensitive))
                    {
                        accepted = false;
                    }
                }
            }
            else if (exportMode == 1)
            {
                // All devices found today (with an RSSI)

                if (d->getRssi() == 0) accepted = false;
            }
            else
            {
                // All devices
            }

            if (accepted)
            {
                // add device to the export string

                exportString += d->getAddr_display() + sep + d->getName_display().replace(sep, sep_replace, Qt::CaseSensitive);

                if (withManuf) exportString += sep + d->getManufacturer().replace(sep, sep_replace, Qt::CaseSensitive);
                if (withComment) exportString += sep + d->getUserComment().replace(sep, sep_replace, Qt::CaseSensitive);
                if (withSeen) exportString += sep + d->getFirstSeen().toString();
                if (withSeen) exportString += sep + d->getLastSeen().toString();

                exportString += endl;
            }
        }
    }

    // Save export string to file //////////////////////////////////////////////

    QString exportFilePath = filename;

    if (getExportFile(exportFilePath))
    {
        qDebug() << "DeviceManager::exportResults(" << exportFilePath << ")";

        // Open file and save content
        QFile efile(exportFilePath);
        if (efile.open(QFile::WriteOnly | QIODevice::Text))
        {
            QTextStream eout(&efile);
            eout.setEncoding(QStringConverter::Utf8);
            eout << exportString;

            status = true;
            efile.close();
        }
    }

    return status;
}

bool DeviceManager::getExportFile(QString &filename) const
{
    bool status = false;

    // No path given by the UI? Generate a "default" path
    if (filename.isEmpty())
    {
        filename = SettingsManager::getInstance()->getExportDirectory_str();
        filename += "/devicelist_";
        filename += QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm");
        filename += ".csv";
    }

    // Check if the directory exist, or try to create it
    QDir exportDirectory = QFileInfo(filename).dir();
    if (!exportDirectory.exists())
    {
        exportDirectory.mkpath(exportDirectory.path());
    }

    if (exportDirectory.exists())
    {
        status = true;
    }
    else
    {
        filename.clear();
        status = false;
    }

    return status;
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
                    qDebug() << "> queryDevice.exec() CAN'T, already exists";
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
    bool wasScanning = false;
    if (m_scanning || m_scanning_paused)
    {
        wasScanning = true;
        scanDevices_stop();
    }

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

    countDevices(); // stats
}

void DeviceManager::updateBoolFilters()
{
    m_devices_filter->updateBoolFilters();
    m_devices_filter->invalidatefilter();

    countDevices(); // stats
}

/* ************************************************************************** */
