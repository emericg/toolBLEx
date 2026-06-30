/*!
 * Copyright (c) 2023 Emeric Grange
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

#include "utils_os.h"

#if defined(Q_OS_LINUX)
#include "utils_os_linux.h"
#elif defined(Q_OS_MACOS)
#include "utils_os_macos.h"
#elif defined(Q_OS_WINDOWS)
#include "utils_os_windows.h"
#endif

#if defined(Q_OS_ANDROID)
#include "utils_os_android.h"
#elif defined(Q_OS_IOS)
#include "utils_os_ios.h"
#if defined(UTILS_NOTIFICATIONS_ENABLED)
#include "utils_os_ios_notif.h"
#endif
#endif

#include <QCoreApplication>
#include <QStyleHints>
#include <QQmlEngine>

/* ************************************************************************** */
/* ************************************************************************** */

UtilsOS *UtilsOS::getInstance()
{
    static UtilsOS *instance = new UtilsOS(QCoreApplication::instance());
    return instance;
}

UtilsOS *UtilsOS::create(QQmlEngine *, QJSEngine *)
{
    UtilsOS *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

UtilsOS::UtilsOS(QObject *parent) : QObject(parent)
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void UtilsOS::keepScreenOn(bool on, const QString &application, const QString &explanation)
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::screenKeepOn(on);
#elif defined(Q_OS_IOS)
    UtilsIOS::screenKeepOn(on);
#elif defined(Q_OS_MACOS)
    if (on && m_screensaverId <= 0)
    {
        m_screensaverId = UtilsMacOS::screenKeepOn(application, explanation);
    }
    else
    {
        UtilsMacOS::screenKeepAuto(m_screensaverId);
    }
#elif defined(Q_OS_LINUX)
    if (on && m_screensaverId <= 0)
    {
        m_screensaverId = UtilsLinux::screenKeepOn(application, explanation);
    }
    else
    {
        UtilsLinux::screenKeepAuto(m_screensaverId);
    }
#elif defined(Q_OS_WINDOWS)
    UtilsWindows::screenKeepOn(on);
#endif

    Q_UNUSED(on)
    Q_UNUSED(application)
    Q_UNUSED(explanation)
}

/* ************************************************************************** */

void UtilsOS::hapticFeedback(const HapticFeedback type)
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::vibrate(type);
#elif defined(Q_OS_IOS)
    UtilsIOS::vibrate(type);
#else
    Q_UNUSED(type)
#endif
}

/* ************************************************************************** */
/* ************************************************************************** */

bool UtilsOS::checkMobileBluetoothPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_bluetooth();
#elif defined(Q_OS_IOS)
    qWarning() << "Please use Qt permission system directly on iOS";
    return false;
#endif

    return true;
}

bool UtilsOS::getMobileBluetoothPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_bluetooth();
#elif defined(Q_OS_IOS)
    qWarning() << "Please use Qt permission system directly on iOS";
    return false;
#endif

    return true;
}

bool UtilsOS::checkMobileLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_location();
#endif

    return true;
}

bool UtilsOS::getMobileLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_location();
#endif

    return true;
}

bool UtilsOS::checkMobileBleLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_location_ble();
#endif

    return true;
}

bool UtilsOS::getMobileBleLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_location_ble();
#endif

    return true;
}

bool UtilsOS::checkMobileBackgroundLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_location_background();
#endif

    return true;
}

bool UtilsOS::getMobileBackgroundLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_location_background();
#endif

    return true;
}

bool UtilsOS::checkMobileStoragePermissions()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermissions_storage();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::getMobileStoragePermissions()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermissions_storage();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::checkMobileStorageReadPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_storage_read();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::getMobileStorageReadPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_storage_read();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::checkMobileStorageWritePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_storage_write();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::getMobileStorageWritePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_storage_write();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::checkMobileStorageFileSystemPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_storage_filesystem();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::getMobileStorageFileSystemPermission(const QString &packageName)
{
    Q_UNUSED(packageName)

#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_storage_filesystem(packageName);
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::checkMobilePhoneStatePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_phonestate();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::getMobilePhoneStatePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_phonestate();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

/* ************************************************************************** */

bool UtilsOS::checkMobileCameraPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_camera();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

bool UtilsOS::getMobileCameraPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_camera();
#elif defined(Q_OS_IOS)
    return false;
#endif

    return true;
}

/* ************************************************************************** */

bool UtilsOS::checkMobileNotificationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_notification();
#elif defined(Q_OS_IOS)
    #if defined(UTILS_NOTIFICATIONS_ENABLED)
        return UtilsIOSNotifications::checkPermission_notification();
    #else
        qWarning() << "UTILS_NOTIFICATIONS_ENABLED is not enabled";
    #endif
#endif

    return true;
}

bool UtilsOS::getMobileNotificationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_notification();
#elif defined(Q_OS_IOS)
    #if defined(UTILS_NOTIFICATIONS_ENABLED)
        return UtilsIOSNotifications::getPermission_notification();
    #else
        qWarning() << "UTILS_NOTIFICATIONS_ENABLED is not enabled";
    #endif
#endif

    return true;
}

/* ************************************************************************** */

bool UtilsOS::isMobileGpsEnabled()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::gpsutils_isGpsEnabled();
#elif defined(Q_OS_IOS)
    return false; // TODO?
#endif

    return false;
}

void UtilsOS::forceMobileGpsEnabled()
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::gpsutils_forceGpsEnabled();
#endif
}

/* ************************************************************************** */

QString UtilsOS::getMobileDeviceModel()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getDeviceModel();
#endif

    return QString();
}

QString UtilsOS::getMobileDeviceSerial()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getDeviceSerial();
#endif

    return QString();
}

/* ************************************************************************** */

int UtilsOS::getMobileStorageCount()
{
#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();
    return storages.size();
#endif

    return 0;
}

QString UtilsOS::getMobileStorageInternal()
{
    QString internal;

#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();

    if (storages.size() > 0)
        internal = storages.at(0);
#endif

    return internal;
}

QString UtilsOS::getMobileStorageExternal(int index)
{
#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();

    if (storages.size() > (1 + index))
        return storages.at(1 + index);
#endif

    Q_UNUSED(index)
    return QString();
}

QStringList UtilsOS::getMobileStorageExternals()
{
#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();

    if (storages.size() > 0)
        storages.removeFirst();

    return storages;
#endif

    return QStringList();
}

/* ************************************************************************** */
