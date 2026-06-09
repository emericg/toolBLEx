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

    Q_PROPERTY(bool isDefault READ isDefault NOTIFY adapterUpdated)
    Q_PROPERTY(bool isInUse READ isInUse NOTIFY adapterUpdated)
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

    bool m_default = false;
    bool m_inUse = false;

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

public:
    Adapter(const QBluetoothHostInfo &adapterInfo, QObject *parent = nullptr);
    ~Adapter();

    bool checkAdapter();
    void update(bool isDefault, int inUse);

    bool isDefault() const { return m_default; }
    void setDefault(bool isDefault);

    bool isInUse() const { return m_inUse; }
    void setInUse(bool inUse);

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
