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

#include "utils_os_macos.h"

#if defined(Q_OS_MACOS)

#include <objc/runtime.h>
#include <IOKit/pwr_mgt/IOPMLib.h>

/* ************************************************************************** */

uint32_t UtilsMacOS::screenKeepOn(const QString &application, const QString &reason)
{
    Q_UNUSED(application)

    // kIOPMAssertionTypeNoDisplaySleep prevents display sleep
    // kIOPMAssertionTypeNoIdleSleep prevents idle sleep

    // reasonForActivity is a descriptive string (128 characters max) used by the
    // system whenever it needs to tell the user why the system is not sleeping.
    QString reason_nonconst = reason;
    reason_nonconst.truncate(128);
    CFStringRef reasonForActivity = reason_nonconst.toCFString();

    IOPMAssertionID assertionID;
    IOReturn status = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                                  kIOPMAssertionLevelOn, reasonForActivity, &assertionID);

    CFRelease(reasonForActivity);

    if (status == kIOReturnSuccess)
    {
        return assertionID;
    }

    return 0;
}

void UtilsMacOS::screenKeepAuto(uint32_t screensaverId)
{
    IOReturn status = IOPMAssertionRelease(screensaverId);
    if (status == kIOReturnSuccess)
    {
        //
    }
}

/* ************************************************************************** */
#endif // Q_OS_MACOS
