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


#ifndef BLE_DESCRIPTORS_H
#define BLE_DESCRIPTORS_H
/* ************************************************************************** */

#include "BleFormat.h"

#include <cstdint>

#include <QString>
#include <QVariant>
#include <QByteArray>

/* ************************************************************************** */

/*!
 * \brief GATT characteristic descriptors names and decoding.
 *
 * References:
 * - Bluetooth Core Specification, Part G (GATT), 3.3.3 Characteristic Descriptor Declarations
 * - Assigned Numbers, Descriptors
 * - Environmental Sensing Service, 3.1.2 (ES Measurement / Trigger Setting / Configuration)
 * - HID Service, 2.7 (Report Reference / External Report Reference)
 */
class BleDescriptors
{
public:
    BleDescriptors() = delete;

    /*!
     * \brief Descriptor UUIDs, from the Assigned Numbers (because QBluetoothUuid::DescriptorType is incomplete)
     */
    enum DescriptorType : uint16_t
    {
        DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTIES  = 0x2900,
        DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION     = 0x2901,
        DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIGURATION = 0x2902,
        DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIGURATION = 0x2903,
        DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT  = 0x2904,
        DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT     = 0x2905,
        DESCRIPTOR_VALID_RANGE                         = 0x2906,
        DESCRIPTOR_EXTERNAL_REPORT_REFERENCE           = 0x2907,
        DESCRIPTOR_REPORT_REFERENCE                    = 0x2908,
        DESCRIPTOR_NUMBER_OF_DIGITALS                  = 0x2909,
        DESCRIPTOR_VALUE_TRIGGER_SETTING               = 0x290A,
        DESCRIPTOR_ES_CONFIGURATION                    = 0x290B,
        DESCRIPTOR_ES_MEASUREMENT                      = 0x290C,
        DESCRIPTOR_ES_TRIGGER_SETTING                  = 0x290D,
        DESCRIPTOR_TIME_TRIGGER_SETTING                = 0x290E,
        DESCRIPTOR_COMPLETE_BREDR_TRANSPORT_BLOCK_DATA = 0x290F,
        DESCRIPTOR_OBSERVATION_SCHEDULE                = 0x2910,
        DESCRIPTOR_VALID_RANGE_AND_ACCURACY            = 0x2911,
        DESCRIPTOR_MEASUREMENT_DESCRIPTION             = 0x2912,
        DESCRIPTOR_MANUFACTURER_LIMITS                 = 0x2913,
        DESCRIPTOR_PROCESS_TOLERANCES                  = 0x2914,
        DESCRIPTOR_IMD_TRIGGER_SETTING                 = 0x2915,
        DESCRIPTOR_COOKING_SENSOR_INFO                 = 0x2916,
        DESCRIPTOR_COOKING_TRIGGER_SETTING             = 0x2917,
    };

    /*!
     * \brief Environmental Sensing Measurement descriptor (0x290C), 11 octets
     */
    struct EnvironmentalSensingMeasurement
    {
        bool valid = false;
        uint16_t flags = 0;                  //!< Bit field, entirely RFU in ESS v1.0
        uint8_t sampling_function = 0;       //!< See samplingFunctionToString()
        uint32_t measurement_period = 0;     //!< In seconds, 0 means "not in use"
        uint32_t update_interval = 0;        //!< Internal update interval, in seconds, 0 means "not in use"
        uint8_t application = 0;             //!< See esApplicationToString()
        uint8_t uncertainty = 0;             //!< In 0.5% steps, 0xFF means "not available"
    };

    /*!
     * \brief Environmental Sensing Trigger Setting descriptor (0x290D), 1 to n octets
     */
    struct EnvironmentalSensingTriggerSetting
    {
        uint8_t condition = 0;      //!< See esTriggerConditionToString()
        QByteArray operand_raw;     //!< Operand, if any, still encoded
        QVariant operand;           //!< Operand, decoded (seconds, or a value in the characteristic format)
    };

    /*!
     * \brief Value Trigger Setting descriptor (0x290A), 1 to n octets
     */
    struct ValueTriggerSetting
    {
        bool valid = false;
        uint8_t condition = 0;        //!< See valueTriggerConditionToString()
        QByteArray comparison_raw;    //!< Comparison value, if any, still encoded
        QVariant comparison;          //!< Analog value (uint16), or the bit mask
        QVariant comparison2;         //!< Analog Two, for the "Analog Interval" conditions
    };

