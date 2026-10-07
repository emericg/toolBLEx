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


#ifndef BLE_FORMAT_H
#define BLE_FORMAT_H
/* ************************************************************************** */

#include <cstdint>

#include <QString>
#include <QStringList>
#include <QList>
#include <QVariant>
#include <QByteArray>
#include <QBluetoothUuid>
#include <QObject>
#include <QCoreApplication>

/* ************************************************************************** */

/*!
 * \brief Characteristic Presentation Format, value decoding and encoding.
 *
 * References:
 * - Bluetooth Core Specification, Part G (GATT), 3.3.3.5 Characteristic Presentation Format
 * - Assigned Numbers, GATT Format Types / GATT Namespace Descriptors / Units
 */
class BleFormat
{
    Q_GADGET
    Q_DECLARE_TR_FUNCTIONS(BleFormat)

public:
    BleFormat() = delete;

    /*!
     * \brief Characteristic Presentation Format descriptor value (7 octets, little-endian)
     */
    struct CharacteristicPresentationFormat
    {
        uint8_t format = 0;        //!< Format of the characteristic value (see FormatType)
        int8_t exponent = 0;       //!< Decimal exponent: actual value = value * 10^exponent
        uint16_t unit = 0;         //!< Unit UUID (see unitToString())
        uint8_t nnamespace = 0;    //!< Organization owning the description enum (0x01 = Bluetooth SIG)
        uint16_t desc = 0;         //!< Description enumeration (see descriptionToString())
    };

    /*!
     * \brief GATT Format Types, from the Assigned Numbers
     */
    enum FormatType : uint8_t
    {
        FORMAT_RFU        = 0x00,
        FORMAT_BOOLEAN    = 0x01,
        FORMAT_UINT2      = 0x02,
        FORMAT_UINT4      = 0x03,
        FORMAT_UINT8      = 0x04,
        FORMAT_UINT12     = 0x05,
        FORMAT_UINT16     = 0x06,
        FORMAT_UINT24     = 0x07,
        FORMAT_UINT32     = 0x08,
        FORMAT_UINT48     = 0x09,
        FORMAT_UINT64     = 0x0A,
        FORMAT_UINT128    = 0x0B,
        FORMAT_SINT8      = 0x0C,
        FORMAT_SINT12     = 0x0D,
        FORMAT_SINT16     = 0x0E,
        FORMAT_SINT24     = 0x0F,
        FORMAT_SINT32     = 0x10,
        FORMAT_SINT48     = 0x11,
        FORMAT_SINT64     = 0x12,
        FORMAT_SINT128    = 0x13,
        FORMAT_FLOAT32    = 0x14,
        FORMAT_FLOAT64    = 0x15,
        FORMAT_MEDFLOAT16 = 0x16, //!< IEEE 11073-20601 SFLOAT
        FORMAT_MEDFLOAT32 = 0x17, //!< IEEE 11073-20601 FLOAT
        FORMAT_UINT16_2   = 0x18, //!< IEEE 11073-20601 nomenclature code
        FORMAT_UTF8S      = 0x19,
        FORMAT_UTF16S     = 0x1A,
        FORMAT_STRUCT     = 0x1B,
        FORMAT_MEDASN1    = 0x1C,
    };
    Q_ENUM(FormatType)

    /*!
     * \brief Result of writeValue()
     */
    enum WriteError
    {
        WRITE_OK = 0,               //!< Encoded exactly
        WRITE_PRECISION_LOST,       //!< Encoded, but rounded to fit the format (exponent, SFLOAT/FLOAT)
        WRITE_NOT_A_NUMBER,         //!< Cannot be parsed for that format
        WRITE_OUT_OF_RANGE,         //!< Does not fit in that format
        WRITE_UNSUPPORTED_FORMAT,   //!< RFU format
    };
    Q_ENUM(WriteError)

    /*!
     * \brief A decimal number, parsed from a string: (-1)^negative * digits * 10^exponent
     */
    struct DecimalValue
    {
        bool negative = false;
        QString digits;             //!< Without leading nor trailing zeros, empty for zero
        int exponent = 0;
    };

    /*!
     * \brief Shortest representation of an UUID, ex: "0x2904"
     */
    static QString uuidShort(const QBluetoothUuid &uuid);

