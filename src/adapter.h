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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef ADAPTER_H
#define ADAPTER_H
/* ************************************************************************** */

#include "AdapterDetails.h"

#include <QObject>
#include <QVariant>

#include <QBluetoothHostInfo>
#include <QBluetoothLocalDevice>

class AdapterInfo;

/* ************************************************************************** */

class Adapter: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isDefault_scan READ isDefault_scan NOTIFY adapterUpdated)
    Q_PROPERTY(bool isDefault_sim READ isDefault_sim NOTIFY adapterUpdated)
    Q_PROPERTY(bool isInUse_scan READ isInUse_scan NOTIFY adapterUpdated)
    Q_PROPERTY(bool isInUse_sim READ isInUse_sim NOTIFY adapterUpdated)
    Q_PROPERTY(int hostMode READ getBluetoothHostMode NOTIFY adapterUpdated)

    Q_PROPERTY(QString address READ getAddressString CONSTANT)
    Q_PROPERTY(QString hostname READ getHostname NOTIFY adapterUpdated)
    Q_PROPERTY(QString chipset READ getChipset NOTIFY adapterUpdated)
    Q_PROPERTY(QString chipsetFirmware READ getChipsetFirmware NOTIFY adapterUpdated)
    Q_PROPERTY(QString manufacturer READ getManufacturer NOTIFY adapterUpdated)
    Q_PROPERTY(QString manufacturerMac READ getManufacturerMac CONSTANT)
    Q_PROPERTY(QString bluetoothVersion READ getBluetoothVersion NOTIFY adapterUpdated)
    Q_PROPERTY(QStringList bluetoothFeatures READ getBluetoothFeatures NOTIFY adapterUpdated)
    Q_PROPERTY(QString systemName READ getSystemName NOTIFY adapterUpdated)

    Q_PROPERTY(QStringList roles READ getRoles NOTIFY adapterUpdated)
    Q_PROPERTY(QStringList phys READ getPhys NOTIFY adapterUpdated)
    Q_PROPERTY(bool centralRole READ isCentralRole NOTIFY adapterUpdated)
    Q_PROPERTY(bool peripheralRole READ isPeripheralRole NOTIFY adapterUpdated)
    Q_PROPERTY(int maxAdvertisingLength READ getMaxAdvertisingLength NOTIFY adapterUpdated)
    Q_PROPERTY(int maxScanResponseLength READ getMaxScanResponseLength NOTIFY adapterUpdated)
    Q_PROPERTY(int advertisingInstances READ getAdvertisingInstances NOTIFY adapterUpdated)
    Q_PROPERTY(int activeAdvertisingInstances READ getActiveAdvertisingInstances NOTIFY adapterUpdated)
    Q_PROPERTY(QVariant txPowerMin READ getTxPowerMin NOTIFY adapterUpdated)
    Q_PROPERTY(QVariant txPowerMax READ getTxPowerMax NOTIFY adapterUpdated)

    QBluetoothLocalDevice *m_adapter_device = nullptr;
    int m_bluetooth_host_mode = 0;

    bool m_available = true;        //!< listed by the system (plugged in)

    bool m_default_scan = false;    //!< preferred adapter for scanning
    bool m_default_sim = false;     //!< preferred adapter for the simulator
    bool m_inUse_scan = false;           //!< used for scanning
    bool m_inUse_sim = false;       //!< used by the simulator

    QBluetoothAddress m_address;
    QString m_hostname;
    QString m_system_name;          //!< system name, when different from the hostname (alias)
    QString m_chipset;
    QString m_manufacturer;
    QString m_mac_manufacturer;
    QStringList m_bluetooth_features;

    AdapterInfo *m_info = nullptr;  //!< platform backend, nullptr if the platform has none
    AdapterDetails m_details;

    void setHostMode(int hostMode);

    /*!
     * \brief Generate the feature tags shown by AdapterWidget, from the adapter details.
     *
     * Roles and PHYs are not included, see getRoles() and getPhys().
     */
    QStringList generateFeatures() const;