    /*!
     * \brief Time Trigger Setting descriptor (0x290E), 1 to 4 octets
     */
    struct TimeTriggerSetting
    {
        bool valid = false;
        uint8_t condition = 0;      //!< See timeTriggerConditionToString()
        QVariant operand;           //!< Time interval (uint24, seconds), or count (uint16)
    };

    /*!
     * \brief Observation Schedule descriptor (0x2910), 12 octets, from the Generic Health Sensor service
     */
    struct ObservationSchedule
    {
        bool valid = false;
        uint32_t observation_type = 0;  //!< MDC code of the observation
        QVariant measurement_period;    //!< IEEE 11073 FLOAT, in seconds, 0 means "unspecified"
        QVariant update_interval;       //!< IEEE 11073 FLOAT, in seconds, 0 means "unspecified"
    };

    /*!
     * \brief Measurement Description descriptor (0x2912), 2 to n octets,
     *        from the Industrial Measurement Device service
     *
     * Every field but the flags is optional. The Resolution and Absolute Uncertainty fields
     * use the format of the characteristic value, they are only decoded with a presentation format.
     */
    struct MeasurementDescription
    {
        bool valid = false;
        uint16_t flags = 0;                 //!< Presence of the fields below
        int sampling_function = -1;         //!< See imdSamplingFunctionToString()
        int measurement_period = -1;        //!< In milliseconds, 0 for an instantaneous value
        int update_interval = -1;           //!< Internal update interval, in milliseconds
        int description = -1;               //!< GATT Characteristic Presentation Format description
        QVariant resolution;                //!< In the characteristic format, or raw
        int relative_uncertainty = -1;      //!< In 0.1% steps
        QVariant absolute_uncertainty;      //!< In the characteristic format, or raw
    };

    /*!
     * \brief Comparison value formats, from the Automation IO service
     */
    enum ValueTriggerComparison
    {
        VALUE_TRIGGER_NONE            = 0, //!< No comparison value
        VALUE_TRIGGER_ANALOG          = 1, //!< Analog (uint16)
        VALUE_TRIGGER_BITMASK         = 2, //!< Same size and format as the Digital characteristic
        VALUE_TRIGGER_ANALOG_INTERVAL = 3, //!< Analog One (uint16), Analog Two (uint16)
    };

    /*!
     * \brief Valid Range and Accuracy descriptor (0x2911), 14 or 18 octets
     */
    struct ValidRangeAndAccuracy
    {
        bool valid = false;
        uint32_t observation_type = 0;  //!< MDC code of the observation
        uint16_t unit_code = 0;         //!< MDC code (partition 2) of the unit
        QVariant lower_limit;           //!< IEEE 11073 FLOAT
        QVariant upper_limit;           //!< IEEE 11073 FLOAT
        QVariant accuracy;              //!< IEEE 11073 FLOAT, optional
    };

    /*!
     * \brief Official descriptor name, ex: "Report Reference"
     */
    static QString descriptorToString(const uint16_t uuid);

    /*!
     * \brief Report Reference descriptor (0x2908) report type, from the HID service
     */
    static QString reportTypeToString(const uint8_t report_type);

    /*!
     * \brief ES Measurement sampling function, ex: "Arithmetic Mean"
     */
    static QString samplingFunctionToString(const uint8_t sampling_function);

    /*!
     * \brief ES Measurement application, ex: "Soil"
     */
    static QString esApplicationToString(const uint8_t application);

    /*!
     * \brief Decode an ES Measurement descriptor value (Flags | Sampling Function | Measurement Period | Update Interval | Application | Uncertainty)
     */
    static EnvironmentalSensingMeasurement readEnvironmentalSensingMeasurement(const QByteArray &data);

    /*!
     * \brief ES Trigger Setting condition, ex: "While greater than the specified value"
     */
    static QString esTriggerConditionToString(const uint8_t condition);

    /*!
     * \brief Conditions 0x01 and 0x02 use an uint24 operand, in seconds
     */
    static bool esTriggerOperandIsTime(const uint8_t condition);

    /*!
     * \brief Conditions 0x04 to 0x09 use an operand in the format of the characteristic value
     */
    static bool esTriggerOperandIsValue(const uint8_t condition);

    /*!
     * \brief Value Trigger Setting condition, ex: "Crossed a boundary"
     */
    static QString valueTriggerConditionToString(const uint8_t condition);

