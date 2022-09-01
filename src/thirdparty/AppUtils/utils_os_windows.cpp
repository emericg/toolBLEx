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
 * \date      2021
 */

#include "utils_os_windows.h"

#if defined(Q_OS_WINDOWS)

#include <windows.h>
#include <QDebug>

/* ************************************************************************** */

void UtilsWindows::screenKeepOn(bool on)
{
    // ES_DISPLAY_REQUIRED prevents display sleep?
    // ES_SYSTEM_REQUIRED prevents idle sleep

    EXECUTION_STATE result;
    if (on)
    {
        result = SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED);
    }
    else
    {
        result = SetThreadExecutionState(ES_CONTINUOUS);
    }

    if (result == NULL)
    {
        qWarning() << "screenKeepOn() failed";
    }
}

/* ************************************************************************** */
#endif // Q_OS_WINDOWS