private slots:
    void hostModeStateChanged(QBluetoothLocalDevice::HostMode state);
    void deviceConnected(const QBluetoothAddress &address);
    void deviceDisconnected(const QBluetoothAddress &address);
    void pairingFinished(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing);
    void errorOccurred(QBluetoothLocalDevice::Error error);
    void detailsChanged(const AdapterDetails &details);

Q_SIGNALS:
    void adapterUpdated();

    /*!
     * \brief Emitted when the underlying QBluetoothLocalDevice has been replaced.
     *
     * The previous device has been deleted, pointers obtained through getDevice() must be refreshed.
     */
    void deviceChanged();

public:
    Adapter(const QBluetoothHostInfo &adapterInfo, QObject *parent = nullptr);
    ~Adapter();

    /*!
     * \brief Check the underlying QBluetoothLocalDevice, and recreate it if it is invalid.
     * \param force: recreate the device even if it is valid.
     * \return true if the adapter is valid (plugged in and usable).
     *
     * Adapter objects are kept when unplugged, as adapters usually reappear.
     * Recreating the device is how a re-plugged adapter is picked up again.
     */
    bool checkAdapter(bool force = false);

    QBluetoothLocalDevice *getDevice() const { return m_adapter_device; }
    bool isValid() const { return (m_available && m_adapter_device && m_adapter_device->isValid()); }

    /*!
     * \brief Check if the adapter is usable right away.
     * \return true if the adapter is valid, and not powered off.
     */
    bool isPoweredOn() const { return (isValid() && m_adapter_device->hostMode() != QBluetoothLocalDevice::HostPoweredOff); }

    /*!
     * \brief Set if the adapter is listed by the system.
     * \param available: false when unplugged, true when plugged back in.
     *
     * An unplugged adapter is reported as powered off, and its device is left alone.
     * A re-plugged adapter gets a new device.
     */
    void setAvailable(bool available);
    bool isAvailable() const { return m_available; }

    bool isDefault_scan() const { return m_default_scan; }
    void setDefault_scan(bool isDefault);

    bool isDefault_sim() const { return m_default_sim; }
    void setDefault_sim(bool isDefault);

    bool isInUse_scan() const { return m_inUse_scan; }
    void setInUse_scan(bool inUse);

    bool isInUse_sim() const { return m_inUse_sim; }
    void setInUse_sim(bool inUse);

    const QBluetoothAddress &getAddress() const { return m_address; }
    QString getAddressString() const { return m_address.toString(); }
    const QString &getHostname() const { return m_hostname; }
    const QString &getSystemName() const { return m_system_name; }
    const QString &getChipset() const { return m_chipset; }
    const QString &getChipsetFirmware() const { return m_details.chipsetFirmware; }
    const QString &getManufacturer() const { return m_manufacturer; }
    const QString &getManufacturerMac() const { return m_mac_manufacturer; }
    const QString &getBluetoothVersion() const { return m_details.coreVersion; }
    const QStringList &getBluetoothFeatures() const { return m_bluetooth_features; }
    int getBluetoothHostMode() const { return m_bluetooth_host_mode; }

    const AdapterDetails &getDetails() const { return m_details; }

    /*!
     * \brief Supported LE roles, as tags: "Central", "Peripheral".
     */
    QStringList getRoles() const;
    const QStringList &getPhys() const { return m_details.phys; }
    bool isCentralRole() const { return m_details.centralRole.value_or(false); }
    bool isPeripheralRole() const { return m_details.peripheralRole.value_or(false); }
    int getMaxAdvertisingLength() const { return m_details.maxAdvertisingLength; }
    int getMaxScanResponseLength() const { return m_details.maxScanResponseLength; }
    int getAdvertisingInstances() const { return m_details.advertisingInstances; }
    int getActiveAdvertisingInstances() const { return m_details.activeAdvertisingInstances; }

    /*!
     * \brief Advertising TX power range, in dBm.
     * \return The value, or an invalid QVariant (undefined in QML) when unknown.
     */
    QVariant getTxPowerMin() const { return m_details.txPowerMin ? QVariant(*m_details.txPowerMin) : QVariant(); }
    QVariant getTxPowerMax() const { return m_details.txPowerMax ? QVariant(*m_details.txPowerMax) : QVariant(); }
};

/* ************************************************************************** */
#endif // ADAPTER_H
