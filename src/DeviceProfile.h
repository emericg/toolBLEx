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

#ifndef DEVICE_PROFILE_H
#define DEVICE_PROFILE_H
/* ************************************************************************** */

#include <QString>
#include <QByteArray>
#include <QRegularExpression>
#include <QJsonObject>
#include <QBluetoothUuid>

/* ************************************************************************** */

/*!
 * \brief Device profile file format.
 *
 * One JSON schema, shared by the services structure cache, the JSON device export, and the simulator profiles.
 * Files without a "format" key are legacy structure caches (version 0).
 */
class DeviceProfile
{
public:
    DeviceProfile() = delete;

    //! Value of the "format" key.
    static constexpr QLatin1StringView formatName{"toolblex-profile"};

    //! Version written by this build.
    static constexpr int formatVersion = 1;

    //! Extension of the exported and saved profiles.
    static constexpr QLatin1StringView fileSuffix{".toolblex.json"};

    //! Extension of the services structure cache.
    static constexpr QLatin1StringView cacheSuffix{".cache"};

    /*!
     * \brief Get the format version of a profile.
     * \param root: the profile root object.
     * \return the version, 0 for a legacy cache, -1 if this is not a toolBLEx profile.
     */
    static int version(const QJsonObject &root)
    {
        if (!root.contains(QLatin1StringView("format")))
        {
            return root.contains(QLatin1StringView("services")) ? 0 : -1;
        }
        if (root.value(QLatin1StringView("format")).toString() != formatName)
        {
            return -1;
        }

        return root.value(QLatin1StringView("version")).toInt(-1);
    }

    /*!
     * \brief Create a profile root object, with the format keys set.
     */
    static QJsonObject createRoot()
    {
        QJsonObject root;
        root.insert(QLatin1StringView("format"), formatName);
        root.insert(QLatin1StringView("version"), formatVersion);
        return root;
    }

    /*!
     * \brief Write a UUID the way the profiles store them.
     * \return the full 128-bit UUID, uppercase, with braces.
     */
    static QString uuidToString(const QBluetoothUuid &uuid)
    {
        return uuid.toString().toUpper();
    }

    /*!
     * \brief Write a value the way the profiles store them.
     * \return the value as an uppercase hexadecimal string, without separators.
     */
    static QString valueToString(const QByteArray &value)
    {
        return QString::fromLatin1(value.toHex().toUpper());
    }

    /*!
     * \brief Read a profile value.
     * \param hex: hexadecimal string, any case, with or without a "0x" prefix.
     */
    static QByteArray valueFromString(QString hex)
    {
        hex.remove(QLatin1Char(' '));
        if (hex.startsWith(QLatin1StringView("0x"), Qt::CaseInsensitive)) hex.remove(0, 2);
        return QByteArray::fromHex(hex.toLatin1());
    }

    /*!
     * \brief Read a UUID typed by the user.
     * \param uuid: ex: "180F", "0x180F", "0000180f", or a full 128-bit UUID.
     * \return the UUID as written in the profiles, empty if invalid.
     */
    static QString uuidFromUserString(const QString &uuid)
    {
        static const QRegularExpression shortUuid(QStringLiteral("^(0x)?([0-9a-fA-F]{4}|[0-9a-fA-F]{8})$"));

        const QString str = uuid.trimmed();
        const QRegularExpressionMatch match = shortUuid.match(str);
        if (match.hasMatch())
        {
            const QString digits = match.captured(2);
            if (digits.size() == 4) return uuidToString(QBluetoothUuid(quint16(digits.toUShort(nullptr, 16))));
            return uuidToString(QBluetoothUuid(quint32(digits.toUInt(nullptr, 16))));
        }

        const QBluetoothUuid full(str);
        if (full.isNull()) return QString();
        return uuidToString(full);
    }

    /*!
     * \brief Check a value typed by the user.
     * \param hex: ex: "0A1B", "0x0a1b", "0a 1b", empty is valid.
     */
    static bool isValueStringValid(const QString &hex)
    {
        static const QRegularExpression valid(QStringLiteral("^(0x)?([0-9a-fA-F]{2} ?)*$"));
        return valid.match(hex.trimmed()).hasMatch();
    }
};

/* ************************************************************************** */
#endif // DEVICE_PROFILE_H
