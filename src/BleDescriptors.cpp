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


#include "BleDescriptors.h"

#include "BleFormat.h"

/* ************************************************************************** */

QString BleDescriptors::descriptorToString(const uint16_t uuid)
{
    switch (uuid)
    {
        case DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTIES:  return QStringLiteral("Characteristic Extended Properties");
        case DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION:     return QStringLiteral("Characteristic User Description");
        case DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIGURATION: return QStringLiteral("Client Characteristic Configuration");
        case DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIGURATION: return QStringLiteral("Server Characteristic Configuration");
        case DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT:  return QStringLiteral("Characteristic Presentation Format");
        case DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT:     return QStringLiteral("Characteristic Aggregate Format");
        case DESCRIPTOR_VALID_RANGE:                         return QStringLiteral("Valid Range");
        case DESCRIPTOR_EXTERNAL_REPORT_REFERENCE:           return QStringLiteral("External Report Reference");
        case DESCRIPTOR_REPORT_REFERENCE:                    return QStringLiteral("Report Reference");
        case DESCRIPTOR_NUMBER_OF_DIGITALS:                  return QStringLiteral("Number of Digitals");
        case DESCRIPTOR_VALUE_TRIGGER_SETTING:               return QStringLiteral("Value Trigger Setting");
        case DESCRIPTOR_ES_CONFIGURATION:                    return QStringLiteral("Environmental Sensing Configuration");
        case DESCRIPTOR_ES_MEASUREMENT:                      return QStringLiteral("Environmental Sensing Measurement");
        case DESCRIPTOR_ES_TRIGGER_SETTING:                  return QStringLiteral("Environmental Sensing Trigger Setting");
        case DESCRIPTOR_TIME_TRIGGER_SETTING:                return QStringLiteral("Time Trigger Setting");
        case DESCRIPTOR_COMPLETE_BREDR_TRANSPORT_BLOCK_DATA: return QStringLiteral("Complete BR-EDR Transport Block Data");
        case DESCRIPTOR_OBSERVATION_SCHEDULE:                return QStringLiteral("Observation Schedule");
        case DESCRIPTOR_VALID_RANGE_AND_ACCURACY:            return QStringLiteral("Valid Range and Accuracy");
        case DESCRIPTOR_MEASUREMENT_DESCRIPTION:             return QStringLiteral("Measurement Description");
        case DESCRIPTOR_MANUFACTURER_LIMITS:                 return QStringLiteral("Manufacturer Limits");
        case DESCRIPTOR_PROCESS_TOLERANCES:                  return QStringLiteral("Process Tolerances");
        case DESCRIPTOR_IMD_TRIGGER_SETTING:                 return QStringLiteral("IMD Trigger Setting");
        case DESCRIPTOR_COOKING_SENSOR_INFO:                 return QStringLiteral("Cooking Sensor Info");
        case DESCRIPTOR_COOKING_TRIGGER_SETTING:             return QStringLiteral("Cooking Trigger Setting");
    }

    return QStringLiteral("Unknown Descriptor");
}

/* ************************************************************************** */

