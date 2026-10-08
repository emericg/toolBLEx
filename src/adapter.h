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

#include <QObject>

#include <QBluetoothHostInfo>
#include <QBluetoothLocalDevice>

/* ************************************************************************** */

class Adapter: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isDefault_scan READ isDefault_scan NOTIFY adapterUpdated)
    Q_PROPERTY(bool isDefault_sim READ isDefault_sim NOTIFY adapterUpdated)
    Q_PROPERTY(bool isInUse_scan READ isInUse_scan NOTIFY adapterUpdated)
    Q_PROPERTY(bool isInUse_sim READ isInUse_sim NOTIFY adapterUpdated)
    Q_PROPERTY(int hostMode READ getBluetoothHostMode NOTIFY adapterUpdated)

    Q_PROPERTY(QString address READ getAddress CONSTANT)
    Q_PROPERTY(QString hostname READ getHostname CONSTANT)
    Q_PROPERTY(QString chipset READ getChipset CONSTANT)
    Q_PROPERTY(QString chipsetFirmware READ getChipsetFirmware CONSTANT)
    Q_PROPERTY(QString manufacturer READ getManufacturer CONSTANT)
    Q_PROPERTY(QString manufacturerMac READ getManufacturerMac CONSTANT)
    Q_PROPERTY(QString bluetoothVersion READ getBluetoothVersion CONSTANT)
    Q_PROPERTY(QStringList bluetoothFeatures READ getBluetoothFeatures CONSTANT)

    QBluetoothLocalDevice *m_adapter_device = nullptr;
    int m_bluetooth_host_mode = 0;

    bool m_available = true;        //!< listed by the system (plugged in)

    bool m_default_scan = false;    //!< preferred adapter for scanning
    bool m_default_sim = false;     //!< preferred adapter for the simulator
    bool m_inUse_scan = false;           //!< used for scanning
    bool m_inUse_sim = false;       //!< used by the simulator

    QString m_address;
    QString m_hostname;
    QString m_chipset;
    QString m_chipset_firmware;
    QString m_manufacturer;
    QString m_mac_manufacturer;
    QString m_bluetooth_version;
    QStringList m_bluetooth_features;

    void setHostMode(int hostMode);

private slots:
    void hostModeStateChanged(QBluetoothLocalDevice::HostMode state);
    void deviceConnected(const QBluetoothAddress &address);
    void deviceDisconnected(const QBluetoothAddress &address);
    void pairingFinished(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing);
    void errorOccurred(QBluetoothLocalDevice::Error error);

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

    const QString &getAddress() const { return m_address; }
    const QString &getHostname() const { return m_hostname; }
    const QString &getChipset() const { return m_chipset; }
    const QString &getChipsetFirmware() const { return m_chipset_firmware; }
    const QString &getManufacturer() const { return m_manufacturer; }
    const QString &getManufacturerMac() const { return m_mac_manufacturer; }
    const QString &getBluetoothVersion() const { return m_bluetooth_version; }
    const QStringList &getBluetoothFeatures() const { return m_bluetooth_features; }
    int getBluetoothHostMode() const { return m_bluetooth_host_mode; }
};

/* ************************************************************************** */
#endif // ADAPTER_H
