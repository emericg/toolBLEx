/*!
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
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2020
 */

#ifndef UTILS_OS_IOS_H
#define UTILS_OS_IOS_H

#include <QtGlobal>

#if defined(Q_OS_IOS)
/* ************************************************************************** */

/*!
 * \brief iOS utils
 */
class UtilsIOS
{
public:
    static void screenKeepOn(bool on);

    static void screenLockOrientation(int orientation);
    static void screenLockOrientation(int orientation, bool autoRotate);
};

/* ************************************************************************** */
#endif // Q_OS_IOS
#endif // UTILS_OS_IOS_H
