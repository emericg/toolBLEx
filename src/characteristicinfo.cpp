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

#include "characteristicinfo.h"

#include <QBluetoothUuid>
#include <QByteArray>
#include <QJsonArray>
#include <QDebug>

/* ************************************************************************** */

CharacteristicInfo::CharacteristicInfo(const QLowEnergyCharacteristic &characteristic,
                                       QObject *parent) : QObject(parent)
{
    if (characteristic.isValid())
    {
        m_ble_characteristic = characteristic;
    }
}

CharacteristicInfo::CharacteristicInfo(const QJsonObject &characteristiccache,
                                       QObject *parent) : QObject(parent)
{
    if (!m_ble_characteristic.isValid())
    {
        m_characteristic_cache = characteristiccache;
    }
}

/* ************************************************************************** */

QLowEnergyCharacteristic CharacteristicInfo::getCharacteristic() const
{
    return m_ble_characteristic;
}

void CharacteristicInfo::setCharacteristic(const QLowEnergyCharacteristic &characteristic)
{
    if (characteristic.isValid())
    {
        // Make sure we won't use the cache
        m_characteristic_cache.empty();

        // Set the BLE characteristic
        m_ble_characteristic = characteristic;
        Q_EMIT characteristicChanged();
    }
}

/* ************************************************************************** */

QString CharacteristicInfo::getName() const
{
    QString name;

    if (m_ble_characteristic.isValid())
    {
        name = m_ble_characteristic.name();
        if (!name.isEmpty()) return name;

        // find descriptor with CharacteristicUserDescription
        const QList <QLowEnergyDescriptor> descriptors = m_ble_characteristic.descriptors();
        for (const QLowEnergyDescriptor &descriptor: descriptors)
        {
            if (descriptor.type() == QBluetoothUuid::DescriptorType::CharacteristicUserDescription)
            {
                name = descriptor.value();
                qDebug() << "- name from descriptor " << name;
                break;
            }
        }
    }
    else if (!m_characteristic_cache.isEmpty())
    {
        name = m_characteristic_cache[name].toString();
    }

    if (name.isEmpty())
    {
        name = QStringLiteral("Unknown Characteristic");
    }

    return name;
}

QString CharacteristicInfo::getUuid() const
{
    QBluetoothUuid uuid;

    if (m_ble_characteristic.isValid())
    {
        uuid = m_ble_characteristic.uuid();
    }
    else if (!m_characteristic_cache.isEmpty())
    {
        uuid = QBluetoothUuid(m_characteristic_cache["uuid"].toString());
    }

    bool success = false;

    quint16 result16 = uuid.toUInt16(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = uuid.toUInt32(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return uuid.toString().toUpper().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}

QString CharacteristicInfo::getUuidFull() const
{
    QBluetoothUuid uuid;

    if (m_ble_characteristic.isValid())
    {
        uuid = m_ble_characteristic.uuid();
    }
    else if (!m_characteristic_cache.isEmpty())
    {
        uuid = QBluetoothUuid(m_characteristic_cache["uuid"].toString());
    }

    return uuid.toString().toUpper();
}

QString CharacteristicInfo::getHandle() const
{
    return QString();
}

/* ************************************************************************** */

QString CharacteristicInfo::getProperty() const
{
    QString properties;

    if (m_ble_characteristic.isValid())
    {
        uint pflag = m_ble_characteristic.properties();

        if (pflag & QLowEnergyCharacteristic::Broadcasting)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("Broadcast");
        }
        if (pflag & QLowEnergyCharacteristic::Read)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("Read");
        }
        if (pflag & QLowEnergyCharacteristic::WriteNoResponse)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("WriteNoResp");
        }
        if (pflag & QLowEnergyCharacteristic::Write)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("Write");
        }
        if (pflag & QLowEnergyCharacteristic::Notify)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("Notify");
        }
        if (pflag & QLowEnergyCharacteristic::Indicate)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("Indicate");
        }
        if (pflag & QLowEnergyCharacteristic::WriteSigned)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("WriteSigned");
        }
        if (pflag & QLowEnergyCharacteristic::ExtendedProperty)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += QStringLiteral("ExtendedProperty");
        }
    }
    else if (!m_characteristic_cache.isEmpty())
    {
        QJsonArray props = m_characteristic_cache["properties"].toArray();
        for (const auto &p: props)
        {
            if (!properties.isEmpty()) properties += " / ";
            properties += p.toString();
        }
    }

    // TODO // Extended Properties
    // Queued Write
    // Writable Auxiliaries

    return properties;
}

QStringList CharacteristicInfo::getPropertyList() const
{
    QStringList plist;

    if (m_ble_characteristic.isValid())
    {
        uint pflag = m_ble_characteristic.properties();

        if (pflag & QLowEnergyCharacteristic::Broadcasting)
        {
            plist += QStringLiteral("Broadcast");
        }
        if (pflag & QLowEnergyCharacteristic::Read)
        {
            plist += QStringLiteral("Read");
        }
        if (pflag & QLowEnergyCharacteristic::WriteNoResponse)
        {
            plist += QStringLiteral("WriteNoResp");
        }
        if (pflag & QLowEnergyCharacteristic::Write)
        {
            plist += QStringLiteral("Write");
        }
        if (pflag & QLowEnergyCharacteristic::Notify)
        {
            plist += QStringLiteral("Notify");
        }
        if (pflag & QLowEnergyCharacteristic::Indicate)
        {
            plist += QStringLiteral("Indicate");
        }
        if (pflag & QLowEnergyCharacteristic::WriteSigned)
        {
            plist += QStringLiteral("WriteSigned");
        }
        if (pflag & QLowEnergyCharacteristic::ExtendedProperty)
        {
            plist += QStringLiteral("ExtendedProperty");
        }
    }
    else if (!m_characteristic_cache.isEmpty())
    {
        QJsonArray props = m_characteristic_cache["properties"].toArray();
        for (const auto &t: props)
        {
            plist += t.toString();
        }
    }

    // TODO // Extended Properties
    // Queued Write
    // Writable Auxiliaries

    return plist;
}

QString CharacteristicInfo::getPermission() const
{
    return QString();
}

QStringList CharacteristicInfo::getPermissionList() const
{
    return QStringList();
}

/* ************************************************************************** */

QString CharacteristicInfo::getValue() const
{
    // Show raw string first and hex value below
    QByteArray a = m_ble_characteristic.value();

    QString result;
    if (a.isEmpty())
    {
        result = QStringLiteral("<none>");
        return result;
    }

    result = a;
    result += QLatin1Char('\n');
    result += a.toHex();

    return result;
}

QString CharacteristicInfo::getValueStr() const
{
    QByteArray a = m_ble_characteristic.value();

    if (a.isEmpty())
    {
        return QStringLiteral("<none>");
    }

    return a;
}

QString CharacteristicInfo::getValueHex() const
{
    QByteArray a = m_ble_characteristic.value();

    if (a.isEmpty())
    {
        return QStringLiteral("<none>");
    }

    return a.toHex().toUpper();
}

/* ************************************************************************** */
