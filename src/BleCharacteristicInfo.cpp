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
#include <QVariantMap>
#include <QDebug>

/* ************************************************************************** */

//! Human readable summary of a presentation format, ex: "sint16 x10^-2 / Celsius temperature (degree Celsius) / outside"
static QString formatSummary(const BleFormat::CharacteristicPresentationFormat &pf)
{
    QString summary = BleFormat::formatToString(pf.format);

    if (pf.exponent != 0)
    {
        summary += QStringLiteral(" x10^") + QString::number(pf.exponent);
    }
    if (pf.unit)
    {
        summary += QStringLiteral(" / ") + BleFormat::unitToString(pf.unit);
    }
    if (pf.desc)
    {
        summary += QStringLiteral(" / ") + BleFormat::descriptionToString(pf.nnamespace, pf.desc);
    }

    return summary;
}

//! One human readable field of a descriptor, for DescriptorInfo::setFields()
static QVariantMap descriptorField(const QString &label, const QString &value)
{
    return QVariantMap{ { QStringLiteral("label"), label }, { QStringLiteral("value"), value } };
}

//! Enabled / disabled, for the configuration bits
static QString enabledToString(const bool enabled)
{
    return enabled ? QStringLiteral("enabled") : QStringLiteral("disabled");
}

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

        // Check characteristic properties
        uint pflag = characteristic_ble.properties();
        if (pflag & QLowEnergyCharacteristic::Broadcasting)
        {
            m_properties_str += QStringLiteral("Broadcast");
        }
        if (pflag & QLowEnergyCharacteristic::Read)
        {
            m_properties_str += QStringLiteral("Read");
        }
        if (pflag & QLowEnergyCharacteristic::WriteNoResponse)
        {
            m_properties_str += QStringLiteral("WriteNoResp");
        }
        if (pflag & QLowEnergyCharacteristic::Write)
        {
            m_properties_str += QStringLiteral("Write");
        }
        if (pflag & QLowEnergyCharacteristic::Notify)
        {
            m_properties_str += QStringLiteral("Notify");
        }
        if (pflag & QLowEnergyCharacteristic::Indicate)
        {
            m_properties_str += QStringLiteral("Indicate");
        }
        if (pflag & QLowEnergyCharacteristic::WriteSigned)
        {
            m_properties_str += QStringLiteral("WriteSigned");
        }
        if (pflag & QLowEnergyCharacteristic::ExtendedProperty)
        {
            m_properties_str += QStringLiteral("ExtendedProperty");
        }

        // Check characteristic descriptors
        const QList <QLowEnergyDescriptor> descriptors = characteristic_ble.descriptors();
        for (const QLowEnergyDescriptor &descriptor: descriptors)
        {
            //qDebug() << "- descriptor TYPE " << descriptor.type() << " NAME " << descriptor.name() << " UUID " << descriptor.uuid();
            //qDebug() << "- descriptor VALUE" << descriptor.value();

            m_descriptors += new DescriptorInfo(descriptor, this);
        }

        //injectFakeDescriptors(); // DEBUG

        decodeDescriptors();

        // Get the characteristic data
        m_data = characteristic_ble.value();
    }
    else
    {
        qWarning() << "CharacteristicInfo::setCharacteristic() characteristic is invalid";
    }
}

/* ************************************************************************** */

void CharacteristicInfo::addDescriptor(const QBluetoothUuid &uuid, const QString &name,
                                       const QByteArray &dvalue)
{
    m_descriptors += new DescriptorInfo(uuid, name, dvalue, this);
}

