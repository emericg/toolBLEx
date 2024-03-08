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

#include "BleCharacteristicInfo.h"

#include <QBluetoothUuid>
#include <QByteArray>
#include <QJsonArray>
#include <QDebug>

/* ************************************************************************** */

CharacteristicInfo::CharacteristicInfo(const QLowEnergyCharacteristic &characteristic_ble,
                                       QObject *parent) : QObject(parent)
{
    setCharacteristic(characteristic_ble);
}

CharacteristicInfo::CharacteristicInfo(const QJsonObject &characteristic_cache,
                                       QObject *parent) : QObject(parent)
{
    setCharacteristic(characteristic_cache);
}

/* ************************************************************************** */

void CharacteristicInfo::setCharacteristic(const QLowEnergyCharacteristic &characteristic_ble)
{
    if (characteristic_ble.isValid())
    {
        m_name = characteristic_ble.name();
        m_uuid = characteristic_ble.uuid();

        // find descriptor with CharacteristicUserDescription
        const QList <QLowEnergyDescriptor> descriptors = characteristic_ble.descriptors();
        for (const QLowEnergyDescriptor &descriptor: descriptors)
        {
            if (descriptor.type() == QBluetoothUuid::DescriptorType::CharacteristicUserDescription)
            {
                m_name = descriptor.value();
                qDebug() << "- name from descriptor " << m_name;
                break;
            }
        }

        uint pflag = characteristic_ble.properties();
        if (pflag & QLowEnergyCharacteristic::Broadcasting)
        {
            m_properties += QStringLiteral("Broadcast");
        }
        if (pflag & QLowEnergyCharacteristic::Read)
        {
            m_properties += QStringLiteral("Read");
        }
        if (pflag & QLowEnergyCharacteristic::WriteNoResponse)
        {
            m_properties += QStringLiteral("WriteNoResp");
        }
        if (pflag & QLowEnergyCharacteristic::Write)
        {
            m_properties += QStringLiteral("Write");
        }
        if (pflag & QLowEnergyCharacteristic::Notify)
        {
            m_properties += QStringLiteral("Notify");
        }
        if (pflag & QLowEnergyCharacteristic::Indicate)
        {
            m_properties += QStringLiteral("Indicate");
        }
        if (pflag & QLowEnergyCharacteristic::WriteSigned)
        {
            m_properties += QStringLiteral("WriteSigned");
        }
        if (pflag & QLowEnergyCharacteristic::ExtendedProperty)
        {
            m_properties += QStringLiteral("ExtendedProperty");
        }

        m_data = characteristic_ble.value();
    }
}

void CharacteristicInfo::setCharacteristic(const QJsonObject &characteristic_cache)
{
    if (!characteristic_cache.isEmpty())
    {
        m_name = characteristic_cache["name"].toString();
        m_uuid = QBluetoothUuid(characteristic_cache["uuid"].toString());

        QJsonArray props = characteristic_cache["properties"].toArray();
        for (const auto &p: props)
        {
            m_properties += p.toString();
        }

        // value is not saved in the cache
    }
}

/* ************************************************************************** */

QString CharacteristicInfo::getName() const
{
    if (m_name.isEmpty())
    {
        return QStringLiteral("Unknown Characteristic");
    }

    return m_name;
}

QString CharacteristicInfo::getUuidFull() const
{
    return m_uuid.toString().toUpper();
}