    /*!
     * \brief Comparison value format expected by a Value Trigger Setting condition
     */
    static ValueTriggerComparison valueTriggerComparisonFormat(const uint8_t condition);

    /*!
     * \brief Decode a Value Trigger Setting descriptor value (Condition | Comparison Value)
     */
    static ValueTriggerSetting readValueTriggerSetting(const QByteArray &data);

    /*!
     * \brief Decode a Valid Range and Accuracy descriptor value (Observation Type | Unit Code | Lower Limit | Upper Limit | Measurement Accuracy)
     */
    static ValidRangeAndAccuracy readValidRangeAndAccuracy(const QByteArray &data);

    /*!
     * \brief ES Configuration descriptor (0x290B) trigger logic
     */
    static QString esTriggerLogicToString(const uint8_t trigger_logic);

    /*!
     * \brief Time Trigger Setting condition, from the Automation IO service,
     *        ex: "Not more often than a time interval"
     */
    static QString timeTriggerConditionToString(const uint8_t condition);

    /*!
     * \brief Decode a Time Trigger Setting descriptor value (Condition | Value)
     *
     * Conditions 0x01 and 0x02 use an uint24 time interval in seconds,
     * condition 0x03 an uint16 count of value changes.
     */
    static TimeTriggerSetting readTimeTriggerSetting(const QByteArray &data);

    /*!
     * \brief Time Trigger Setting summary, ex: "Not more often than a time interval: 10 s"
     */
    static QString timeTriggerToString(const TimeTriggerSetting &tts);

    /*!
     * \brief Decode an Observation Schedule descriptor value (Observation Type | Measurement Period | Update Interval)
     */
    static ObservationSchedule readObservationSchedule(const QByteArray &data);

    /*!
     * \brief Measurement Description sampling function, ex: "Moving average"
     *
     * Not the same assigned numbers as the ES Measurement sampling function.
     */
    static QString imdSamplingFunctionToString(const uint8_t sampling_function);

    /*!
     * \brief Decode a Measurement Description descriptor value
     *        (Flags | Sampling Function | Measurement Period | Internal Update Interval |
     *        Description | Resolution | Relative Uncertainty | Absolute Uncertainty)
     * \param data: the descriptor value.
     * \param pf: the characteristic presentation format, nullptr if unknown or an aggregate.
     *
     * The variable size fields (Resolution and Absolute Uncertainty) share the same format,
     * so their size is deduced from what is left once the fixed size fields are read.
     * Without presentation format, they are kept as hexadecimal strings.
     */
    static MeasurementDescription readMeasurementDescription(const QByteArray &data,
                                                             const BleFormat::CharacteristicPresentationFormat *pf);

    /*!
     * \brief Decode a Valid Range descriptor value (Lower inclusive value | Upper inclusive value)
     * \param data: the descriptor value.
     * \param pf: the characteristic presentation format, nullptr if unknown or an aggregate.
     * \param min: lower inclusive value, decoded, or the raw first half when the format is unknown.
     * \param max: upper inclusive value, decoded, or the raw second half when the format is unknown.
     * \return false if the value could not be split in two.
     */
    static bool readValidRange(const QByteArray &data,
                               const BleFormat::CharacteristicPresentationFormat *pf,
                               QVariant &min, QVariant &max);

    /*!
     * \brief Decode an ES Trigger Setting descriptor value (Condition | Operand)
     * \param data: the descriptor value.
     * \param pf: the characteristic presentation format, used by the value operands,
     *        nullptr if unknown or an aggregate (the operand is then kept raw).
     * \param ts: the trigger setting to fill.
     * \return false if the descriptor is empty.
     */
    static bool readEsTriggerSetting(const QByteArray &data,
                                     const BleFormat::CharacteristicPresentationFormat *pf,
                                     EnvironmentalSensingTriggerSetting &ts);

    /*!
     * \brief ES Trigger Setting summary, ex: "While greater than the specified value: 25.0"
     */
    static QString esTriggerToString(const EnvironmentalSensingTriggerSetting &ts);

    /*!
     * \brief Value Trigger Setting summary, ex: "Crossed a boundary: 100 ... 2000"
     */
    static QString valueTriggerToString(const ValueTriggerSetting &vts);

    /*!
     * \brief Valid Range and Accuracy summary, ex: "0 ... 1000 (±5)"
     */
    static QString validRangeAndAccuracyToString(const ValidRangeAndAccuracy &vra);
};

/* ************************************************************************** */
#endif // BLE_DESCRIPTORS_H