void CharacteristicInfo::decodeDescriptors()
{
    // Start from scratch, a single descriptor update can change the meaning of the others
    m_notify_enabled = false;
    m_indicate_enabled = false;
    m_broadcast_enabled = false;
    m_formats.clear();
    m_has_aggregate = false;
    m_aggregate_handles.clear();
    m_min = QVariant();
    m_max = QVariant();
    m_valid_range_accuracy = BleDescriptors::ValidRangeAndAccuracy();

    QList <QVariantList> fields;
    fields.reserve(m_descriptors.size());

    for (const auto *d: std::as_const(m_descriptors))
    {
        const DescriptorInfo *di = qobject_cast<const DescriptorInfo *>(d);
        fields += di ? decodeDescriptor(di) : QVariantList();
    }

    // The extended properties descriptor adds to the properties,
    // which may already contain them (from the cache, or a previous decoding)
    m_properties_str.removeDuplicates();

    // Now that every presentation format is known
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();

    for (int i = 0; i < m_descriptors.size(); i++)
    {
        DescriptorInfo *di = qobject_cast<DescriptorInfo *>(m_descriptors.at(i));
        if (!di) continue;

        decodeContextDescriptor(di, pf, fields[i]);
        di->setFields(fields.at(i));
    }
}

QVariantList CharacteristicInfo::decodeDescriptor(const DescriptorInfo *di)
{
    QVariantList fields;

    // Vendor specific descriptor? nothing to decode
    bool uuid16 = false;
    const quint16 duuid = di->getUuid16(&uuid16);
    if (!uuid16) return fields;

    const QByteArray &dvalue = di->getValue();

    switch (duuid)
    {
    case BleDescriptors::DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTIES:
    {
        // Bit field (2 octets)
        const uint16_t eflags = static_cast<uint16_t>(BleFormat::readUIntLE(dvalue, 0, qMin(2, static_cast<int>(dvalue.size()))));
        QStringList eprops;
        if (eflags & 0x0001) eprops += QStringLiteral("Reliable Write");
        if (eflags & 0x0002) eprops += QStringLiteral("Writable Auxiliaries");

        m_properties_str += eprops;
        fields += descriptorField(tr("Properties:"), eprops.isEmpty() ? QStringLiteral("none") : eprops.join(QStringLiteral(", ")));
    } break;

    case BleDescriptors::DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION:
    {
        // Not read (yet), or not readable, keep the name we already have
        if (!dvalue.isEmpty())
        {
            m_name = QString::fromUtf8(dvalue);
            fields += descriptorField(tr("Description:"), m_name);
        }
    } break;

    case BleDescriptors::DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIGURATION:
    {
        // Bit field (2 octets)
        const uint16_t cflags = static_cast<uint16_t>(BleFormat::readUIntLE(dvalue, 0, qMin(2, static_cast<int>(dvalue.size()))));
        m_notify_enabled = (cflags & 0x0001);
        m_indicate_enabled = (cflags & 0x0002);

        fields += descriptorField(tr("Notifications:"), enabledToString(m_notify_enabled));
        fields += descriptorField(tr("Indications:"), enabledToString(m_indicate_enabled));
    } break;

    case BleDescriptors::DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIGURATION:
    {
        // Bit field (2 octets)
        const uint16_t sflags = static_cast<uint16_t>(BleFormat::readUIntLE(dvalue, 0, qMin(2, static_cast<int>(dvalue.size()))));
        m_broadcast_enabled = (sflags & 0x0001);

        fields += descriptorField(tr("Broadcast:"), enabledToString(m_broadcast_enabled));
    } break;

    case BleDescriptors::DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT:
    {
        // Format (1) | Exponent (1) | Unit (2) | Name Space (1) | Description (2)
        if (dvalue.size() >= 7)
        {
            BleFormat::CharacteristicPresentationFormat pf;
            pf.format = static_cast<uint8_t>(dvalue.at(0));
            pf.exponent = static_cast<int8_t>(dvalue.at(1));
            pf.unit = static_cast<uint16_t>(BleFormat::readUIntLE(dvalue, 2, 2));
            pf.nnamespace = static_cast<uint8_t>(dvalue.at(4));
            pf.desc = static_cast<uint16_t>(BleFormat::readUIntLE(dvalue, 5, 2));

            m_formats += pf;

            fields += descriptorField(tr("Format:"), BleFormat::formatToString(pf.format) + QStringLiteral(" (") +
                                                     BleFormat::formatToDescription(pf.format) + QStringLiteral(")"));
            if (pf.exponent != 0) fields += descriptorField(tr("Exponent:"), QString::number(pf.exponent));
            if (pf.unit) fields += descriptorField(tr("Unit:"), BleFormat::unitToString(pf.unit));
            if (pf.nnamespace) fields += descriptorField(tr("Namespace:"), BleFormat::namespaceToString(pf.nnamespace));
            if (pf.desc) fields += descriptorField(tr("Description:"), BleFormat::descriptionToString(pf.nnamespace, pf.desc));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeDescriptor() presentation format descriptor is too small:" << dvalue.size();
        }
    } break;

    case BleDescriptors::DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT:
    {
        // List of Attribute Handles of Characteristic Presentation Format declarations (2 octets each)
        m_has_aggregate = true;
        m_aggregate_handles.clear();
        for (int i = 0; (i + 1) < dvalue.size(); i += 2)
        {
            m_aggregate_handles += static_cast<quint16>(BleFormat::readUIntLE(dvalue, i, 2));
        }

        fields += descriptorField(tr("Handles:"), getAggregateHandles().join(QStringLiteral(", ")));
    } break;

    case BleDescriptors::DESCRIPTOR_VALID_RANGE:
    case BleDescriptors::DESCRIPTOR_ES_TRIGGER_SETTING:
    case BleDescriptors::DESCRIPTOR_MEASUREMENT_DESCRIPTION:
        // Decoded by decodeContextDescriptor()
        break;

    case BleDescriptors::DESCRIPTOR_EXTERNAL_REPORT_REFERENCE:
    {
        // UUID of the referenced characteristic (2 octets)
        if (dvalue.size() >= 2)
        {
            const QBluetoothUuid reference(static_cast<quint16>(BleFormat::readUIntLE(dvalue, 0, 2)));
            fields += descriptorField(tr("Reference:"), BleFormat::uuidShort(reference));
        }
    } break;

    case BleDescriptors::DESCRIPTOR_REPORT_REFERENCE:
    {
        // Report ID (1) | Report Type (1)
        if (dvalue.size() >= 2)
        {
            fields += descriptorField(tr("Report ID:"), QString::number(static_cast<uint8_t>(dvalue.at(0))));
            fields += descriptorField(tr("Report type:"), BleDescriptors::reportTypeToString(static_cast<uint8_t>(dvalue.at(1))));
        }
    } break;

    case BleDescriptors::DESCRIPTOR_NUMBER_OF_DIGITALS:
    {
        // Number of digitals in the characteristic value (1 octet)
        if (dvalue.size() >= 1)
        {
            fields += descriptorField(tr("Digitals:"), QString::number(static_cast<uint8_t>(dvalue.at(0))));
        }
    } break;

    case BleDescriptors::DESCRIPTOR_ES_CONFIGURATION:
    {
        // Trigger Logic (1 octet)
        if (dvalue.size() >= 1)
        {
            fields += descriptorField(tr("Trigger logic:"), BleDescriptors::esTriggerLogicToString(static_cast<uint8_t>(dvalue.at(0))));
        }
    } break;

    case BleDescriptors::DESCRIPTOR_ES_MEASUREMENT:
    {
        const BleDescriptors::EnvironmentalSensingMeasurement esm = BleDescriptors::readEnvironmentalSensingMeasurement(dvalue);
        if (esm.valid)
        {
            fields += descriptorField(tr("Sampling function:"), BleDescriptors::samplingFunctionToString(esm.sampling_function));
            fields += descriptorField(tr("Measurement period:"), esm.measurement_period ?
                                      QString::number(esm.measurement_period) + QStringLiteral(" s") :
                                      QStringLiteral("not in use"));
            fields += descriptorField(tr("Update interval:"), esm.update_interval ?
                                      QString::number(esm.update_interval) + QStringLiteral(" s") :
                                      QStringLiteral("not in use"));
            fields += descriptorField(tr("Application:"), BleDescriptors::esApplicationToString(esm.application));
            // 0xFF means "information not available", otherwise 0.5% steps
            fields += descriptorField(tr("Uncertainty:"), (esm.uncertainty != 0xFF) ?
                                      QString::number(esm.uncertainty * 0.5) + QStringLiteral(" %") :
                                      QStringLiteral("not available"));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeDescriptor() ES measurement descriptor is too small:" << dvalue.size();
        }
    } break;

    case BleDescriptors::DESCRIPTOR_VALUE_TRIGGER_SETTING:
    {
        // Condition (1) | Comparison Value (0 to n, defined per condition)
        const BleDescriptors::ValueTriggerSetting vts = BleDescriptors::readValueTriggerSetting(dvalue);
        if (vts.valid)
        {
            fields += descriptorField(tr("Trigger:"), BleDescriptors::valueTriggerToString(vts));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeDescriptor() value trigger setting descriptor is empty";
        }
    } break;

    case BleDescriptors::DESCRIPTOR_VALID_RANGE_AND_ACCURACY:
    {
        // Observation Type (4) | Unit Code (2) | Lower Limit (4) | Upper Limit (4) | Accuracy (4, optional)
        m_valid_range_accuracy = BleDescriptors::readValidRangeAndAccuracy(dvalue);
        if (m_valid_range_accuracy.valid)
        {
            fields += descriptorField(tr("Range and accuracy:"), getValidRangeAndAccuracy());
            fields += descriptorField(tr("Observation type:"), tr("MDC %1, unit MDC %2").arg(m_valid_range_accuracy.observation_type)
                                                                                        .arg(m_valid_range_accuracy.unit_code));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeDescriptor() valid range and accuracy descriptor is too small:" << dvalue.size();
        }
    } break;

    case BleDescriptors::DESCRIPTOR_TIME_TRIGGER_SETTING:
    {
        // Condition (1) | Value (0 to 3, defined per condition)
        const BleDescriptors::TimeTriggerSetting tts = BleDescriptors::readTimeTriggerSetting(dvalue);
        if (tts.valid)
        {
            fields += descriptorField(tr("Trigger:"), BleDescriptors::timeTriggerToString(tts));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeDescriptor() time trigger setting descriptor is empty";
        }
    } break;

    case BleDescriptors::DESCRIPTOR_OBSERVATION_SCHEDULE:
    {
        // Observation Type (4) | Measurement Period (4) | Update Interval (4)
        const BleDescriptors::ObservationSchedule os = BleDescriptors::readObservationSchedule(dvalue);
        if (os.valid)
        {
            auto seconds = [](const QVariant &v) -> QString {
                if (!v.isValid()) return QStringLiteral("not available");
                if (v.toDouble() == 0.0) return QStringLiteral("unspecified");
                return v.toString() + QStringLiteral(" s");
            };

            fields += descriptorField(tr("Observation type:"), tr("MDC %1").arg(os.observation_type));
            fields += descriptorField(tr("Measurement period:"), seconds(os.measurement_period));
            fields += descriptorField(tr("Update interval:"), seconds(os.update_interval));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeDescriptor() observation schedule descriptor is too small:" << dvalue.size();
        }
    } break;

    //case BleDescriptors::DESCRIPTOR_COMPLETE_BREDR_TRANSPORT_BLOCK_DATA:
    //case BleDescriptors::DESCRIPTOR_MANUFACTURER_LIMITS:
    //case BleDescriptors::DESCRIPTOR_PROCESS_TOLERANCES:
    //case BleDescriptors::DESCRIPTOR_IMD_TRIGGER_SETTING:
    //case BleDescriptors::DESCRIPTOR_COOKING_SENSOR_INFO:
    //case BleDescriptors::DESCRIPTOR_COOKING_TRIGGER_SETTING:
    // TODO // kept raw in m_descriptors for now

    default:
        qWarning() << "> UNHANDLED DESCRIPTOR >" << Qt::hex << duuid;
        break;
    }

    return fields;
}