QString CharacteristicInfo::getUuidShort() const
{
    bool success = false;

    quint16 result16 = m_uuid.toUInt16(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = m_uuid.toUInt32(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return m_uuid.toString().toUpper().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}

QString CharacteristicInfo::getHandle() const
{
    return QString();
}

/* ************************************************************************** */

QString CharacteristicInfo::getProperty() const
{
    QString properties;

    for (const auto &p: m_properties)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += p;
    }

    // TODO // Extended Properties
    // Queued Write
    // Writable Auxiliaries

    return properties;
}

QStringList CharacteristicInfo::getPropertyList() const
{
    // TODO // Extended Properties
    // Queued Write
    // Writable Auxiliaries

    return m_properties;
}

QString CharacteristicInfo::getPermission() const
{
/*
    Access Permissions

       Similar to file permissions, access permissions determine whether the client can read or write (or both) an attribute value (introduced in Value). Each attribute can have one of the following access permissions:

       None
           The attribute can neither be read nor written by a client.
       Readable
           The attribute can be read by a client.
       Writable
           The attribute can be written by a client.
       Readable and writable
           The attribute can be both read and written by the client.

   Encryption

       Determines whether a certain level of encryption is required for this attribute to be accessed by the client. (See Authentication, Security Modes and Procedures, and Security Modes for more information on authentication and encryption.) These are the allowed encryption permissions, as defined by GATT:

       No encryption required (Security Mode 1, Level 1)
           The attribute is accessible on a plain-text, non-encrypted connection.
       Unauthenticated encryption required (Security Mode 1, Level 2)
           The connection must be encrypted to access this attribute, but the encryption keys do not need to be authenticated (although they can be).
       Authenticated encryption required (Security Mode 1, Level 3)
           The connection must be encrypted with an authenticated key to access this attribute.

   Authorization

       Determines whether user permission (also known as authorization, as discussed in Security Modes and Procedures) is required to access this attribute. An attribute can choose only between requiring or not requiring authorization:

       No authorization required
           Access to this attribute does not require authorization.
       Authorization required
           Access to this attribute requires authorization.
*/
    return QString();
}

QStringList CharacteristicInfo::getPermissionList() const
{
    return QStringList();
}

/* ************************************************************************** */

void CharacteristicInfo::setReadInProgress(bool value)
{
    if (m_read_inprogress != value)
    {
        m_read_inprogress = value;
        if (m_read_inprogress) m_read_inerror = false;
        Q_EMIT statusChanged();
    }
}

void CharacteristicInfo::setWriteInProgress(bool value)
{
    if (m_write_inprogress != value)
    {
        m_write_inprogress = value;
        if (m_write_inprogress) m_write_inerror = false;
        Q_EMIT statusChanged();
    }
}

void CharacteristicInfo::setNotifyInProgress(bool value)
{
    if (m_notify_inprogress != value)
    {
        m_notify_inprogress = value;
        if (m_notify_inprogress) m_notify_inerror = false;
        Q_EMIT statusChanged();
    }
}

void CharacteristicInfo::setReadInError(bool value)
{
    if (m_read_inerror != value)
    {
        m_read_inerror = value;
        if (m_read_inerror) m_read_inprogress = false;
        Q_EMIT statusChanged();
    }
}

void CharacteristicInfo::setWriteInError(bool value)
{
    if (m_write_inerror != value)
    {
        m_write_inerror = value;
        if (m_write_inerror) m_write_inprogress = false;
        Q_EMIT statusChanged();
    }
}

void CharacteristicInfo::setNotifyInError(bool value)
{
    if (m_notify_inerror != value)
    {
        m_notify_inerror = value;
        if (m_notify_inerror) m_notify_inprogress = false;
        Q_EMIT statusChanged();
    }
}

/* ************************************************************************** */

QString CharacteristicInfo::getValue() const
{
    // Show raw string first and hex value below
    QString result;

    if (m_data.isEmpty())
    {
        result = QStringLiteral("<none>");
        return result;
    }

    result = m_data;
    result += QLatin1Char('\n');
    result += m_data.toHex();

    return result;
}

QString CharacteristicInfo::getValueHex() const
{
    if (m_data.isEmpty())
    {
        return QStringLiteral("<none>");
    }

    return m_data.toHex().toUpper();
}

QString CharacteristicInfo::getValueAscii() const
{
    if (m_data.isEmpty())
    {
        return QStringLiteral("<none>");
    }

    return m_data;
}

QStringList CharacteristicInfo::getValueHex_list() const
{
    QStringList out;
    for (int i = 0; i < m_data.size(); i++)
    {
        QByteArray duo; duo += m_data.at(i);
        out += duo.toHex();
    }
    return out;
}

QStringList CharacteristicInfo::getValueAscii_list() const
{
    QStringList out;
    for (int i = 0; i < m_data.size(); i++)
    {
        QByteArray duo; duo += m_data.at(i);
        out += QString::fromStdString(duo.toStdString());
    }
    return out;
}

/* ************************************************************************** */

void CharacteristicInfo::setValue(const QByteArray &v)
{
    m_data = v;
    Q_EMIT valueChanged();
}

/* ************************************************************************** */
