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

#include "BleFormat.h"
#include "BleDescriptors.h"
#include "BleDescriptorInfo.h"

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>

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

    //Q_PROPERTY(QString properties READ getProperty NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList propertiesList READ getPropertyList NOTIFY characteristicChanged)
    //Q_PROPERTY(QString permissions READ getPermission NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList permissionsList READ getPermissionList NOTIFY characteristicChanged)

    Q_PROPERTY(bool readInProgress READ getReadInProgress NOTIFY statusChanged)
    Q_PROPERTY(bool writeInProgress READ getWriteInProgress NOTIFY statusChanged)
    Q_PROPERTY(bool notifyInProgress READ getNotifyInProgress NOTIFY statusChanged)
    Q_PROPERTY(bool readInError READ getReadInError NOTIFY statusChanged)
    Q_PROPERTY(bool writeInError READ getWriteInError NOTIFY statusChanged)
    Q_PROPERTY(bool notifyInError READ getNotifyInError NOTIFY statusChanged)

    Q_PROPERTY(int dataSize READ getDataSize NOTIFY valueChanged)
    Q_PROPERTY(QVariant data READ getData NOTIFY valueChanged)

    Q_PROPERTY(QString valueAscii READ getValueAscii NOTIFY valueChanged)
    Q_PROPERTY(QString valueHex READ getValueHex NOTIFY valueChanged)
    Q_PROPERTY(QStringList valueHex_list READ getValueHex_list NOTIFY valueChanged)
    Q_PROPERTY(QStringList valueAscii_list READ getValueAscii_list NOTIFY valueChanged)
    Q_PROPERTY(QStringList valueFormatted_list READ getValueFormatted_list NOTIFY valueChanged)

    /// Descriptors

    Q_PROPERTY(int descriptorsCount READ getDescriptorsCount NOTIFY characteristicChanged)
    Q_PROPERTY(QVariant descriptorsList READ getDescriptorsList NOTIFY characteristicChanged)

    // Client / Server Characteristic Configuration (0x2902 / 0x2903)
    Q_PROPERTY(bool notificationEnabled READ getNotificationEnabled NOTIFY characteristicChanged)
    Q_PROPERTY(bool indicationEnabled READ getIndicationEnabled NOTIFY characteristicChanged)
    Q_PROPERTY(bool broadcastEnabled READ getBroadcastEnabled NOTIFY characteristicChanged)

    // Characteristic Presentation Format (0x2904)
    Q_PROPERTY(bool hasPresentationFormat READ hasPresentationFormat NOTIFY characteristicChanged)
    Q_PROPERTY(int formatType READ getFormatType NOTIFY characteristicChanged)
    Q_PROPERTY(QString formatName READ getFormatName NOTIFY characteristicChanged)
    Q_PROPERTY(QString formatInfo READ getFormatInfo NOTIFY characteristicChanged)
    Q_PROPERTY(int formatExponent READ getFormatExponent NOTIFY characteristicChanged)
    Q_PROPERTY(QString formatUnit READ getFormatUnit NOTIFY characteristicChanged)
    Q_PROPERTY(QString formatNamespace READ getFormatNamespace NOTIFY characteristicChanged)
    Q_PROPERTY(QString formatDescription READ getFormatDescription NOTIFY characteristicChanged)
    Q_PROPERTY(int formatSize READ getFormatSize NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList formatsList READ getFormatsList NOTIFY characteristicChanged)

    // Characteristic Aggregate Format (0x2905)
    Q_PROPERTY(bool isAggregate READ isAggregate NOTIFY characteristicChanged)
    Q_PROPERTY(bool formatsResolved READ areFormatsResolved NOTIFY characteristicChanged)
    Q_PROPERTY(QStringList aggregateHandles READ getAggregateHandles NOTIFY characteristicChanged)

    // Valid Range (0x2906)
    Q_PROPERTY(bool hasValidRange READ hasValidRange NOTIFY characteristicChanged)
    Q_PROPERTY(QVariant min READ getMin NOTIFY characteristicChanged)
    Q_PROPERTY(QVariant max READ getMax NOTIFY characteristicChanged)
    Q_PROPERTY(QString validRange READ getValidRange NOTIFY characteristicChanged)

    // Valid Range and Accuracy (0x2911)
    Q_PROPERTY(bool hasValidRangeAndAccuracy READ hasValidRangeAndAccuracy NOTIFY characteristicChanged)
    Q_PROPERTY(QString validRangeAndAccuracy READ getValidRangeAndAccuracy NOTIFY characteristicChanged)

    QString m_name;
    QBluetoothUuid m_uuid;
    QStringList m_properties_str;
    QList <int> m_properties_enum;
    QStringList m_permissions; // TODO
    QByteArray m_data;

    bool m_read_inprogress = false;
    bool m_write_inprogress = false;
    bool m_notify_inprogress = false;

    bool m_read_inerror = false;
    bool m_write_inerror = false;
    bool m_notify_inerror = false;

    //! Every descriptor for this characteristic
    QList <QObject *> m_descriptors;

    //! Client Characteristic Configuration descriptor (0x2902)
    //! Beware: this is per-client state, and is often reported as 0 on Linux
    bool m_notify_enabled = false;
    bool m_indicate_enabled = false;

    //! Server Characteristic Configuration descriptor (0x2903)
    bool m_broadcast_enabled = false;

    //! Characteristic Presentation Format descriptor(s) (0x2904)
    //! More than one means the characteristic value is an aggregate (0x2905)
    QList <BleFormat::CharacteristicPresentationFormat> m_formats;

    //! Characteristic Aggregate Format descriptor (0x2905)
    //! Attribute handles of the presentation format descriptors, in value order
    bool m_has_aggregate = false;
    QList <quint16> m_aggregate_handles;

    //! The presentation format, if there is exactly one and the value is not an aggregate
    const BleFormat::CharacteristicPresentationFormat *singleFormat() const;

    //! Valid Range descriptor (0x2906), decoded using the presentation format
    QVariant m_min;
    QVariant m_max;

    //! Valid Range and Accuracy descriptor (0x2911)
    BleDescriptors::ValidRangeAndAccuracy m_valid_range_accuracy;

    //! Keep a descriptor, to be decoded by decodeDescriptors()
    void addDescriptor(const QBluetoothUuid &uuid, const QString &name, const QByteArray &dvalue);

    /*!
     * \brief Decode every descriptor, from scratch.
     *
     * Fills both the characteristic level information (formats, ranges, triggers...),
     * and the human readable fields of each DescriptorInfo.
     * Called after the discovery, and every time a descriptor value changes.
     */
    void decodeDescriptors();

    /*!
     * \brief Decode a descriptor that does not depend on the other descriptors.
     * \param di: the descriptor.
     * \return its human readable fields, empty for the context dependent or unknown descriptors.
     */
    QVariantList decodeDescriptor(const DescriptorInfo *di);

    /*!
     * \brief Decode a descriptor that depends on the presentation format,
     *        which may be declared *after* it (valid range, environmental sensing triggers).
     * \param di: the descriptor.
     * \param pf: the presentation format, nullptr if unknown or an aggregate.
     * \param fields: its human readable fields, only set if it is one of them.
     */
    void decodeContextDescriptor(const DescriptorInfo *di,
                                 const BleFormat::CharacteristicPresentationFormat *pf,
                                 QVariantList &fields);

    //! DEBUG // Give made up descriptors to every characteristic, to work on the UI
    void injectFakeDescriptors();