void CharacteristicInfo::decodeContextDescriptor(const DescriptorInfo *di,
                                                 const BleFormat::CharacteristicPresentationFormat *pf,
                                                 QVariantList &fields)
{
    bool uuid16 = false;
    const quint16 duuid = di->getUuid16(&uuid16);
    if (!uuid16) return;

    const QByteArray &dvalue = di->getValue();

    if (duuid == BleDescriptors::DESCRIPTOR_VALID_RANGE)
    {
        // Lower inclusive value | Upper inclusive value, in the presentation format
        // With an aggregate, we cannot tell which format the range is expressed in,
        // so it will be presented raw
        if (isAggregate())
        {
            qWarning() << "CharacteristicInfo::decodeContextDescriptor() valid range on an aggregate format, cannot decode it";
        }

        if (BleDescriptors::readValidRange(dvalue, pf, m_min, m_max))
        {
            fields = { descriptorField(tr("Valid range:"), getValidRange()) };
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeContextDescriptor() cannot decode valid range:" << dvalue.toHex();
        }
    }
    else if (duuid == BleDescriptors::DESCRIPTOR_MEASUREMENT_DESCRIPTION)
    {
        // Flags (2) | Sampling Function (1) | Measurement Period (3) | Internal Update Interval (3) |
        // Description (2) | Resolution (n) | Relative Uncertainty (1) | Absolute Uncertainty (n)
        const BleDescriptors::MeasurementDescription md = BleDescriptors::readMeasurementDescription(dvalue, pf);
        if (md.valid)
        {
            auto value = [pf](const QVariant &v) -> QString {
                return (pf && v.typeId() != QMetaType::QString) ? BleFormat::valueToString(v, *pf) : v.toString();
            };

            if (md.sampling_function >= 0)
                fields += descriptorField(tr("Sampling function:"), BleDescriptors::imdSamplingFunctionToString(static_cast<uint8_t>(md.sampling_function)));
            if (md.measurement_period >= 0)
                fields += descriptorField(tr("Measurement period:"), md.measurement_period ?
                                          QString::number(md.measurement_period) + QStringLiteral(" ms") :
                                          QStringLiteral("instantaneous"));
            if (md.update_interval >= 0)
                fields += descriptorField(tr("Update interval:"), QString::number(md.update_interval) + QStringLiteral(" ms"));
            if (md.description >= 0)
                fields += descriptorField(tr("Description:"), BleFormat::descriptionToString(0x01, static_cast<uint16_t>(md.description)));
            if (md.resolution.isValid())
                fields += descriptorField(tr("Resolution:"), value(md.resolution));
            if (md.relative_uncertainty >= 0)
                fields += descriptorField(tr("Uncertainty:"), QString::number(md.relative_uncertainty / 10.0) + QStringLiteral(" %"));
            if (md.absolute_uncertainty.isValid())
                fields += descriptorField(tr("Uncertainty:"), QStringLiteral("±") + value(md.absolute_uncertainty));
        }
        else
        {
            qWarning() << "CharacteristicInfo::decodeContextDescriptor() cannot decode measurement description:" << dvalue.toHex();
        }
    }
    else if (duuid == BleDescriptors::DESCRIPTOR_ES_TRIGGER_SETTING)
    {
        // Condition (1) | Operand (0 to n, defined per condition)
        BleDescriptors::EnvironmentalSensingTriggerSetting ts;
        if (BleDescriptors::readEsTriggerSetting(dvalue, pf, ts))
        {
            fields = { descriptorField(tr("Trigger:"), BleDescriptors::esTriggerToString(ts)) };
        }
    }
}