    /*!
     * \brief Format short name, ex: "uint16"
     */
    static QString formatToString(const uint8_t format);

    /*!
     * \brief Format description, ex: "unsigned 16-bit integer"
     */
    static QString formatToDescription(const uint8_t format);

    /*!
     * \brief Size of a single value of that format, in bytes (0 if the format has a variable size)
     */
    static int formatSize(const uint8_t format);

    /*!
     * \brief Is the exponent field applicable to that format? (only integer formats use it)
     */
    static bool formatHasExponent(const uint8_t format);

    /*!
     * \brief Name Space field, ex: "Bluetooth SIG"
     */
    static QString namespaceToString(const uint8_t nnamespace);

    /*!
     * \brief Description field, using the GATT Namespace Descriptors (Bluetooth SIG name space)
     */
    static QString descriptionToString(const uint8_t nnamespace, const uint16_t desc);

    /*!
     * \brief Unit field, ex: "Celsius temperature (degree Celsius)"
     */
    static QString unitToString(const uint16_t unit);

    /*!
     * \brief Unit to append to a value, ex: "degree Celsius", "%".
     * \param unit: the presentation format unit UUID.
     * \return the unit name without its quantity, empty if unitless, dimensionless or unknown.
     */
    static QString unitName(const uint16_t unit);

    /*!
     * \brief Read 'bytes' bytes as a little-endian unsigned integer
     */
    static quint64 readUIntLE(const QByteArray &data, const int offset, const int bytes);

    /*!
     * \brief Read the IEEE 11073-20601 SFLOAT (medfloat16) at that offset
     */
    static QVariant readMedFloat16(const QByteArray &data, const int offset);

    /*!
     * \brief Read the IEEE 11073-20601 FLOAT (medfloat32) at that offset
     */
    static QVariant readMedFloat32(const QByteArray &data, const int offset);

    /*!
     * \brief Read a single value out of a characteristic value, using a presentation format.
     * \param data: the characteristic (or descriptor) value.
     * \param offset: where to start reading, in bytes.
     * \param format: one of the GATT format types (see FormatType).
     * \param exponent: the presentation format exponent (only used by integer formats).
     * \return the decoded value, or an invalid QVariant if it cannot be decoded.
     *
     * Fixed size formats are read as little-endian, as mandated by the GATT
     * specification. Variable size formats (strings, structures) consume everything
     * from 'offset' to the end of 'data'. Values wider than 64 bits are returned as
     * an hexadecimal string.
     */
    static QVariant readValue(const QByteArray &data, const int offset, const uint8_t format, const int8_t exponent = 0);

    /*!
     * \brief Human readable version of a value decoded by readValue().
     * \param value: the decoded value.
     * \param pf: the presentation format it was decoded with.
     * \return the value, followed by its unit if any, ex: "21.50 degree Celsius".
     *
     * Values scaled by a negative exponent keep as many decimals as the exponent allows.
     * Medical floats (whose own exponent is lost after decoding) use up to 10 significant digits.
     */
    static QString valueToString(const QVariant &value, const CharacteristicPresentationFormat &pf);

    /*!
     * \brief Decode a characteristic value using its presentation format(s).
     * \param data: the characteristic value.
     * \param formats: its presentation formats, more than one for an aggregate, in value order.
     * \return one human readable string per decoded field (see valueToString()).
     *
     * Decoding stops at the first field that is missing from the value, that uses an unknown format,
     * or that has a variable size without being the last one (its size cannot be known).
     */
    static QStringList readFormattedValues(const QByteArray &data, const QList <CharacteristicPresentationFormat> &formats);

    /*!
     * \brief Parse a decimal number, without going through a floating point representation.
     * \param str: ex: "-12.5", "+3", "4.2e-3" (C locale, no thousands separator).
     * \param dv: the parsed value.
     * \return false if 'str' is not a decimal number.
     */
    static bool parseDecimal(const QString &str, DecimalValue &dv);

