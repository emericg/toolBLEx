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

#ifndef CHARACTERISTIC_INFO_H
#define CHARACTERISTIC_INFO_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QtBluetooth/QLowEnergyCharacteristic>

/* ************************************************************************** */

class CharacteristicInfo: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString characteristicName READ getName NOTIFY characteristicChanged)
    Q_PROPERTY(QString characteristicUuid READ getUuid NOTIFY characteristicChanged)
    Q_PROPERTY(QString characteristicUuidFull READ getUuidFull NOTIFY characteristicChanged)
    Q_PROPERTY(QString characteristicHandle READ getHandle NOTIFY characteristicChanged)
    Q_PROPERTY(QString characteristicPermission READ getPermission NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList characteristicPermissionList READ getPermissionList NOTIFY characteristicChanged)

    Q_PROPERTY(QString characteristicValueStr READ getValueStr NOTIFY characteristicChanged)
    Q_PROPERTY(QString characteristicValueHex READ getValueHex NOTIFY characteristicChanged)

    QLowEnergyCharacteristic m_characteristic;

Q_SIGNALS:
    void characteristicChanged();

public:
    CharacteristicInfo() = default;
    CharacteristicInfo(const QLowEnergyCharacteristic &characteristic);

    void setCharacteristic(const QLowEnergyCharacteristic &characteristic);
    QLowEnergyCharacteristic getCharacteristic() const;

    QString getName() const;
    QString getUuid() const;
    QString getUuidFull() const;
    QString getHandle() const;
    QString getPermission() const;
    QStringList getPermissionList() const;

    QString getValue() const;
    QString getValueStr() const;
    QString getValueHex() const;
};

/* ************************************************************************** */
#endif // CHARACTERISTIC_INFO_H