/* ************************************************************************** */

void CharacteristicInfo::updateDescriptor(const QLowEnergyDescriptor &descriptor, const QByteArray &dvalue)
{
    for (auto *d: std::as_const(m_descriptors))
    {
        DescriptorInfo *di = qobject_cast<DescriptorInfo *>(d);
        if (!di) continue;

        // Same UUID descriptors can exist on a characteristic (ex: aggregates), so use the
        // live descriptor (compared by handle) when we have one
        if (di->getDescriptor().isValid() ? (di->getDescriptor() != descriptor)
                                          : (di->getUuid() != descriptor.uuid())) continue;

        di->setValue(dvalue);
        di->setReadInProgress(false);

        decodeDescriptors();
        Q_EMIT characteristicChanged();
        Q_EMIT valueChanged(); // the value decoding depends on the presentation formats

        return;
    }
}

/* ************************************************************************** */

void CharacteristicInfo::injectFakeDescriptors()
{
    static bool warned = false;
    if (!warned)
    {
        warned = true;
        qWarning() << "/!\\ FAKE_BLE_DESCRIPTORS is enabled: every characteristic gets made up descriptors /!\\";
    }

    // Fake, but real descriptor values, so they go through the regular decoding
    // Four different sets, picked from the UUID, to cover the various UI paths
    bool uuid16 = false;
    const quint16 cuuid = m_uuid.toUInt16(&uuid16);
    const int set = uuid16 ? (cuuid % 4) : 3;

    if (set == 0) // environmental sensor
    {
        // valid range comes *before* the presentation format on purpose
        addDescriptor(QBluetoothUuid(quint16(0x2906)), QString(), QByteArray::fromHex("9CFF7017"));
        addDescriptor(QBluetoothUuid(quint16(0x2904)), QString(), QByteArray::fromHex("0EFE2F27010C01"));
        addDescriptor(QBluetoothUuid(quint16(0x2902)), QString(), QByteArray::fromHex("0100"));
        addDescriptor(QBluetoothUuid(quint16(0x290C)), QString(), QByteArray::fromHex("000002" "3C0000" "0F0000" "0102"));
        addDescriptor(QBluetoothUuid(quint16(0x290D)), QString(), QByteArray::fromHex("06C409"));
        addDescriptor(QBluetoothUuid(quint16(0x290D)), QString(), QByteArray::fromHex("012C0100"));
        addDescriptor(QBluetoothUuid(quint16(0x290B)), QString(), QByteArray::fromHex("01"));
        addDescriptor(QBluetoothUuid(quint16(0x2912)), QString(), QByteArray::fromHex("3F00" "06" "E80300" "D00700" "0C01" "0100" "0A"));
    }
    else if (set == 1) // HID-ish
    {
        addDescriptor(QBluetoothUuid(quint16(0x2908)), QString(), QByteArray::fromHex("0101"));
        addDescriptor(QBluetoothUuid(quint16(0x2907)), QString(), QByteArray::fromHex("4B2A"));
        addDescriptor(QBluetoothUuid(quint16(0x2909)), QString(), QByteArray::fromHex("08"));
        addDescriptor(QBluetoothUuid(quint16(0x290A)), QString(), QByteArray::fromHex("040F"));
        addDescriptor(QBluetoothUuid(quint16(0x2902)), QString(), QByteArray::fromHex("0200"));
        // unknown to QBluetoothUuid::DescriptorType
        addDescriptor(QBluetoothUuid(quint16(0x290E)), QString(), QByteArray::fromHex("020A0000"));
    }
    else if (set == 2) // aggregate of two formats
    {
        addDescriptor(QBluetoothUuid(quint16(0x2900)), QString(), QByteArray::fromHex("03"));
        addDescriptor(QBluetoothUuid(quint16(0x2904)), QString(), QByteArray::fromHex("0400AD27010000"));
        addDescriptor(QBluetoothUuid(quint16(0x2904)), QString(), QByteArray::fromHex("06FF2427010100"));
        addDescriptor(QBluetoothUuid(quint16(0x2905)), QString(), QByteArray::fromHex("05020702"));
        addDescriptor(QBluetoothUuid(quint16(0x2903)), QString(), QByteArray::fromHex("0100"));
    }
    else // strings and vendor specific
    {
        addDescriptor(QBluetoothUuid(quint16(0x2904)), QString(), QByteArray::fromHex("19000027010000"));
        addDescriptor(QBluetoothUuid(quint16(0x2902)), QString(), QByteArray::fromHex("0000"));
        addDescriptor(QBluetoothUuid(quint16(0x2911)), QString(), QByteArray::fromHex("B84B0200" "0413" "00000000" "E80300FF" "050000FF"));
        addDescriptor(QBluetoothUuid(quint16(0x290A)), QString(), QByteArray::fromHex("05" "6400" "D007"));
        addDescriptor(QBluetoothUuid(quint16(0x2910)), QString(), QByteArray::fromHex("B84B0200" "3C000000" "0A000000"));
        addDescriptor(QBluetoothUuid(QStringLiteral("{f000ffc1-0451-4000-b000-000000000000}")), QString(),
                      QByteArray::fromHex("48656C6C6F2066726F6D2061206D61646520757020766564"
                                          "6F722064657363726970746F72202D20303132333435363789ABCDEF"));
    }
}

