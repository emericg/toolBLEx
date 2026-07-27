/*!
 * Copyright (c) 2026 Emeric Grange
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

#ifndef PERMISSIONMANAGER_ANDROIDHELPER_H
#define PERMISSIONMANAGER_ANDROIDHELPER_H
/* ************************************************************************** */

#include <QString>

/* ************************************************************************** */

/*!
 * \brief Thin static wrapper over Android's runtime-permission JNI calls.
 */
class AndroidPermissionHelper
{
public:
    //! android.permission.POST_NOTIFICATIONS (runtime permission, Android 13 / API 33+).
    static inline const QString PostNotifications = QStringLiteral("android.permission.POST_NOTIFICATIONS");

    //! Android API-level range over which a permission must be requested at runtime.
    struct SdkRange
    {
        int minSdk = -1; //!< First API level requiring a runtime request; -1 = no lower bound.
        int maxSdk = -1; //!< Last API level requiring it; -1 = no (known) upper bound.
    };

    //! The runtime-request API range for a known permission ({-1, -1} if untracked).
    static SdkRange sdkRange(const QString &permission);

    //! Whether 'permission' must be requested at runtime on THIS device's API level.
    static bool applies(const QString &permission);

    //! Whether the app currently holds the given Android runtime permission.
    static bool check(const QString &permission);

    //! Fire the (asynchronous) system request dialog for the given permission.
    static void request(const QString &permission);
};

/* ************************************************************************** */
#endif // PERMISSIONMANAGER_ANDROIDHELPER_H
