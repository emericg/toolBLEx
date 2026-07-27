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

#include "PermissionManager_AndroidHelper.h"

#ifdef Q_OS_ANDROID
#include <QtCore/qcoreapplication_platform.h>
#include <QJniObject>
#include <QJniEnvironment>
#endif

/* ************************************************************************** */

AndroidPermissionHelper::SdkRange AndroidPermissionHelper::sdkRange(const QString &permission)
{
    if (permission == PostNotifications) return { 33, -1 }; // Android 13+, no (known) upper bound

    return {}; // untracked permission: {-1, -1} (no bounds)
}

bool AndroidPermissionHelper::applies(const QString &permission)
{
#ifdef Q_OS_ANDROID
    const int sdk = QNativeInterface::QAndroidApplication::sdkVersion();
    const SdkRange range = sdkRange(permission);

    if (range.minSdk >= 0 && sdk < range.minSdk) return false; // not a runtime permission yet on this device
    if (range.maxSdk >= 0 && sdk > range.maxSdk) return false; // no longer applicable on this device

    return true;
#else
    Q_UNUSED(permission)
    return false; // no Android runtime permissions off-device
#endif
}

bool AndroidPermissionHelper::check(const QString &permission)
{
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid()) return false;

    jint result = context.callMethod<jint>("checkSelfPermission", "(Ljava/lang/String;)I",
                                           QJniObject::fromString(permission).object<jstring>());

    return (result == 0); // PackageManager.PERMISSION_GRANTED
#else
    Q_UNUSED(permission)
    return false;
#endif
}

void AndroidPermissionHelper::request(const QString &permission)
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) return;

    QJniEnvironment env;
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray permArray = env->NewObjectArray(1, stringClass,
                                                 QJniObject::fromString(permission).object<jstring>());

    activity.callMethod<void>("requestPermissions", "([Ljava/lang/String;I)V", permArray, jint(1));

    env->DeleteLocalRef(permArray);
    env->DeleteLocalRef(stringClass);
#else
    Q_UNUSED(permission)
#endif
}

/* ************************************************************************** */
