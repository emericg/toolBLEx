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
    Q_PROPERTY(int mode READ getBluetoothHostMode NOTIFY adapterUpdated)

    Q_PROPERTY(QString address READ getAddress CONSTANT)
    Q_PROPERTY(QString hostname READ getHostname CONSTANT)
    Q_PROPERTY(QString manufacturer READ getManufacturer CONSTANT)
    Q_PROPERTY(QString version READ getBluetoothVersion CONSTANT)

    bool m_default = false;
    QString m_address;
    QString m_hostname;
    QString m_mac_manufacturer;
    QString m_bluetooth_version;
    int m_bluetooth_host_mode = 0;

Q_SIGNALS:
    void adapterUpdated();

public:
    Adapter(const QBluetoothHostInfo &adapterInfo,
            bool inUse, int hostMode,
            QObject *parent = nullptr);

    ~Adapter() = default;

    bool isDefault() const { return m_default; }
    QString getAddress() const { return m_address; }
    QString getHostname() const { return m_hostname; }
    QString getManufacturer() const { return m_mac_manufacturer; }
    QString getBluetoothVersion() const { return m_bluetooth_version; }
    int getBluetoothHostMode() const { return m_bluetooth_host_mode; }

    void update(bool inUse, int hostMode);
};

/* ************************************************************************** */
#endif // ADAPTER_H
