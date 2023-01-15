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
#include <QStringList>

#include <QLowEnergyCharacteristic>
#include <QJsonObject>

/* ************************************************************************** */

class CharacteristicInfo: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName NOTIFY characteristicChanged)
    Q_PROPERTY(QString uuid READ getUuidFull NOTIFY characteristicChanged)
    Q_PROPERTY(QString uuid_full READ getUuidFull NOTIFY characteristicChanged)
    Q_PROPERTY(QString uuid_short READ getUuidShort NOTIFY characteristicChanged)
    Q_PROPERTY(QString properties READ getProperty NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList propertiesList READ getPropertyList NOTIFY characteristicChanged)
    Q_PROPERTY(QString permissions READ getPermission NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList permissionsList READ getPermissionList NOTIFY characteristicChanged)

    Q_PROPERTY(bool readInProgress READ getReadInProgress NOTIFY valueChanged)
    Q_PROPERTY(bool writeInProgress READ getWriteInProgress NOTIFY valueChanged)
    Q_PROPERTY(bool notifyInProgress READ getNotifyInProgress NOTIFY valueChanged)

    Q_PROPERTY(QString valueStr READ getValueStr NOTIFY valueChanged)
    Q_PROPERTY(QString valueHex READ getValueHex NOTIFY valueChanged)

    QString m_name;
    QBluetoothUuid m_uuid;
    QStringList m_properties;
    QStringList m_permissions; // TODO
    QByteArray m_value;

    bool m_read_inprogress = false;
    bool m_write_inprogress = false;
    bool m_notify_inprogress = false;

Q_SIGNALS:
    void characteristicChanged();
    void valueChanged();

public:
    CharacteristicInfo(const QLowEnergyCharacteristic &characteristic_ble, QObject *parent);
    CharacteristicInfo(const QJsonObject &characteristic_cache, QObject *parent);

    void setCharacteristic(const QLowEnergyCharacteristic &characteristic_ble);
    void setCharacteristic(const QJsonObject &characteristic_cache);

    QString getName() const;
    QString getUuidFull() const;
    QString getUuidShort() const;
    QString getHandle() const; // TODO // deprecated?

    QString getProperty() const;
    QStringList getPropertyList() const;

    QString getPermission() const;
    QStringList getPermissionList() const; // TODO

    bool getReadInProgress() const { return m_read_inprogress; };
    bool getWriteInProgress() const { return m_write_inprogress; };
    bool getNotifyInProgress() const { return m_notify_inprogress; };

    QString getValue() const;
    QString getValueStr() const;
    QString getValueHex() const;

    void setValue(const QByteArray &v);
};

/* ************************************************************************** */
#endif // CHARACTERISTIC_INFO_H
