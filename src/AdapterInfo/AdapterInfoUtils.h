/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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

#ifndef ADAPTER_INFO_UTILS_H
#define ADAPTER_INFO_UTILS_H
/* ************************************************************************** */

#include <QString>

#include <iterator>

/* ************************************************************************** */

namespace AdapterInfoUtils {

/*!
 * \brief Convert a Bluetooth core version number (HCI / LMP version) to its specification name.
 * \param version: Core version number, from the Bluetooth SIG "Core Version" assigned numbers.
 * \return The specification version, ex: 13 > "5.4", or an empty string if unknown.
 */
inline QString coreVersionString(int version)
{
    static const char *const versions[] = {
        "1.0", "1.1", "1.2", "2.0", "2.1", "3.0", "4.0", "4.1", "4.2",
        "5.0", "5.1", "5.2", "5.3", "5.4", "6.0", "6.1", "6.2", "6.3",
    };

    if (version < 0 || version >= int(std::size(versions))) return QString();
    return QString::fromLatin1(versions[version]);
}

} // namespace AdapterInfoUtils

/* ************************************************************************** */
#endif // ADAPTER_INFO_UTILS_H
