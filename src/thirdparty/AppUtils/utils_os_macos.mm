/*!
 * Copyright (c) 2021 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
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