QString BleDescriptors::reportTypeToString(const uint8_t report_type)
{
    switch (report_type)
    {
        case 0x01: return QStringLiteral("Input Report");
        case 0x02: return QStringLiteral("Output Report");
        case 0x03: return QStringLiteral("Feature Report");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

QString BleDescriptors::samplingFunctionToString(const uint8_t sampling_function)
{
    switch (sampling_function)
    {
        case 0x00: return QStringLiteral("Unspecified");
        case 0x01: return QStringLiteral("Instantaneous");
        case 0x02: return QStringLiteral("Arithmetic Mean");
        case 0x03: return QStringLiteral("RMS");
        case 0x04: return QStringLiteral("Maximum");
        case 0x05: return QStringLiteral("Minimum");
        case 0x06: return QStringLiteral("Accumulated");
        case 0x07: return QStringLiteral("Count");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

QString BleDescriptors::esApplicationToString(const uint8_t application)
{
    switch (application)
    {
        case 0x00: return QStringLiteral("Unspecified");
        case 0x01: return QStringLiteral("Air");
        case 0x02: return QStringLiteral("Water");
        case 0x03: return QStringLiteral("Barometric");
        case 0x04: return QStringLiteral("Soil");
        case 0x05: return QStringLiteral("Infrared");
        case 0x06: return QStringLiteral("Map Database");
        case 0x07: return QStringLiteral("Barometric Elevation Source");
        case 0x08: return QStringLiteral("GPS only Elevation Source");
        case 0x09: return QStringLiteral("GPS and Map database Elevation Source");
        case 0x0A: return QStringLiteral("Vertical datum Elevation Source");
        case 0x0B: return QStringLiteral("Onshore");
        case 0x0C: return QStringLiteral("Onboard vessel or vehicle");
        case 0x0D: return QStringLiteral("Front");
        case 0x0E: return QStringLiteral("Back/Rear");
        case 0x0F: return QStringLiteral("Upper");
        case 0x10: return QStringLiteral("Lower");
        case 0x11: return QStringLiteral("Primary");
        case 0x12: return QStringLiteral("Secondary");
        case 0x13: return QStringLiteral("Outdoor");
        case 0x14: return QStringLiteral("Indoor");
        case 0x15: return QStringLiteral("Top");
        case 0x16: return QStringLiteral("Bottom");
        case 0x17: return QStringLiteral("Main");
        case 0x18: return QStringLiteral("Backup");
        case 0x19: return QStringLiteral("Auxiliary");
        case 0x1A: return QStringLiteral("Supplementary");
        case 0x1B: return QStringLiteral("Inside");
        case 0x1C: return QStringLiteral("Outside");
        case 0x1D: return QStringLiteral("Left");
        case 0x1E: return QStringLiteral("Right");
        case 0x1F: return QStringLiteral("Internal");
        case 0x20: return QStringLiteral("External");
        case 0x21: return QStringLiteral("Solar");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

BleDescriptors::EnvironmentalSensingMeasurement BleDescriptors::readEnvironmentalSensingMeasurement(const QByteArray &data)
{
    EnvironmentalSensingMeasurement esm;

    if (data.size() < 11) return esm;

    esm.flags = static_cast<uint16_t>(BleFormat::readUIntLE(data, 0, 2));
    esm.sampling_function = static_cast<uint8_t>(data.at(2));
    esm.measurement_period = static_cast<uint32_t>(BleFormat::readUIntLE(data, 3, 3));
    esm.update_interval = static_cast<uint32_t>(BleFormat::readUIntLE(data, 6, 3));
    esm.application = static_cast<uint8_t>(data.at(9));
    esm.uncertainty = static_cast<uint8_t>(data.at(10));
    esm.valid = true;

    return esm;
}

/* ************************************************************************** */

QString BleDescriptors::esTriggerConditionToString(const uint8_t condition)
{
    switch (condition)
    {
        case 0x00: return QStringLiteral("Trigger inactive");
        case 0x01: return QStringLiteral("Use a fixed time interval between transmissions");
        case 0x02: return QStringLiteral("No less than the specified time between transmissions");
        case 0x03: return QStringLiteral("When value changes compared to previous value");
        case 0x04: return QStringLiteral("While less than the specified value");
        case 0x05: return QStringLiteral("While less than or equal to the specified value");
        case 0x06: return QStringLiteral("While greater than the specified value");
        case 0x07: return QStringLiteral("While greater than or equal to the specified value");
        case 0x08: return QStringLiteral("While equal to the specified value");
        case 0x09: return QStringLiteral("While not equal to the specified value");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

bool BleDescriptors::esTriggerOperandIsTime(const uint8_t condition)
{
    return (condition == 0x01 || condition == 0x02);
}

/* ************************************************************************** */

bool BleDescriptors::esTriggerOperandIsValue(const uint8_t condition)
{
    return (condition >= 0x04 && condition <= 0x09);
}

/* ************************************************************************** */

QString BleDescriptors::valueTriggerConditionToString(const uint8_t condition)
{
    switch (condition)
    {
        case 0x00: return QStringLiteral("The characteristic value changed");
        case 0x01: return QStringLiteral("Crossed a boundary");
        case 0x02: return QStringLiteral("On the boundary");
        case 0x03: return QStringLiteral("Changed more than the specified value");
        case 0x04: return QStringLiteral("Mask then compare");
        case 0x05: return QStringLiteral("Inside or outside the boundaries");
        case 0x06: return QStringLiteral("On the boundaries");
        case 0x07: return QStringLiteral("No value trigger");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

BleDescriptors::ValueTriggerComparison BleDescriptors::valueTriggerComparisonFormat(const uint8_t condition)
{
    switch (condition)
    {
        case 0x01:
        case 0x02:
        case 0x03: return VALUE_TRIGGER_ANALOG;
        case 0x04: return VALUE_TRIGGER_BITMASK;
        case 0x05:
        case 0x06: return VALUE_TRIGGER_ANALOG_INTERVAL;
    }

    return VALUE_TRIGGER_NONE; // 0x00, 0x07 and RFU
}

/* ************************************************************************** */

BleDescriptors::ValueTriggerSetting BleDescriptors::readValueTriggerSetting(const QByteArray &data)
{
    ValueTriggerSetting vts;

    if (data.size() < 1) return vts;

    vts.condition = static_cast<uint8_t>(data.at(0));
    vts.comparison_raw = data.mid(1);
    vts.valid = true;

    const ValueTriggerComparison format = valueTriggerComparisonFormat(vts.condition);

    if (format == VALUE_TRIGGER_ANALOG && vts.comparison_raw.size() >= 2)
    {
        vts.comparison = QVariant::fromValue(BleFormat::readUIntLE(vts.comparison_raw, 0, 2));
    }
    else if (format == VALUE_TRIGGER_ANALOG_INTERVAL && vts.comparison_raw.size() >= 4)
    {
        vts.comparison = QVariant::fromValue(BleFormat::readUIntLE(vts.comparison_raw, 0, 2));
        vts.comparison2 = QVariant::fromValue(BleFormat::readUIntLE(vts.comparison_raw, 2, 2));
    }
    else if (format == VALUE_TRIGGER_BITMASK && vts.comparison_raw.size() >= 1)
    {
        // Same size and format as the Digital characteristic, so keep it raw
        vts.comparison = QVariant(QStringLiteral("0x") + vts.comparison_raw.toHex().toUpper());
    }

    return vts;
}

/* ************************************************************************** */

BleDescriptors::ValidRangeAndAccuracy BleDescriptors::readValidRangeAndAccuracy(const QByteArray &data)
{
    ValidRangeAndAccuracy vra;

    if (data.size() < 14) return vra;

    vra.observation_type = static_cast<uint32_t>(BleFormat::readUIntLE(data, 0, 4));
    vra.unit_code = static_cast<uint16_t>(BleFormat::readUIntLE(data, 4, 2));
    vra.lower_limit = BleFormat::readMedFloat32(data, 6);
    vra.upper_limit = BleFormat::readMedFloat32(data, 10);
    vra.valid = true;

    // The measurement accuracy field is optional
    if (data.size() >= 18)
    {
        vra.accuracy = BleFormat::readMedFloat32(data, 14);
    }

    return vra;
}

/* ************************************************************************** */

QString BleDescriptors::esTriggerLogicToString(const uint8_t trigger_logic)
{
    switch (trigger_logic)
    {
        case 0x00: return QStringLiteral("Boolean AND");
        case 0x01: return QStringLiteral("Boolean OR");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

bool BleDescriptors::readValidRange(const QByteArray &data,
                                    const BleFormat::CharacteristicPresentationFormat *pf,
                                    QVariant &min, QVariant &max)
{
    min = QVariant();
    max = QVariant();

    const uint8_t format = pf ? pf->format : BleFormat::FORMAT_RFU;
    const int8_t exponent = pf ? pf->exponent : 0;
    const int size = BleFormat::formatSize(format);

    if (size > 0 && data.size() >= (size * 2))
    {
        min = BleFormat::readValue(data, 0, format, exponent);
        max = BleFormat::readValue(data, size, format, exponent);
        return true;
    }
    if (!data.isEmpty() && data.size() % 2 == 0)
    {
        // Unknown or variable size format: just split the range in two halves
        const int half = (data.size() / 2);
        min = QString(QStringLiteral("0x") + data.left(half).toHex().toUpper());
        max = QString(QStringLiteral("0x") + data.mid(half).toHex().toUpper());
        return true;
    }

    return false;
}

/* ************************************************************************** */

bool BleDescriptors::readEsTriggerSetting(const QByteArray &data,
                                          const BleFormat::CharacteristicPresentationFormat *pf,
                                          EnvironmentalSensingTriggerSetting &ts)
{
    ts = EnvironmentalSensingTriggerSetting();

    if (data.isEmpty()) return false;

    ts.condition = static_cast<uint8_t>(data.at(0));
    ts.operand_raw = data.mid(1);

    if (esTriggerOperandIsTime(ts.condition))
    {
        // uint24, in seconds
        if (ts.operand_raw.size() >= 3)
        {
            ts.operand = QVariant::fromValue(BleFormat::readUIntLE(ts.operand_raw, 0, 3));
        }
    }
    else if (esTriggerOperandIsValue(ts.condition))
    {
        // Same format, exponent and unit as the characteristic value,
        // kept raw when it is unknown or an aggregate
        if (pf) ts.operand = BleFormat::readValue(ts.operand_raw, 0, pf->format, pf->exponent);
        else if (!ts.operand_raw.isEmpty()) ts.operand = QString(QStringLiteral("0x") + ts.operand_raw.toHex().toUpper());
    }

    return true;
}

QString BleDescriptors::esTriggerToString(const EnvironmentalSensingTriggerSetting &ts)
{
    QString trigger = esTriggerConditionToString(ts.condition);

    if (ts.operand.isValid())
    {
        trigger += QStringLiteral(": ") + ts.operand.toString();
        if (esTriggerOperandIsTime(ts.condition)) trigger += QStringLiteral(" s");
    }

    return trigger;
}

/* ************************************************************************** */

QString BleDescriptors::valueTriggerToString(const ValueTriggerSetting &vts)
{
    if (!vts.valid) return QString();

    QString trigger = valueTriggerConditionToString(vts.condition);

    if (vts.comparison.isValid())
    {
        trigger += QStringLiteral(": ") + vts.comparison.toString();

        if (vts.comparison2.isValid())
        {
            trigger += QStringLiteral(" ... ") + vts.comparison2.toString();
        }
    }

    return trigger;
}

/* ************************************************************************** */

QString BleDescriptors::validRangeAndAccuracyToString(const ValidRangeAndAccuracy &vra)
{
    if (!vra.valid) return QString();

    QString range = vra.lower_limit.toString() + QStringLiteral(" ... ") + vra.upper_limit.toString();

    if (vra.accuracy.isValid())
    {
        range += QStringLiteral(" (±") + vra.accuracy.toString() + QStringLiteral(")");
    }

    return range;
}

/* ************************************************************************** */

QString BleDescriptors::timeTriggerConditionToString(const uint8_t condition)
{
    switch (condition)
    {
        case 0x00: return QStringLiteral("No time-based triggering");
        case 0x01: return QStringLiteral("Unconditionally after a time interval");
        case 0x02: return QStringLiteral("Not more often than a time interval");
        case 0x03: return QStringLiteral("After a number of value changes");
    }

    return QStringLiteral("RFU");
}

BleDescriptors::TimeTriggerSetting BleDescriptors::readTimeTriggerSetting(const QByteArray &data)
{
    TimeTriggerSetting tts;

    if (data.size() < 1) return tts;

    tts.condition = static_cast<uint8_t>(data.at(0));
    tts.valid = true;

    if ((tts.condition == 0x01 || tts.condition == 0x02) && data.size() >= 4)
    {
        tts.operand = QVariant::fromValue(BleFormat::readUIntLE(data, 1, 3));
    }
    else if (tts.condition == 0x03 && data.size() >= 3)
    {
        tts.operand = QVariant::fromValue(BleFormat::readUIntLE(data, 1, 2));
    }

    return tts;
}

QString BleDescriptors::timeTriggerToString(const TimeTriggerSetting &tts)
{
    if (!tts.valid) return QString();

    QString trigger = timeTriggerConditionToString(tts.condition);

    if (tts.operand.isValid())
    {
        trigger += QStringLiteral(": ") + tts.operand.toString();
        if (tts.condition != 0x03) trigger += QStringLiteral(" s");
    }

    return trigger;
}

/* ************************************************************************** */

BleDescriptors::ObservationSchedule BleDescriptors::readObservationSchedule(const QByteArray &data)
{
    ObservationSchedule os;

    if (data.size() < 12) return os;

    os.observation_type = static_cast<uint32_t>(BleFormat::readUIntLE(data, 0, 4));
    os.measurement_period = BleFormat::readMedFloat32(data, 4);
    os.update_interval = BleFormat::readMedFloat32(data, 8);
    os.valid = true;

    return os;
}

/* ************************************************************************** */

QString BleDescriptors::imdSamplingFunctionToString(const uint8_t sampling_function)
{
    switch (sampling_function)
    {
        case 0x00: return QStringLiteral("Unspecified");
        case 0x01: return QStringLiteral("Instantaneous");
        case 0x02: return QStringLiteral("Arithmetic mean since the beginning of the work cycle");
        case 0x03: return QStringLiteral("RMS since the beginning of the work cycle");
        case 0x04: return QStringLiteral("Maximum in the current work cycle");
        case 0x05: return QStringLiteral("Minimum in the current work cycle");
        case 0x06: return QStringLiteral("Moving average");
    }

    return QStringLiteral("RFU");
}

BleDescriptors::MeasurementDescription BleDescriptors::readMeasurementDescription(const QByteArray &data,
                                                                                  const BleFormat::CharacteristicPresentationFormat *pf)
{
    MeasurementDescription md;

    if (data.size() < 2) return md;

    md.flags = static_cast<uint16_t>(BleFormat::readUIntLE(data, 0, 2));

    const bool has_sampling = (md.flags & 0x0001);
    const bool has_period = (md.flags & 0x0002);
    const bool has_interval = (md.flags & 0x0004);
    const bool has_description = (md.flags & 0x0008);
    const bool has_resolution = (md.flags & 0x0010);
    const bool has_relative = (md.flags & 0x0020);
    const bool has_absolute = (md.flags & 0x0040);

    // Fixed size fields
    const int fixed_size = 2 + (has_sampling ? 1 : 0) + (has_period ? 3 : 0) + (has_interval ? 3 : 0) +
                           (has_description ? 2 : 0) + (has_relative ? 1 : 0);
    if (data.size() < fixed_size) return md;

    // Variable size fields, both in the characteristic format
    const int variable_count = (has_resolution ? 1 : 0) + (has_absolute ? 1 : 0);
    const int variable_size = variable_count ? ((data.size() - fixed_size) / variable_count) : 0;
    if (variable_count && (variable_size <= 0 || (data.size() - fixed_size) % variable_count)) return md;

    auto readVariable = [&](const int offset) -> QVariant
    {
        const QByteArray field = data.mid(offset, variable_size);
        if (pf && BleFormat::formatSize(pf->format) == variable_size)
        {
            return BleFormat::readValue(field, 0, pf->format, pf->exponent);
        }
        return QVariant(QString(QStringLiteral("0x") + field.toHex().toUpper()));
    };

    int offset = 2;
    if (has_sampling) { md.sampling_function = static_cast<uint8_t>(data.at(offset)); offset += 1; }
    if (has_period) { md.measurement_period = static_cast<int>(BleFormat::readUIntLE(data, offset, 3)); offset += 3; }
    if (has_interval) { md.update_interval = static_cast<int>(BleFormat::readUIntLE(data, offset, 3)); offset += 3; }
    if (has_description) { md.description = static_cast<int>(BleFormat::readUIntLE(data, offset, 2)); offset += 2; }
    if (has_resolution) { md.resolution = readVariable(offset); offset += variable_size; }
    if (has_relative) { md.relative_uncertainty = static_cast<uint8_t>(data.at(offset)); offset += 1; }
    if (has_absolute) { md.absolute_uncertainty = readVariable(offset); offset += variable_size; }

    md.valid = true;

    return md;
}

/* ************************************************************************** */