/* ************************************************************************** */

void CharacteristicInfo::setCharacteristic(const QJsonObject &characteristic_cache)
{
    if (!characteristic_cache.isEmpty())
    {
        m_name = characteristic_cache["name"].toString();
        m_uuid = QBluetoothUuid(characteristic_cache["uuid"].toString());

        const QJsonArray props = characteristic_cache["properties"].toArray();
        for (const auto &p: props)
        {
            m_properties_str += p.toString();
        }

        // The value is optional
        if (characteristic_cache.contains("value"))
        {
            m_data = QByteArray::fromHex(characteristic_cache["value"].toString().toLatin1());
        }

        const QJsonArray descriptors = characteristic_cache["descriptors"].toArray();
        for (const auto &d: descriptors)
        {
            const QJsonObject descriptor_cache = d.toObject();

            addDescriptor(QBluetoothUuid(descriptor_cache["uuid"].toString()),
                          descriptor_cache["name"].toString(),
                          QByteArray::fromHex(descriptor_cache["value"].toString().toLatin1()));
        }

        //injectFakeDescriptors(); // DEBUG

        decodeDescriptors();
    }
    else
    {
        qWarning() << "CharacteristicInfo::setCharacteristic() cache is empty";
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
    return BleFormat::uuidShort(m_uuid);
}

/* ************************************************************************** */

QString CharacteristicInfo::getProperty() const
{
    QString properties;

    for (const auto &p: m_properties_str)
    {
        if (!properties.isEmpty()) properties += " / ";
        properties += p;

        //qDebug() << " properties: " << p;
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

    return m_properties_str;
}

QString CharacteristicInfo::getPermission() const
{
/*
    Access Permissions

        Similar to file permissions, access permissions determine whether the client can read or write (or both) an attribute value (introduced in Value).
        Each attribute can have one of the following access permissions:

        None
            The attribute can neither be read nor written by a client.
        Readable
            The attribute can be read by a client.
        Writable
            The attribute can be written by a client.
        Readable and writable
            The attribute can be both read and written by the client.

    Encryption

        Determines whether a certain level of encryption is required for this attribute to be accessed by the client.
            (See Authentication, Security Modes and Procedures, and Security Modes for more information on authentication and encryption.)
            These are the allowed encryption permissions, as defined by GATT:

        No encryption required (Security Mode 1, Level 1)
            The attribute is accessible on a plain-text, non-encrypted connection.
        Unauthenticated encryption required (Security Mode 1, Level 2)
            The connection must be encrypted to access this attribute, but the encryption keys do not need to be authenticated (although they can be).
        Authenticated encryption required (Security Mode 1, Level 3)
            The connection must be encrypted with an authenticated key to access this attribute.

    Authorization

        Determines whether user permission (also known as authorization, as discussed in Security Modes and Procedures) is required to access this attribute.
            An attribute can choose only between requiring or not requiring authorization:

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

QVariant CharacteristicInfo::getDescriptorsList() const
{
    return QVariant::fromValue(m_descriptors);
}

/* ************************************************************************** */

const BleFormat::CharacteristicPresentationFormat *CharacteristicInfo::singleFormat() const
{
    if (m_formats.size() != 1 || isAggregate()) return nullptr;

    return &m_formats.first();
}

int CharacteristicInfo::getFormatType() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? pf->format : -1;
}

QString CharacteristicInfo::getFormatName() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? BleFormat::formatToString(pf->format) : QString();
}

QString CharacteristicInfo::getFormatInfo() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? BleFormat::formatToDescription(pf->format) : QString();
}