    /*!
     * \brief Encode a single value, using a presentation format. The opposite of readValue().
     * \param value: the value to encode (usually a string, as typed by the user).
     * \param format: one of the GATT format types (see FormatType).
     * \param exponent: the presentation format exponent (only used by integer formats).
     * \param error: if set, the result of the encoding.
     * \return the encoded value, empty if it cannot be encoded.
     *
     * Fixed size formats are written as little-endian, as mandated by the GATT specification.
     * Integer formats take the actual value (ex: "21.5" with an exponent of -2 is
     * written as 2150), scaled exactly (no floating point conversion).
     * If it needs to be rounded, it is still encoded, but 'error' is set to WRITE_PRECISION_LOST.
     * Formats wider than 64 bits and structures take an hexadecimal string, like readValue() returns.
     */
    static QByteArray writeValue(const QVariant &value, const uint8_t format, const int8_t exponent = 0, WriteError *error = nullptr);

    /*!
     * \brief Encode a value typed by the user. writeValue(), plus the byte order and the empty value.
     * \param value: the value, as typed (hexadecimal for structures, see writeValue()).
     * \param format: one of the GATT format types (see FormatType).
     * \param bigEndian: reverse the bytes of numeric formats (GATT values are little-endian).
     * \param exponent: the presentation format exponent (only used by integer formats).
     * \param error: if set, the result of the encoding.
     * \return the encoded value, empty if it cannot be encoded, or if 'value' is empty (that is not an error).
     *
     * Values that need rounding are still encoded, but 'error' is set to WRITE_PRECISION_LOST.
     */
    static QByteArray encodeValue(const QString &value, const uint8_t format, const bool bigEndian = false,
                                  const int8_t exponent = 0, WriteError *error = nullptr);

    /*!
     * \brief Human readable reason of a writeValue() failure, ex: "out of range for this format".
     * \return an empty string for WRITE_OK.
     */
    static QString writeErrorToString(const WriteError error);

private:
    /*!
     * \brief Ordinal from a GATT Namespace Descriptor value, ex: 12 > "12th"
     */
    static QString ordinalToString(const uint16_t ordinal);

    /*!
     * \brief Sign extend a 'bits' wide two's complement value
     */
    static qint64 signExtend(const quint64 value, const int bits);

    /*!
     * \brief Apply the presentation format exponent, if any
     */
    static QVariant applyExponent(const QVariant &value, const uint8_t format, const int8_t exponent);

    /*!
     * \brief Scale a decimal number by a power of ten, and round it to an integer.
     * \param dv: the decimal number.
     * \param shift: power of ten to apply.
     * \param magnitude: |dv| * 10^shift, rounded half away from zero.
     * \return WRITE_OK, WRITE_PRECISION_LOST if rounded, or WRITE_OUT_OF_RANGE if it doesn't fit in 64 bits.
     */
    static WriteError scaleDecimal(const DecimalValue &dv, const int shift, quint64 &magnitude);

    /*!
     * \brief Width of an integer format, in bits (0 for non integer formats, and 128 bits formats)
     */
    static int formatIntegerBits(const uint8_t format, bool *isSigned = nullptr);

    /*!
     * \brief Append the 'bytes' lower bytes of 'raw', little-endian
     */
    static void appendUIntLE(QByteArray &out, const quint64 raw, const int bytes);

    /*!
     * \brief Encode an integer, little-endian, on the smallest number of bytes holding 'bits'.
     * \param shift: power of ten to apply to the value before encoding it (the opposite of the exponent).
     */
    static WriteError encodeInteger(const QString &str, const int bits, const bool isSigned, const int shift, QByteArray &out);

    /*!
     * \brief Encode an IEEE 11073-20601 SFLOAT (medfloat16) or FLOAT (medfloat32).
     * \param str: a decimal number, or "nan", "inf", "-inf".
     *
     * The largest exponent holding the value exactly (smallest mantissa) is used. If there is none,
     * the value is rounded using the smallest exponent that fits (WRITE_PRECISION_LOST).
     */
    static WriteError encodeMedFloat(const QString &str, const bool isShort, QByteArray &out);

    /*!
     * \brief Encode an IEEE 754 float32 or float64
     */
    static WriteError encodeFloat(const QString &str, const bool isDouble, QByteArray &out);

    /*!
     * \brief Encode an hexadecimal string, ex: "0x0102AB" or "01 02 ab", bytes are kept in that order
     */
    static WriteError encodeHex(const QString &str, QByteArray &out);
};

/* ************************************************************************** */
#endif // BLE_FORMAT_H