Q_SIGNALS:
    void characteristicChanged();
    void statusChanged();
    void valueChanged();

public:
    CharacteristicInfo(const QLowEnergyCharacteristic &characteristic_ble, QObject *parent);
    CharacteristicInfo(const QJsonObject &characteristic_cache, QObject *parent);

    void setCharacteristic(const QLowEnergyCharacteristic &characteristic_ble);
    void setCharacteristic(const QJsonObject &characteristic_cache);

    QString getName() const;
    QString getUuidFull() const;
    QString getUuidShort() const;

    QString getProperty() const; // TODO
    QStringList getPropertyList() const; // TODO

    QString getPermission() const; // TODO
    QStringList getPermissionList() const; // TODO

    void setReadInProgress(bool value);
    void setWriteInProgress(bool value);
    void setNotifyInProgress(bool value);
    bool getReadInProgress() const { return m_read_inprogress; };
    bool getWriteInProgress() const { return m_write_inprogress; };
    bool getNotifyInProgress() const { return m_notify_inprogress; };

    void setReadInError(bool value);
    void setWriteInError(bool value);
    void setNotifyInError(bool value);
    bool getReadInError() const { return m_read_inerror; };
    bool getWriteInError() const { return m_write_inerror; };
    bool getNotifyInError() const { return m_notify_inerror; };

    QVariant getData() const { return QVariant::fromValue(m_data); }
    int getDataSize() const { return m_data.size(); }

    QString getValueHex() const;
    QString getValueAscii() const;
    QStringList getValueHex_list() const;
    QStringList getValueAscii_list() const;

    /*!
     * \brief Characteristic value, decoded using its presentation format(s) (0x2904).
     * \return one string per decoded field, more than one for an aggregate,
     *         empty without presentation format or data (see BleFormat::readFormattedValues()).
     */
    QStringList getValueFormatted_list() const;

    void setValue(const QByteArray &v);

    /*!
     * \brief Update a descriptor value, after a descriptor read or write.
     * \param descriptor: the descriptor, matched by handle (or by UUID without live descriptor).
     * \param dvalue: its new value.
     */
    void updateDescriptor(const QLowEnergyDescriptor &descriptor, const QByteArray &dvalue);

    int getDescriptorsCount() const { return m_descriptors.count(); }
    QVariant getDescriptorsList() const;
    const QList <QObject *> getDescriptorsInfos() const { return m_descriptors; }

    // Characteristic Presentation Format (0x2904)
    bool hasPresentationFormat() const { return !m_formats.isEmpty(); }

    /*!
     * \brief GATT format type of the characteristic value (see BleFormat::FormatType).
     * \return the format, -1 without presentation format or for an aggregate.
     */
    int getFormatType() const;
    QString getFormatName() const;
    QString getFormatInfo() const;
    int getFormatExponent() const;
    QString getFormatUnit() const;
    QString getFormatNamespace() const;
    QString getFormatDescription() const;
    int getFormatSize() const;
    QStringList getFormatsList() const;

    // Characteristic Aggregate Format (0x2905)
    /*!
     * \brief Is the characteristic value made of more than one field?
     * \return true with more than one presentation format, or an aggregate format referencing more than one.
     *
     * The single format getters (getFormatName(), getFormatExponent()...) return nothing for aggregates.
     */
    bool isAggregate() const;
    /*!
     * \brief Are all the presentation formats of the value declared on this characteristic?
     * \return false if the aggregate format references more formats than this characteristic has.
     *
     * QtBluetooth does not expose attribute handles, so the aggregate format handles cannot be matched
     * to their presentation format descriptors. Local formats are assumed to be declared in value order,
     * and the value is not decoded when some of them are missing.
     */
    bool areFormatsResolved() const;
    QStringList getAggregateHandles() const;

    // Valid Range (0x2906)
    bool hasValidRange() const { return (m_min.isValid() && m_max.isValid()); }
    QVariant getMin() const { return m_min; }
    QVariant getMax() const { return m_max; }
    QString getValidRange() const;

    // Client / Server Characteristic Configuration (0x2902 / 0x2903)
    bool getNotificationEnabled() const { return m_notify_enabled; }
    bool getIndicationEnabled() const { return m_indicate_enabled; }
    bool getBroadcastEnabled() const { return m_broadcast_enabled; }

    // Valid Range and Accuracy (0x2911)
    bool hasValidRangeAndAccuracy() const { return m_valid_range_accuracy.valid; }
    QString getValidRangeAndAccuracy() const;
};

/* ************************************************************************** */
#endif // CHARACTERISTIC_INFO_H