int CharacteristicInfo::getFormatExponent() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? pf->exponent : 0;
}

QString CharacteristicInfo::getFormatUnit() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? BleFormat::unitToString(pf->unit) : QString();
}

QString CharacteristicInfo::getFormatNamespace() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? BleFormat::namespaceToString(pf->nnamespace) : QString();
}

QString CharacteristicInfo::getFormatDescription() const
{
    const BleFormat::CharacteristicPresentationFormat *pf = singleFormat();
    return pf ? BleFormat::descriptionToString(pf->nnamespace, pf->desc) : QString();
}

int CharacteristicInfo::getFormatSize() const
{
    // Expected size of the characteristic value, in bytes
    // 0 if we don't know, or if any of the formats has a variable size
    if (!areFormatsResolved()) return 0;

    int size = 0;

    for (const auto &pf: m_formats)
    {
        const int s = BleFormat::formatSize(pf.format);
        if (s <= 0) return 0;

        size += s;
    }

    return size;
}

QStringList CharacteristicInfo::getFormatsList() const
{
    QStringList out;

    for (const auto &pf: m_formats)
    {
        out += formatSummary(pf);
    }

    return out;
}

/* ************************************************************************** */

bool CharacteristicInfo::isAggregate() const
{
    return (m_has_aggregate ? m_aggregate_handles.size() : m_formats.size()) > 1;
}

