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
#include <QDebug>

/* ************************************************************************** */

CharacteristicInfo::CharacteristicInfo(const QLowEnergyCharacteristic &characteristic):
    m_characteristic(characteristic)
{
    //
}

void CharacteristicInfo::setCharacteristic(const QLowEnergyCharacteristic &characteristic)
{
    m_characteristic = characteristic;
    Q_EMIT characteristicChanged();
}

/* ************************************************************************** */

QLowEnergyCharacteristic CharacteristicInfo::getCharacteristic() const
{
    return m_characteristic;
}

QString CharacteristicInfo::getName() const
{
    QString name = m_characteristic.name();
    if (!name.isEmpty()) return name;
/*
    // QT6 // find descriptor with CharacteristicUserDescription
    const QList<QLowEnergyDescriptor> descriptors = m_characteristic.descriptors();
    for (const QLowEnergyDescriptor &descriptor : descriptors) {
        if (descriptor.type() == QBluetoothUuid::CharacteristicUserDescription) {
            name = descriptor.value();
            break;
        }
    }
*/
    if (name.isEmpty())
        name = "Unknown Characteristic";

    return name;
}

QString CharacteristicInfo::getUuid() const
{
    const QBluetoothUuid uuid = m_characteristic.uuid();

    bool success = false;

    quint16 result16 = uuid.toUInt16(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = uuid.toUInt32(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return uuid.toString().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}

QString CharacteristicInfo::getUuidFull() const
{
    return m_characteristic.uuid().toString();
}

QString CharacteristicInfo::getHandle() const
{
    QByteArray v;
    //v.setNum(m_characteristic.handle());
    const quint8 *data = reinterpret_cast<const quint8 *>(v.constData());
/*
    qDebug() << "- size " << v.size();
    qDebug() << "- part1 " << QString::number(data[1], 16).rightJustified(2, '0', false);
    qDebug() << "- part0 " << QString::number(data[0], 16).rightJustified(2, '0', false);
*/
    if (v.size() == 1 || data[1] == 0)
        return QStringLiteral("0x") +
                QString::number(data[0], 16).rightJustified(2, '0', false);

    return QStringLiteral("0x") +
            QString::number(data[1], 16).rightJustified(2, '0', false) +
            QString::number(data[0], 16).rightJustified(2, '0', false);
}

QString CharacteristicInfo::getPermission() const
{
    uint permission = m_characteristic.properties();
    QString properties;

    if (permission & QLowEnergyCharacteristic::Read)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("Read");
    }
    if (permission & QLowEnergyCharacteristic::Write)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("Write");
    }
    if (permission & QLowEnergyCharacteristic::Notify)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("Notify");
    }
    if (permission & QLowEnergyCharacteristic::Indicate)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("Indicate");
    }
    if (permission & QLowEnergyCharacteristic::ExtendedProperty)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("ExtendedProperty");
    }
    if (permission & QLowEnergyCharacteristic::Broadcasting)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("Broadcast");
    }
    if (permission & QLowEnergyCharacteristic::WriteNoResponse)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("WriteNoResp");
    }
    if (permission & QLowEnergyCharacteristic::WriteSigned)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += QStringLiteral("WriteSigned");
    }

    return properties;
}

QStringList CharacteristicInfo::getPermissionList() const
{
    uint permission = m_characteristic.properties();
    QStringList properties;

    if (permission & QLowEnergyCharacteristic::Read)
    {
        properties += QStringLiteral("Read");
    }
    if (permission & QLowEnergyCharacteristic::Write)
    {
        properties += QStringLiteral("Write");
    }
    if (permission & QLowEnergyCharacteristic::Notify)
    {
        properties += QStringLiteral("Notify");
    }
    if (permission & QLowEnergyCharacteristic::Indicate)
    {
        properties += QStringLiteral("Indicate");
    }
    if (permission & QLowEnergyCharacteristic::ExtendedProperty)
    {
        properties += QStringLiteral("ExtendedProperty");
    }
    if (permission & QLowEnergyCharacteristic::Broadcasting)
    {
        properties += QStringLiteral("Broadcast");
    }
    if (permission & QLowEnergyCharacteristic::WriteNoResponse)
    {
        properties += QStringLiteral("WriteNoResp");
    }
    if (permission & QLowEnergyCharacteristic::WriteSigned)
    {
        properties += QStringLiteral("WriteSigned");
    }

    return properties;
}

QString CharacteristicInfo::getValue() const
{
    // Show raw string first and hex value below
    QByteArray a = m_characteristic.value();

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
    // Show raw string first and hex value below
    QByteArray a = m_characteristic.value();

    QString result;
    if (a.isEmpty())
    {
        result = QStringLiteral("<none>");
        return result;
    }

    result = a;

    return result;
}

QString CharacteristicInfo::getValueHex() const
{
    // Show raw string first and hex value below
    QByteArray a = m_characteristic.value();

    QString result;
    if (a.isEmpty())
    {
        result = QStringLiteral("<none>");
        return result;
    }

    result = a.toHex().toUpper();

    return result;
}

/* ************************************************************************** */
