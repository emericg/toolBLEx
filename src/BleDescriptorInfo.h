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

#ifndef DESCRIPTOR_INFO_H
#define DESCRIPTOR_INFO_H
/* ************************************************************************** */

#include "BleFormat.h"
#include "BleDescriptors.h"

#include <QObject>
#include <QString>
#include <QVariant>
#include <QVariantList>
#include <QByteArray>
#include <QBluetoothUuid>
#include <QLowEnergyDescriptor>

/* ************************************************************************** */

/*!
 * A characteristic descriptor, decoded or not, with its raw value.
 * The decoding of the known descriptors is done by the CharacteristicInfo,
 * which also fills the human readable fields of each descriptor.
 */
class DescriptorInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ getName NOTIFY descriptorChanged)
    Q_PROPERTY(QString uuid READ getUuidFull NOTIFY descriptorChanged)
    Q_PROPERTY(QString uuid_full READ getUuidFull NOTIFY descriptorChanged)
    Q_PROPERTY(QString uuid_short READ getUuidShort NOTIFY descriptorChanged)

    Q_PROPERTY(int dataSize READ getDataSize NOTIFY valueChanged)
    Q_PROPERTY(QVariant data READ getData NOTIFY valueChanged)
    Q_PROPERTY(QString valueHex READ getValueHex NOTIFY valueChanged)
    Q_PROPERTY(QString valueAscii READ getValueAscii NOTIFY valueChanged)

    Q_PROPERTY(QVariantList fields READ getFields NOTIFY fieldsChanged)

    Q_PROPERTY(bool readable READ isReadable NOTIFY descriptorChanged)
    Q_PROPERTY(bool readInProgress READ getReadInProgress NOTIFY statusChanged)
    Q_PROPERTY(bool readInError READ getReadInError NOTIFY statusChanged)

    QBluetoothUuid m_uuid;
    QString m_name;
    QByteArray m_data;

    //! The live descriptor, invalid when it comes from the cache (or is made up)
    QLowEnergyDescriptor m_descriptor;

    //! Decoded value, as a list of { "label", "value" } maps
    QVariantList m_fields;

    bool m_read_inprogress = false;
    bool m_read_inerror = false;

Q_SIGNALS:
    void descriptorChanged();
    void valueChanged();
    void fieldsChanged();
    void statusChanged();

public:
    DescriptorInfo(const QBluetoothUuid &uuid, const QString &name,
                   const QByteArray &value, QObject *parent);
    DescriptorInfo(const QLowEnergyDescriptor &descriptor, QObject *parent);

    const QLowEnergyDescriptor &getDescriptor() const { return m_descriptor; }
    bool isReadable() const { return m_descriptor.isValid(); }

    const QBluetoothUuid &getUuid() const { return m_uuid; }
    quint16 getUuid16(bool *ok = nullptr) const { return m_uuid.toUInt16(ok); }

    QString getName() const;
    const QString &getNameRaw() const { return m_name; }
    QString getUuidFull() const { return m_uuid.toString().toUpper(); }
    QString getUuidShort() const { return BleFormat::uuidShort(m_uuid); }

    const QByteArray &getValue() const { return m_data; }
    QVariant getData() const { return QVariant::fromValue(m_data); }
    int getDataSize() const { return m_data.size(); }
    QString getValueHex() const;
    QString getValueAscii() const;

    void setValue(const QByteArray &v);

    const QVariantList &getFields() const { return m_fields; }
    void setFields(const QVariantList &fields);

    void setReadInProgress(bool value);
    void setReadInError(bool value);
    bool getReadInProgress() const { return m_read_inprogress; }
    bool getReadInError() const { return m_read_inerror; }
};

/* ************************************************************************** */
#endif // DESCRIPTOR_INFO_H