bool CharacteristicInfo::areFormatsResolved() const
{
    return (!m_has_aggregate || m_aggregate_handles.size() == m_formats.size());
}

QStringList CharacteristicInfo::getAggregateHandles() const
{
    QStringList out;

    for (const quint16 handle: m_aggregate_handles)
    {
        out += QStringLiteral("0x") + QString::number(handle, 16).toUpper().rightJustified(4, QLatin1Char('0'));
    }

    return out;
}

/* ************************************************************************** */

QString CharacteristicInfo::getValidRange() const
{
    if (!hasValidRange()) return QString();

    return m_min.toString() + QStringLiteral(" ... ") + m_max.toString();
}

/* ************************************************************************** */

QString CharacteristicInfo::getValidRangeAndAccuracy() const
{
    return BleDescriptors::validRangeAndAccuracyToString(m_valid_range_accuracy);
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

QString CharacteristicInfo::getValueHex() const
{
    return QString::fromLatin1(m_data.toHex().toUpper());
}

QString CharacteristicInfo::getValueAscii() const
{
    return QString::fromUtf8(m_data);
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

QStringList CharacteristicInfo::getValueFormatted_list() const
{
    if (!areFormatsResolved()) return QStringList();

    return BleFormat::readFormattedValues(m_data, m_formats);
}

/* ************************************************************************** */

void CharacteristicInfo::setValue(const QByteArray &v)
{
    m_data = v;
    Q_EMIT valueChanged();
}

/* ************************************************************************** */
