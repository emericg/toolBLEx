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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "BleDescriptorInfo.h"

/* ************************************************************************** */

DescriptorInfo::DescriptorInfo(const QBluetoothUuid &uuid, const QString &name,
                               const QByteArray &value, QObject *parent) : QObject(parent)
{
    m_uuid = uuid;
    m_name = name;
    m_data = value;
}

DescriptorInfo::DescriptorInfo(const QLowEnergyDescriptor &descriptor, QObject *parent) :
    DescriptorInfo(descriptor.uuid(), descriptor.name(), descriptor.value(), parent)
{
    m_descriptor = descriptor;
}

/* ************************************************************************** */

QString DescriptorInfo::getName() const
{
    if (!m_name.isEmpty()) return m_name;

    // QBluetoothUuid::DescriptorType is incomplete, so Qt has no name for
    // some of the descriptors we may encounter...

    bool uuid16 = false;
    const quint16 duuid = m_uuid.toUInt16(&uuid16);
    if (uuid16) return BleDescriptors::descriptorToString(duuid);

    return QStringLiteral("Unknown Descriptor");
}

/* ************************************************************************** */

QString DescriptorInfo::getValueHex() const
{
    return QString::fromLatin1(m_data.toHex().toUpper());
}

QString DescriptorInfo::getValueAscii() const
{
    return QString::fromUtf8(m_data);
}

void DescriptorInfo::setValue(const QByteArray &v)
{
    m_data = v;
    Q_EMIT valueChanged();
}

/* ************************************************************************** */

void DescriptorInfo::setFields(const QVariantList &fields)
{
    if (m_fields != fields)
    {
        m_fields = fields;
        Q_EMIT fieldsChanged();
    }
}

/* ************************************************************************** */

void DescriptorInfo::setReadInProgress(bool value)
{
    if (m_read_inprogress != value)
    {
        m_read_inprogress = value;
        if (m_read_inprogress) m_read_inerror = false;
        Q_EMIT statusChanged();
    }
}

void DescriptorInfo::setReadInError(bool value)
{
    if (m_read_inerror != value)
    {
        m_read_inerror = value;
        if (m_read_inerror) m_read_inprogress = false;
        Q_EMIT statusChanged();
    }
}

/* ************************************************************************** */
