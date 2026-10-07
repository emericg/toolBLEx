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


#include "BleFormat.h"

#include <algorithm>
#include <cmath>
#include <cctype>
#include <cstring>
#include <limits>

#include <QLocale>

/* ************************************************************************** */

QString BleFormat::uuidShort(const QBluetoothUuid &uuid)
{
    bool success = false;

    quint16 result16 = uuid.toUInt16(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = uuid.toUInt32(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return uuid.toString().toUpper().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}

/* ************************************************************************** */

QString BleFormat::formatToString(const uint8_t format)
{
    switch (format)
    {
        case FORMAT_BOOLEAN:    return QStringLiteral("boolean");
        case FORMAT_UINT2:      return QStringLiteral("uint2");
        case FORMAT_UINT4:      return QStringLiteral("uint4");
        case FORMAT_UINT8:      return QStringLiteral("uint8");
        case FORMAT_UINT12:     return QStringLiteral("uint12");
        case FORMAT_UINT16:     return QStringLiteral("uint16");
        case FORMAT_UINT24:     return QStringLiteral("uint24");
        case FORMAT_UINT32:     return QStringLiteral("uint32");
        case FORMAT_UINT48:     return QStringLiteral("uint48");
        case FORMAT_UINT64:     return QStringLiteral("uint64");
        case FORMAT_UINT128:    return QStringLiteral("uint128");
        case FORMAT_SINT8:      return QStringLiteral("sint8");
        case FORMAT_SINT12:     return QStringLiteral("sint12");
        case FORMAT_SINT16:     return QStringLiteral("sint16");
        case FORMAT_SINT24:     return QStringLiteral("sint24");
        case FORMAT_SINT32:     return QStringLiteral("sint32");
        case FORMAT_SINT48:     return QStringLiteral("sint48");
        case FORMAT_SINT64:     return QStringLiteral("sint64");
        case FORMAT_SINT128:    return QStringLiteral("sint128");
        case FORMAT_FLOAT32:    return QStringLiteral("float32");
        case FORMAT_FLOAT64:    return QStringLiteral("float64");
        case FORMAT_MEDFLOAT16: return QStringLiteral("medfloat16");
        case FORMAT_MEDFLOAT32: return QStringLiteral("medfloat32");
        case FORMAT_UINT16_2:   return QStringLiteral("uint16[2]");
        case FORMAT_UTF8S:      return QStringLiteral("utf8s");
        case FORMAT_UTF16S:     return QStringLiteral("utf16s");
        case FORMAT_STRUCT:     return QStringLiteral("struct");
        case FORMAT_MEDASN1:    return QStringLiteral("medASN1");
    }

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

QString BleFormat::formatToDescription(const uint8_t format)
{
    switch (format)
    {
        case FORMAT_BOOLEAN:    return QStringLiteral("unsigned 1-bit; 0 = false; 1 = true");
        case FORMAT_UINT2:      return QStringLiteral("unsigned 2-bit integer");
        case FORMAT_UINT4:      return QStringLiteral("unsigned 4-bit integer");
        case FORMAT_UINT8:      return QStringLiteral("unsigned 8-bit integer");
        case FORMAT_UINT12:     return QStringLiteral("unsigned 12-bit integer");
        case FORMAT_UINT16:     return QStringLiteral("unsigned 16-bit integer");
        case FORMAT_UINT24:     return QStringLiteral("unsigned 24-bit integer");
        case FORMAT_UINT32:     return QStringLiteral("unsigned 32-bit integer");
        case FORMAT_UINT48:     return QStringLiteral("unsigned 48-bit integer");
        case FORMAT_UINT64:     return QStringLiteral("unsigned 64-bit integer");
        case FORMAT_UINT128:    return QStringLiteral("unsigned 128-bit integer");
        case FORMAT_SINT8:      return QStringLiteral("signed 8-bit integer");
        case FORMAT_SINT12:     return QStringLiteral("signed 12-bit integer");
        case FORMAT_SINT16:     return QStringLiteral("signed 16-bit integer");
        case FORMAT_SINT24:     return QStringLiteral("signed 24-bit integer");
        case FORMAT_SINT32:     return QStringLiteral("signed 32-bit integer");
        case FORMAT_SINT48:     return QStringLiteral("signed 48-bit integer");
        case FORMAT_SINT64:     return QStringLiteral("signed 64-bit integer");
        case FORMAT_SINT128:    return QStringLiteral("signed 128-bit integer");
        case FORMAT_FLOAT32:    return QStringLiteral("IEEE-754 32-bit floating point");
        case FORMAT_FLOAT64:    return QStringLiteral("IEEE-754 64-bit floating point");
        case FORMAT_MEDFLOAT16: return QStringLiteral("IEEE 11073-20601 16-bit SFLOAT");
        case FORMAT_MEDFLOAT32: return QStringLiteral("IEEE 11073-20601 32-bit FLOAT");
        case FORMAT_UINT16_2:   return QStringLiteral("IEEE 11073-20601 nomenclature code");
        case FORMAT_UTF8S:      return QStringLiteral("UTF-8 string");
        case FORMAT_UTF16S:     return QStringLiteral("UTF-16 string");
        case FORMAT_STRUCT:     return QStringLiteral("opaque structure");
        case FORMAT_MEDASN1:    return QStringLiteral("IEEE-11073 ASN.1/MDER structure");
    }

    return QStringLiteral("Reserved for future use");
}

/* ************************************************************************** */

int BleFormat::formatSize(const uint8_t format)
{
    switch (format)
    {
        case FORMAT_BOOLEAN:
        case FORMAT_UINT2:
        case FORMAT_UINT4:
        case FORMAT_UINT8:
        case FORMAT_SINT8:      return 1;
        case FORMAT_UINT12:
        case FORMAT_UINT16:
        case FORMAT_SINT12:
        case FORMAT_SINT16:
        case FORMAT_MEDFLOAT16: return 2;
        case FORMAT_UINT24:
        case FORMAT_SINT24:     return 3;
        case FORMAT_UINT32:
        case FORMAT_SINT32:
        case FORMAT_FLOAT32:
        case FORMAT_MEDFLOAT32:
        case FORMAT_UINT16_2:   return 4;
        case FORMAT_UINT48:
        case FORMAT_SINT48:     return 6;
        case FORMAT_UINT64:
        case FORMAT_SINT64:
        case FORMAT_FLOAT64:    return 8;
        case FORMAT_UINT128:
        case FORMAT_SINT128:    return 16;
    }

    return 0; // utf8s, utf16s, struct, medASN1, RFU
}

/* ************************************************************************** */

bool BleFormat::formatHasExponent(const uint8_t format)
{
    return (format >= FORMAT_UINT2 && format <= FORMAT_SINT128);
}

/* ************************************************************************** */

QString BleFormat::namespaceToString(const uint8_t nnamespace)
{
    if (nnamespace == 0x01) return QStringLiteral("Bluetooth SIG");

    return QStringLiteral("RFU");
}

/* ************************************************************************** */

QString BleFormat::ordinalToString(const uint16_t ordinal)
{
    QString suffix = QStringLiteral("th");

    if ((ordinal % 100) < 11 || (ordinal % 100) > 13)
    {
        if ((ordinal % 10) == 1) suffix = QStringLiteral("st");
        else if ((ordinal % 10) == 2) suffix = QStringLiteral("nd");
        else if ((ordinal % 10) == 3) suffix = QStringLiteral("rd");
    }

    return QString::number(ordinal) + suffix;
}

/* ************************************************************************** */

QString BleFormat::descriptionToString(const uint8_t nnamespace, const uint16_t desc)
{
    if (nnamespace != 0x01) return QStringLiteral("0x") + QString::number(desc, 16).toUpper().rightJustified(4, '0');

    switch (desc)
    {
        case 0x0000: return QStringLiteral("unknown");

        case 0x0100: return QStringLiteral("front");
        case 0x0101: return QStringLiteral("back");
        case 0x0102: return QStringLiteral("top");
        case 0x0103: return QStringLiteral("bottom");
        case 0x0104: return QStringLiteral("upper");
        case 0x0105: return QStringLiteral("lower");
        case 0x0106: return QStringLiteral("main");
        case 0x0107: return QStringLiteral("backup");
        case 0x0108: return QStringLiteral("auxiliary");
        case 0x0109: return QStringLiteral("supplementary");
        case 0x010A: return QStringLiteral("flash");
        case 0x010B: return QStringLiteral("inside");
        case 0x010C: return QStringLiteral("outside");
        case 0x010D: return QStringLiteral("left");
        case 0x010E: return QStringLiteral("right");
        case 0x010F: return QStringLiteral("internal");
        case 0x0110: return QStringLiteral("external");
    }

    // 0x0001 to 0x00FF are ordinals ("first" to "two-hundred-and-fifty-fifth")
    if (desc <= 0x00FF) return ordinalToString(desc);

    return QStringLiteral("0x") + QString::number(desc, 16).toUpper().rightJustified(4, '0');
}

/* ************************************************************************** */

QString BleFormat::unitToString(const uint16_t unit)
{
    switch (unit)
    {
        case 0x2700: return QStringLiteral("unitless");
        case 0x2701: return QStringLiteral("length (metre)");
        case 0x2702: return QStringLiteral("mass (kilogram)");
        case 0x2703: return QStringLiteral("time (second)");
        case 0x2704: return QStringLiteral("electric current (ampere)");
        case 0x2705: return QStringLiteral("thermodynamic temperature (kelvin)");
        case 0x2706: return QStringLiteral("amount of substance (mole)");
        case 0x2707: return QStringLiteral("luminous intensity (candela)");

        case 0x2710: return QStringLiteral("area (square metres)");
        case 0x2711: return QStringLiteral("volume (cubic metres)");
        case 0x2712: return QStringLiteral("velocity (metres per second)");
        case 0x2713: return QStringLiteral("acceleration (metres per second squared)");
        case 0x2714: return QStringLiteral("wavenumber (reciprocal metre)");
        case 0x2715: return QStringLiteral("density (kilogram per cubic metre)");
        case 0x2716: return QStringLiteral("surface density (kilogram per square metre)");
        case 0x2717: return QStringLiteral("specific volume (cubic metre per kilogram)");
        case 0x2718: return QStringLiteral("current density (ampere per square metre)");
        case 0x2719: return QStringLiteral("magnetic field strength (ampere per metre)");
        case 0x271A: return QStringLiteral("amount concentration (mole per cubic metre)");
        case 0x271B: return QStringLiteral("mass concentration (kilogram per cubic metre)");
        case 0x271C: return QStringLiteral("luminance (candela per square metre)");
        case 0x271D: return QStringLiteral("refractive index");
        case 0x271E: return QStringLiteral("relative permeability");

        case 0x2720: return QStringLiteral("plane angle (radian)");
        case 0x2721: return QStringLiteral("solid angle (steradian)");
        case 0x2722: return QStringLiteral("frequency (hertz)");
        case 0x2723: return QStringLiteral("force (newton)");
        case 0x2724: return QStringLiteral("pressure (pascal)");
        case 0x2725: return QStringLiteral("energy (joule)");
        case 0x2726: return QStringLiteral("power (watt)");
        case 0x2727: return QStringLiteral("electric charge (coulomb)");
        case 0x2728: return QStringLiteral("electric potential difference (volt)");
        case 0x2729: return QStringLiteral("capacitance (farad)");
        case 0x272A: return QStringLiteral("electric resistance (ohm)");
        case 0x272B: return QStringLiteral("electric conductance (siemens)");
        case 0x272C: return QStringLiteral("magnetic flux (weber)");
        case 0x272D: return QStringLiteral("magnetic flux density (tesla)");
        case 0x272E: return QStringLiteral("inductance (henry)");
        case 0x272F: return QStringLiteral("Celsius temperature (degree Celsius)");
        case 0x2730: return QStringLiteral("luminous flux (lumen)");
        case 0x2731: return QStringLiteral("illuminance (lux)");
        case 0x2732: return QStringLiteral("activity referred to a radionuclide (becquerel)");
        case 0x2733: return QStringLiteral("absorbed dose (gray)");
        case 0x2734: return QStringLiteral("dose equivalent (sievert)");
        case 0x2735: return QStringLiteral("catalytic activity (katal)");

        case 0x2740: return QStringLiteral("dynamic viscosity (pascal second)");
        case 0x2741: return QStringLiteral("moment of force (newton metre)");
        case 0x2742: return QStringLiteral("surface tension (newton per metre)");
        case 0x2743: return QStringLiteral("angular velocity (radian per second)");
        case 0x2744: return QStringLiteral("angular acceleration (radian per second squared)");
        case 0x2745: return QStringLiteral("heat flux density (watt per square metre)");
        case 0x2746: return QStringLiteral("heat capacity (joule per kelvin)");
        case 0x2747: return QStringLiteral("specific heat capacity (joule per kilogram kelvin)");
        case 0x2748: return QStringLiteral("specific energy (joule per kilogram)");
        case 0x2749: return QStringLiteral("thermal conductivity (watt per metre kelvin)");
        case 0x274A: return QStringLiteral("energy density (joule per cubic metre)");
        case 0x274B: return QStringLiteral("electric field strength (volt per metre)");
        case 0x274C: return QStringLiteral("electric charge density (coulomb per cubic metre)");
        case 0x274D: return QStringLiteral("surface charge density (coulomb per square metre)");
        case 0x274E: return QStringLiteral("electric flux density (coulomb per square metre)");
        case 0x274F: return QStringLiteral("permittivity (farad per metre)");
        case 0x2750: return QStringLiteral("permeability (henry per metre)");
        case 0x2751: return QStringLiteral("molar energy (joule per mole)");
        case 0x2752: return QStringLiteral("molar entropy (joule per mole kelvin)");
        case 0x2753: return QStringLiteral("exposure (coulomb per kilogram)");
        case 0x2754: return QStringLiteral("absorbed dose rate (gray per second)");
        case 0x2755: return QStringLiteral("radiant intensity (watt per steradian)");
        case 0x2756: return QStringLiteral("radiance (watt per square metre steradian)");
        case 0x2757: return QStringLiteral("catalytic activity concentration (katal per cubic metre)");

        case 0x2760: return QStringLiteral("time (minute)");
        case 0x2761: return QStringLiteral("time (hour)");
        case 0x2762: return QStringLiteral("time (day)");
        case 0x2763: return QStringLiteral("plane angle (degree)");
        case 0x2764: return QStringLiteral("plane angle (minute)");
        case 0x2765: return QStringLiteral("plane angle (second)");
        case 0x2766: return QStringLiteral("area (hectare)");
        case 0x2767: return QStringLiteral("volume (litre)");
        case 0x2768: return QStringLiteral("mass (tonne)");

        case 0x2780: return QStringLiteral("pressure (bar)");
        case 0x2781: return QStringLiteral("pressure (millimetre of mercury)");
        case 0x2782: return QStringLiteral("length (ångström)");
        case 0x2783: return QStringLiteral("length (nautical mile)");
        case 0x2784: return QStringLiteral("area (barn)");
        case 0x2785: return QStringLiteral("velocity (knot)");
        case 0x2786: return QStringLiteral("logarithmic radio quantity (neper)");
        case 0x2787: return QStringLiteral("logarithmic radio quantity (bel)");

        case 0x27A0: return QStringLiteral("length (yard)");
        case 0x27A1: return QStringLiteral("length (parsec)");
        case 0x27A2: return QStringLiteral("length (inch)");
        case 0x27A3: return QStringLiteral("length (foot)");
        case 0x27A4: return QStringLiteral("length (mile)");
        case 0x27A5: return QStringLiteral("pressure (pound-force per square inch)");
        case 0x27A6: return QStringLiteral("velocity (kilometre per hour)");
        case 0x27A7: return QStringLiteral("velocity (mile per hour)");
        case 0x27A8: return QStringLiteral("angular velocity (revolution per minute)");
        case 0x27A9: return QStringLiteral("energy (gram calorie)");
        case 0x27AA: return QStringLiteral("energy (kilogram calorie)");
        case 0x27AB: return QStringLiteral("energy (kilowatt hour)");
        case 0x27AC: return QStringLiteral("thermodynamic temperature (degree Fahrenheit)");
        case 0x27AD: return QStringLiteral("percentage");
        case 0x27AE: return QStringLiteral("per mille");
        case 0x27AF: return QStringLiteral("period (beats per minute)");
        case 0x27B0: return QStringLiteral("electric charge (ampere hours)");
        case 0x27B1: return QStringLiteral("mass density (milligram per decilitre)");
        case 0x27B2: return QStringLiteral("mass density (millimole per litre)");
        case 0x27B3: return QStringLiteral("time (year)");
        case 0x27B4: return QStringLiteral("time (month)");
        case 0x27B5: return QStringLiteral("concentration (count per cubic metre)");
        case 0x27B6: return QStringLiteral("irradiance (watt per square metre)");
        case 0x27B7: return QStringLiteral("milliliter (per kilogram per minute)");
        case 0x27B8: return QStringLiteral("mass (pound)");
        case 0x27B9: return QStringLiteral("metabolic equivalent");
        case 0x27BA: return QStringLiteral("step (per minute)");
        case 0x27BC: return QStringLiteral("stroke (per minute)");
        case 0x27BD: return QStringLiteral("pace (kilometre per minute)");
        case 0x27BE: return QStringLiteral("luminous efficacy (lumen per watt)");
        case 0x27BF: return QStringLiteral("luminous energy (lumen hour)");
        case 0x27C0: return QStringLiteral("luminous exposure (lux hour)");
        case 0x27C1: return QStringLiteral("mass flow (gram per second)");
        case 0x27C2: return QStringLiteral("volume flow (litre per second)");
        case 0x27C3: return QStringLiteral("sound pressure (decibel)");
        case 0x27C4: return QStringLiteral("parts per million");
        case 0x27C5: return QStringLiteral("parts per billion");
        case 0x27C6: return QStringLiteral("mass density rate ((milligram per decilitre) per minute)");
        case 0x27C7: return QStringLiteral("electrical apparent energy (kilovolt ampere hour)");
        case 0x27C8: return QStringLiteral("electrical apparent power (volt ampere)");
        case 0x27C9: return QStringLiteral("gravity (gn)");
    }

    return QStringLiteral("unknown unit");
}

/* ************************************************************************** */

QString BleFormat::unitName(const uint16_t unit)
{
    switch (unit)
    {
        case 0x27AD: return QStringLiteral("%");
        case 0x27AE: return QStringLiteral("‰");
        case 0x27B9: return QStringLiteral("MET");
        case 0x27C4: return QStringLiteral("ppm");
        case 0x27C5: return QStringLiteral("ppb");
    }

    // "quantity (unit name)"
    const QString str = unitToString(unit);
    const qsizetype open = str.indexOf(QLatin1Char('('));
    const qsizetype close = str.lastIndexOf(QLatin1Char(')'));
    if (open < 0 || close <= open) return QString();

    return str.mid(open + 1, close - open - 1);
}

/* ************************************************************************** */

quint64 BleFormat::readUIntLE(const QByteArray &data, const int offset, const int bytes)
{
    quint64 value = 0;

    for (int i = 0; i < bytes; i++)
    {
        value |= static_cast<quint64>(static_cast<uint8_t>(data.at(offset + i))) << (8 * i);
    }

    return value;
}

/* ************************************************************************** */

qint64 BleFormat::signExtend(const quint64 value, const int bits)
{
    const quint64 sign = (Q_UINT64_C(1) << (bits - 1));
    if (value & sign) return static_cast<qint64>(value | ~((sign << 1) - 1));

    return static_cast<qint64>(value);
}

/* ************************************************************************** */

QVariant BleFormat::applyExponent(const QVariant &value, const uint8_t format,
                                  const int8_t exponent)
{
    if (exponent == 0 || !formatHasExponent(format)) return value;

    return QVariant(value.toDouble() * std::pow(10.0, exponent));
}

/* ************************************************************************** */

QVariant BleFormat::readMedFloat16(const QByteArray &data, const int offset)
{
    const quint16 raw = static_cast<quint16>(readUIntLE(data, offset, 2));
    const quint16 mantissa_raw = (raw & 0x0FFF);
    const int8_t exponent = static_cast<int8_t>(signExtend((raw >> 12) & 0x000F, 4));

    if (mantissa_raw == 0x07FF) return QVariant(std::nan(""));                                  // NaN
    if (mantissa_raw == 0x0800) return QVariant();                                              // NRes
    if (mantissa_raw == 0x07FE) return QVariant(std::numeric_limits <double>::infinity());      // +INFINITY
    if (mantissa_raw == 0x0802) return QVariant(-std::numeric_limits <double>::infinity());     // -INFINITY
    if (mantissa_raw == 0x0801) return QVariant();                                              // RFU

    const qint64 mantissa = signExtend(mantissa_raw, 12);

    return QVariant(mantissa * std::pow(10.0, exponent));
}

/* ************************************************************************** */

QVariant BleFormat::readMedFloat32(const QByteArray &data, const int offset)
{
    const quint32 raw = static_cast<quint32>(readUIntLE(data, offset, 4));
    const quint32 mantissa_raw = (raw & 0x00FFFFFF);
    const int8_t exponent = static_cast<int8_t>((raw >> 24) & 0xFF);

    if (mantissa_raw == 0x007FFFFF) return QVariant(std::nan(""));                              // NaN
    if (mantissa_raw == 0x00800000) return QVariant();                                          // NRes
    if (mantissa_raw == 0x007FFFFE) return QVariant(std::numeric_limits <double>::infinity());  // +INFINITY
    if (mantissa_raw == 0x00800002) return QVariant(-std::numeric_limits <double>::infinity()); // -INFINITY
    if (mantissa_raw == 0x00800001) return QVariant();                                          // RFU

    const qint64 mantissa = signExtend(mantissa_raw, 24);

    return QVariant(mantissa * std::pow(10.0, exponent));
}

/* ************************************************************************** */

QVariant BleFormat::readValue(const QByteArray &data, const int offset, const uint8_t format, const int8_t exponent)
{
    if (offset < 0 || offset >= data.size()) return QVariant();

    const int size = formatSize(format);
    if (size > 0 && (offset + size) > data.size()) return QVariant();

    switch (format)
    {
        case FORMAT_BOOLEAN:
            return QVariant(static_cast<bool>(readUIntLE(data, offset, 1) & 0x01));

        case FORMAT_UINT2:
            return applyExponent(QVariant::fromValue(readUIntLE(data, offset, 1) & 0x03), format, exponent);
        case FORMAT_UINT4:
            return applyExponent(QVariant::fromValue(readUIntLE(data, offset, 1) & 0x0F), format, exponent);
        case FORMAT_UINT8:
        case FORMAT_UINT16:
        case FORMAT_UINT24:
        case FORMAT_UINT32:
        case FORMAT_UINT48:
        case FORMAT_UINT64:
            return applyExponent(QVariant::fromValue(readUIntLE(data, offset, size)), format, exponent);
        case FORMAT_UINT12:
            return applyExponent(QVariant::fromValue(readUIntLE(data, offset, 2) & 0x0FFF), format, exponent);

        case FORMAT_SINT8:
        case FORMAT_SINT16:
        case FORMAT_SINT24:
        case FORMAT_SINT32:
        case FORMAT_SINT48:
        case FORMAT_SINT64:
            return applyExponent(QVariant::fromValue(signExtend(readUIntLE(data, offset, size), size * 8)), format, exponent);
        case FORMAT_SINT12:
            return applyExponent(QVariant::fromValue(signExtend(readUIntLE(data, offset, 2) & 0x0FFF, 12)), format, exponent);

        case FORMAT_UINT128:
        case FORMAT_SINT128:
            return QVariant(QStringLiteral("0x") + data.mid(offset, size).toHex().toUpper());

        case FORMAT_FLOAT32:
        {
            const quint32 raw = static_cast<quint32>(readUIntLE(data, offset, 4));
            float f; memcpy(&f, &raw, sizeof(f));
            return QVariant(f);
        }
        case FORMAT_FLOAT64:
        {
            const quint64 raw = readUIntLE(data, offset, 8);
            double d; memcpy(&d, &raw, sizeof(d));
            return QVariant(d);
        }

        case FORMAT_MEDFLOAT16:
            return readMedFloat16(data, offset);
        case FORMAT_MEDFLOAT32:
            return readMedFloat32(data, offset);

        case FORMAT_UINT16_2:
            return QVariant(QStringLiteral("0x") + QString::number(readUIntLE(data, offset, 2), 16).toUpper().rightJustified(4, '0') +
                            QStringLiteral(" 0x") + QString::number(readUIntLE(data, offset + 2, 2), 16).toUpper().rightJustified(4, '0'));

        case FORMAT_UTF8S:
            return QVariant(QString::fromUtf8(data.mid(offset)));
        case FORMAT_UTF16S:
        {
            const int count = (data.size() - offset) / 2;
            QString str;
            str.reserve(count);
            for (int i = 0; i < count; i++)
            {
                str += QChar(static_cast<char16_t>(readUIntLE(data, offset + (i * 2), 2)));
            }
            return QVariant(str);
        }

        case FORMAT_STRUCT:
        case FORMAT_MEDASN1:
            return QVariant(QStringLiteral("0x") + data.mid(offset).toHex().toUpper());
    }

    return QVariant();
}

/* ************************************************************************** */

QString BleFormat::valueToString(const QVariant &value, const CharacteristicPresentationFormat &pf)
{
    if (!value.isValid()) return QStringLiteral("invalid");

    QString str;

    if (value.typeId() == QMetaType::Bool)
    {
        str = value.toBool() ? QStringLiteral("true") : QStringLiteral("false");
    }
    else if (value.typeId() == QMetaType::Double && formatHasExponent(pf.format) && pf.exponent < 0)
    {
        str = QString::number(value.toDouble(), 'f', -pf.exponent);
    }
    else if (pf.format == FORMAT_MEDFLOAT16 || pf.format == FORMAT_MEDFLOAT32)
    {
        str = QString::number(value.toDouble(), 'g', 10);
    }
    else
    {
        str = value.toString();
    }

    switch (pf.format)
    {
        case FORMAT_UTF8S:
        case FORMAT_UTF16S:
        case FORMAT_STRUCT:
        case FORMAT_MEDASN1:
            return str;
    }

    const QString unit = unitName(pf.unit);
    if (!unit.isEmpty()) str += QLatin1Char(' ') + unit;

    return str;
}

/* ************************************************************************** */

QStringList BleFormat::readFormattedValues(const QByteArray &data, const QList <CharacteristicPresentationFormat> &formats)
{
    QStringList out;
    int offset = 0;

    for (int i = 0; i < formats.size(); i++)
    {
        const CharacteristicPresentationFormat &pf = formats.at(i);
        const int size = formatSize(pf.format);

        if (pf.format == FORMAT_RFU || pf.format > FORMAT_MEDASN1) break;
        if (size <= 0 && i < (formats.size() - 1)) break;
        if (offset >= data.size() || (offset + size) > data.size()) break;

        out += valueToString(readValue(data, offset, pf.format, pf.exponent), pf);
        offset += size;
    }

    return out;
}

/* ************************************************************************** */

bool BleFormat::parseDecimal(const QString &str, DecimalValue &dv)
{
    const QString s = str.trimmed();
    dv = DecimalValue();

    int i = 0;
    if (i < s.size() && (s.at(i) == u'+' || s.at(i) == u'-')) dv.negative = (s.at(i++) == u'-');

    QString digits;
    int fraction = 0;
    bool dot = false;

    for (; i < s.size(); i++)
    {
        const char16_t c = s.at(i).unicode();
        if (c >= u'0' && c <= u'9')
        {
            digits += QChar(c);
            if (dot) fraction++;
        }
        else if (c == u'.' && !dot) dot = true;
        else break;
    }
    if (digits.isEmpty()) return false;

    int exp10 = 0;
    if (i < s.size() && (s.at(i) == u'e' || s.at(i) == u'E'))
    {
        const QString e = s.mid(i + 1);
        bool ok = !e.isEmpty() && !e.at(0).isSpace();
        if (ok) exp10 = e.toInt(&ok);
        if (!ok || exp10 < -1000 || exp10 > 1000) return false;
        i = s.size();
    }
    if (i != s.size()) return false;

    int lead = 0;
    while (lead < digits.size() && digits.at(lead) == u'0') lead++;

    dv.digits = digits.mid(lead);
    dv.exponent = exp10 - fraction;

    while (dv.digits.endsWith(u'0'))
    {
        dv.digits.chop(1);
        dv.exponent++;
    }
    if (dv.digits.isEmpty())
    {
        dv.negative = false;
        dv.exponent = 0;
    }

    return true;
}

/* ************************************************************************** */

BleFormat::WriteError BleFormat::scaleDecimal(const DecimalValue &dv, const int shift, quint64 &magnitude)
{
    magnitude = 0;
    if (dv.digits.isEmpty()) return WRITE_OK;

    const int size = dv.digits.size();
    const int total = dv.exponent + shift;
    bool ok = false;

    if (total >= 0)
    {
        if (size + total > 20) return WRITE_OUT_OF_RANGE;
        magnitude = (dv.digits + QString(total, u'0')).toULongLong(&ok);
        return ok ? WRITE_OK : WRITE_OUT_OF_RANGE;
    }

    // Trailing zeros are stripped, so dropping digits always loses precision
    const int drop = -total;
    if (drop > size) return WRITE_PRECISION_LOST; // rounds to 0

    const QString kept = dv.digits.left(size - drop);
    if (kept.size() > 20) return WRITE_OUT_OF_RANGE;
    if (!kept.isEmpty())
    {
        magnitude = kept.toULongLong(&ok);
        if (!ok) return WRITE_OUT_OF_RANGE;
    }
    if (dv.digits.at(size - drop) >= u'5')
    {
        if (magnitude == std::numeric_limits<quint64>::max()) return WRITE_OUT_OF_RANGE;
        magnitude++;
    }

    return WRITE_PRECISION_LOST;
}

/* ************************************************************************** */

int BleFormat::formatIntegerBits(const uint8_t format, bool *isSigned)
{
    if (isSigned) *isSigned = (format >= FORMAT_SINT8 && format <= FORMAT_SINT128);

    switch (format)
    {
        case FORMAT_BOOLEAN:    return 1;
        case FORMAT_UINT2:      return 2;
        case FORMAT_UINT4:      return 4;
        case FORMAT_UINT8:
        case FORMAT_SINT8:      return 8;
        case FORMAT_UINT12:
        case FORMAT_SINT12:     return 12;
        case FORMAT_UINT16:
        case FORMAT_SINT16:     return 16;
        case FORMAT_UINT24:
        case FORMAT_SINT24:     return 24;
        case FORMAT_UINT32:
        case FORMAT_SINT32:     return 32;
        case FORMAT_UINT48:
        case FORMAT_SINT48:     return 48;
        case FORMAT_UINT64:
        case FORMAT_SINT64:     return 64;
    }

    return 0;
}

/* ************************************************************************** */

void BleFormat::appendUIntLE(QByteArray &out, const quint64 raw, const int bytes)
{
    for (int i = 0; i < bytes; i++)
    {
        out.append(static_cast<char>((raw >> (8 * i)) & 0xFF));
    }
}

/* ************************************************************************** */

BleFormat::WriteError BleFormat::encodeInteger(const QString &str, const int bits,
                                               const bool isSigned, const int shift,
                                               QByteArray &out)
{
    DecimalValue dv;
    if (!parseDecimal(str, dv)) return WRITE_NOT_A_NUMBER;

    quint64 magnitude = 0;
    const WriteError status = scaleDecimal(dv, shift, magnitude);
    if (status == WRITE_OUT_OF_RANGE) return status;

    const bool negative = (dv.negative && magnitude > 0);
    quint64 raw = magnitude;

    if (isSigned)
    {
        const quint64 limit = (Q_UINT64_C(1) << (bits - 1));
        if (negative ? (magnitude > limit) : (magnitude >= limit)) return WRITE_OUT_OF_RANGE;
        if (negative) raw = (~magnitude + 1);
    }
    else
    {
        if (negative) return WRITE_OUT_OF_RANGE;
        if (bits < 64 && magnitude >= (Q_UINT64_C(1) << bits)) return WRITE_OUT_OF_RANGE;
    }

    if (bits < 64) raw &= ((Q_UINT64_C(1) << bits) - 1);
    appendUIntLE(out, raw, (bits + 7) / 8);

    return status;
}

/* ************************************************************************** */

BleFormat::WriteError BleFormat::encodeMedFloat(const QString &str, const bool isShort, QByteArray &out)
{
    const int mantissaBits = isShort ? 12 : 24;
    const int exponentBits = isShort ? 4 : 8;
    const qint64 maxMantissa = (Q_INT64_C(1) << (mantissaBits - 1)) - 3; // above are the special values
    const int minExp = -(1 << (exponentBits - 1));
    const int maxExp = (1 << (exponentBits - 1)) - 1;

    qint64 mantissa = 0;
    int exponent = 0;
    WriteError status = WRITE_OK;

    const QString s = str.trimmed().toLower();
    if (s == QLatin1String("nan")) mantissa = maxMantissa + 2;
    else if (s == QLatin1String("inf") || s == QLatin1String("+inf")) mantissa = maxMantissa + 1;
    else if (s == QLatin1String("-inf")) mantissa = -(maxMantissa + 1);
    else
    {
        DecimalValue dv;
        if (!parseDecimal(str, dv)) return WRITE_NOT_A_NUMBER;

        status = WRITE_OUT_OF_RANGE;
        for (int x = qBound(minExp, dv.exponent, maxExp); x <= maxExp; x++)
        {
            quint64 magnitude = 0;
            const WriteError st = scaleDecimal(dv, -x, magnitude);
            if (st == WRITE_OUT_OF_RANGE || magnitude > static_cast<quint64>(maxMantissa)) continue;

            mantissa = dv.negative ? -static_cast<qint64>(magnitude) : static_cast<qint64>(magnitude);
            exponent = x;
            status = st;
            break;
        }
        if (status == WRITE_OUT_OF_RANGE) return status;
    }

    const quint64 raw = ((static_cast<quint64>(exponent) & ((1 << exponentBits) - 1)) << mantissaBits) |
                        (static_cast<quint64>(mantissa) & ((Q_UINT64_C(1) << mantissaBits) - 1));
    appendUIntLE(out, raw, isShort ? 2 : 4);

    return status;
}

/* ************************************************************************** */

BleFormat::WriteError BleFormat::encodeFloat(const QString &str, const bool isDouble, QByteArray &out)
{
    bool ok = false;
    const double d = str.trimmed().toDouble(&ok);
    if (!ok) return std::isinf(d) ? WRITE_OUT_OF_RANGE : WRITE_NOT_A_NUMBER;

    if (isDouble)
    {
        quint64 raw;
        memcpy(&raw, &d, sizeof(raw));
        appendUIntLE(out, raw, 8);
    }
    else
    {
        if (std::isfinite(d) && std::fabs(d) > std::numeric_limits<float>::max()) return WRITE_OUT_OF_RANGE;

        const float f = static_cast<float>(d);
        quint32 raw;
        memcpy(&raw, &f, sizeof(raw));
        appendUIntLE(out, raw, 4);
    }

    return WRITE_OK;
}

/* ************************************************************************** */

BleFormat::WriteError BleFormat::encodeHex(const QString &str, QByteArray &out)
{
    QString s = str.trimmed();
    if (s.startsWith(QLatin1String("0x"), Qt::CaseInsensitive)) s = s.mid(2);

    QByteArray hex;
    for (const QChar c: std::as_const(s))
    {
        if (c.isSpace()) continue;
        if (c.unicode() > 0x7F || !isxdigit(c.toLatin1())) return WRITE_NOT_A_NUMBER;
        hex += c.toLatin1();
    }
    if (hex.isEmpty() || (hex.size() % 2) != 0) return WRITE_NOT_A_NUMBER;

    out += QByteArray::fromHex(hex);

    return WRITE_OK;
}

/* ************************************************************************** */

QByteArray BleFormat::writeValue(const QVariant &value, const uint8_t format,
                                 const int8_t exponent, WriteError *error)
{
    QString str;
    if (value.typeId() == QMetaType::Bool)
        str = value.toBool() ? QStringLiteral("1") : QStringLiteral("0");
    else if (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::Float)
        str = QString::number(value.toDouble(), 'g', QLocale::FloatingPointShortest);
    else
        str = value.toString();

    QByteArray out;
    WriteError status = WRITE_OK;

    bool isSigned = false;
    const int bits = formatIntegerBits(format, &isSigned);

    if (bits > 0)
    {
        if (format == FORMAT_BOOLEAN)
        {
            const QString b = str.trimmed().toLower();
            if (b == QLatin1String("true")) str = QStringLiteral("1");
            else if (b == QLatin1String("false")) str = QStringLiteral("0");
        }

        const int shift = formatHasExponent(format) ? -exponent : 0;
        status = encodeInteger(str, bits, isSigned, shift, out);
    }
    else
    {
        switch (format)
        {
            case FORMAT_FLOAT32:    status = encodeFloat(str, false, out); break;
            case FORMAT_FLOAT64:    status = encodeFloat(str, true, out); break;
            case FORMAT_MEDFLOAT16: status = encodeMedFloat(str, true, out); break;
            case FORMAT_MEDFLOAT32: status = encodeMedFloat(str, false, out); break;

            case FORMAT_UTF8S:
                out = str.toUtf8();
                break;
            case FORMAT_UTF16S:
                for (const QChar c: std::as_const(str)) appendUIntLE(out, c.unicode(), 2);
                break;

            case FORMAT_UINT128:
            case FORMAT_SINT128:
                status = encodeHex(str, out);
                if (status == WRITE_OK && out.size() != 16) status = WRITE_OUT_OF_RANGE;
                break;

            case FORMAT_UINT16_2:
            {
                // ex: "0x1234 0xABCD", as readValue() returns it
                const QStringList parts = str.split(QLatin1Char(' '), Qt::SkipEmptyParts);
                if (parts.size() != 2) { status = WRITE_NOT_A_NUMBER; break; }

                for (const QString &p: parts)
                {
                    bool ok = false;
                    const uint v = QString(p).remove(QLatin1String("0x"), Qt::CaseInsensitive).toUInt(&ok, 16);
                    if (!ok) { status = WRITE_NOT_A_NUMBER; break; }
                    if (v > 0xFFFF) { status = WRITE_OUT_OF_RANGE; break; }
                    appendUIntLE(out, v, 2);
                }
            } break;

            case FORMAT_STRUCT:
            case FORMAT_MEDASN1:
                status = encodeHex(str, out);
                break;

            default:
                status = WRITE_UNSUPPORTED_FORMAT;
                break;
        }
    }

    if (status >= WRITE_NOT_A_NUMBER) out.clear();
    if (error) *error = status;

    return out;
}

/* ************************************************************************** */

QByteArray BleFormat::encodeValue(const QString &value, const uint8_t format, const bool bigEndian,
                                  const int8_t exponent, WriteError *error)
{
    if (error) *error = WRITE_OK;
    if (value.isEmpty()) return QByteArray();

    QByteArray out = writeValue(value, format, exponent, error);

    // Numbers only, hexadecimal formats (uint128, uint16[2], struct...) are typed in transmission order
    const bool numeric = (formatIntegerBits(format) > 0 ||
                          format == FORMAT_FLOAT32 || format == FORMAT_FLOAT64 ||
                          format == FORMAT_MEDFLOAT16 || format == FORMAT_MEDFLOAT32);
    if (bigEndian && numeric)
    {
        std::reverse(out.begin(), out.end());
    }

    return out;
}

/* ************************************************************************** */

QString BleFormat::writeErrorToString(const WriteError error)
{
    switch (error)
    {
        case WRITE_OK:                  return QString();
        case WRITE_PRECISION_LOST:      return tr("the value would be rounded");
        case WRITE_NOT_A_NUMBER:        return tr("invalid value for this format");
        case WRITE_OUT_OF_RANGE:        return tr("out of range for this format");
        case WRITE_UNSUPPORTED_FORMAT:  return tr("unsupported format");
    }

    return QString();
}

/* ************************************************************************** */
