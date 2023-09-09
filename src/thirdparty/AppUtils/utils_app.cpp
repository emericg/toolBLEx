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

#include "utils_app.h"

#if defined(Q_OS_ANDROID)
#include "utils_os_android.h"
#elif defined(Q_OS_IOS)
#include "utils_os_ios.h"
#endif

#include <cmath>

#include <QDir>
#include <QSize>
#include <QColor>

#include <QCoreApplication>
#include <QStandardPaths>
#include <QDesktopServices>

/* ************************************************************************** */

UtilsApp *UtilsApp::instance = nullptr;

UtilsApp *UtilsApp::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsApp();
    }

    return instance;
}

UtilsApp::UtilsApp()
{
    // Set default application path
    m_appPath = QCoreApplication::applicationDirPath();

    // Make sure the path is terminated with a separator?
    //if (!m_appPath.endsWith('/')) m_appPath += '/';
}

UtilsApp::~UtilsApp()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

QString UtilsApp::appName()
{
    return QString::fromLatin1(APP_NAME);
}

QString UtilsApp::appVersion()
{
    return QString::fromLatin1(APP_VERSION);
}

QString UtilsApp::appBuildDate()
{
    return QString::fromLatin1(__DATE__);
}

QString UtilsApp::appBuildDateTime()
{
    return QString::fromLatin1(__DATE__) + " " + QString::fromLatin1(__TIME__);
}

QString UtilsApp::appBuildMode()
{
#if !defined(QT_NO_DEBUG) && !defined(NDEBUG)
    return "DEBUG";
#endif

    return "";
}

QString UtilsApp::appBuildModeFull()
{
#if defined(QT_NO_DEBUG) || defined(NDEBUG)
    return "RELEASE";
#endif

    return "DEBUG";
}

bool UtilsApp::isDebugBuild()
{
#if defined(QT_NO_DEBUG) || defined(NDEBUG)
    return false;
#endif

    return true;
}

QString UtilsApp::qtVersion()
{
    return QString(qVersion());
}

/* ************************************************************************** */
/* ************************************************************************** */

void UtilsApp::appExit()
{
    QCoreApplication::exit();
}

/* ************************************************************************** */

void UtilsApp::setAppPath(const QString &value)
{
    if (m_appPath != value)
    {
        QDir newpath(value);
        newpath.cdUp();
        m_appPath = newpath.absolutePath();

        // Make sure the path is terminated with a separator.
        if (!m_appPath.endsWith('/')) m_appPath += '/';
    }
}

/* ************************************************************************** */

void UtilsApp::vibrate(int ms)
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::vibrate(ms);
#elif defined(Q_OS_IOS)
    return UtilsIOS::vibrate(ms);
#else
    Q_UNUSED(ms)
#endif
}

/* ************************************************************************** */

void UtilsApp::openWith(const QString &path)
{
    QUrl url;

#if defined(Q_OS_ANDROID)
    // Starting from API 24, open will only accept path begining by "content://"

    if (path.startsWith("/"))
    {
        url = "content://" + path;
    }
    else if (path.startsWith("file://"))
    {
        QString  newpath = path;
        newpath = newpath.replace("file://", "content://");
        url = newpath;
    }
    else if (path.startsWith("content://"))
    {
        url = path;
    }

#elif defined(Q_OS_IOS)

    url = QUrl::fromLocalFile(path);

#else // defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)

    url = QUrl::fromLocalFile(path);

#endif

    //qDebug() << "url:" << url;
    QDesktopServices::openUrl(url);
}

/* ************************************************************************** */

bool UtilsApp::isColorLight(const int color)
{
    int r = (color & 0x00FF0000) >> 16;
    int g = (color & 0x0000FF00) >> 8;
    int b = (color & 0x000000FF);

    double darkness = 1.0 - (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
    return (darkness < 0.2);
}

bool UtilsApp::isQColorLight(const QColor &color)
{
    double darkness = 1.0 - (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255.0;
    return (darkness < 0.2);
}

/* ************************************************************************** */
/* ************************************************************************** */

QUrl UtilsApp::getStandardPath_url(const QString &type)
{
    return QUrl::fromLocalFile(getStandardPath_string(type));
}

QString UtilsApp::getStandardPath_string(const QString &type)
{
    QString path;
    QStringList paths;

    if (type == "audio")
        paths = QStandardPaths::standardLocations(QStandardPaths::MusicLocation);
    else if (type == "video")
        paths = QStandardPaths::standardLocations(QStandardPaths::MoviesLocation);
    else if (type == "photo")
        paths = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    else
    {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        paths = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation); // DEPRECATED
#else
        paths = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
#endif
    }

    if (!paths.isEmpty()) path = paths.at(0);

    return path;
}

/* ************************************************************************** */
/* ************************************************************************** */

int UtilsApp::getAndroidSdkVersion()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getSdkVersion();
#else
    return 0;
#endif
}

void UtilsApp::openAndroidAppInfo(const QString &packageName)
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::openApplicationInfo(packageName);
#endif

    Q_UNUSED(packageName)
}

void UtilsApp::openAndroidStorageSettings(const QString &packageName)
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::openStorageSettings(packageName);
#endif

    Q_UNUSED(packageName)
}

void UtilsApp::openAndroidLocationSettings()
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::openLocationSettings();
#endif
}

bool UtilsApp::checkMobileLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_location();
#else
    return true;
#endif
}

bool UtilsApp::getMobileLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_location();
#else
    return true;
#endif
}

bool UtilsApp::checkMobileBleLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_location_ble();
#elif defined(Q_OS_IOS)
    return true; // TODO // we know have Bluetooth permission on iOS too
#else
    return true;
#endif
}

bool UtilsApp::getMobileBleLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_location_ble();
#else
    return true;
#endif
}

bool UtilsApp::checkMobileBackgroundLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_location_background();
#else
    return true;
#endif
}

bool UtilsApp::getMobileBackgroundLocationPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_location_background();
#else
    return true;
#endif
}

bool UtilsApp::checkMobileStoragePermissions()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermissions_storage();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobileStoragePermissions()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermissions_storage();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::checkMobileStorageReadPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_storage_read();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobileStorageReadPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_storage_read();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::checkMobileStorageWritePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_storage_write();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobileStorageWritePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_storage_write();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::checkMobileStorageFileSystemPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_storage_filesystem();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobileStorageFileSystemPermission(const QString &packageName)
{
    Q_UNUSED(packageName)

#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_storage_filesystem(packageName);
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::checkMobilePhoneStatePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_phonestate();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobilePhoneStatePermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_phonestate();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

/* ************************************************************************** */

bool UtilsApp::checkMobileCameraPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::checkPermission_camera();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

bool UtilsApp::getMobileCameraPermission()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getPermission_camera();
#elif defined(Q_OS_IOS)
    return false;
#else
    return true;
#endif
}

/* ************************************************************************** */

bool UtilsApp::isMobileGpsEnabled()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::gpsutils_isGpsEnabled();
#elif defined(Q_OS_IOS)
    return false; // TODO
#else
    return false;
#endif
}

void UtilsApp::forceMobileGpsEnabled()
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::gpsutils_forceGpsEnabled();
#endif
}

/* ************************************************************************** */

QString UtilsApp::getMobileDeviceModel()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getDeviceModel();
#else
    return QString();
#endif
}

QString UtilsApp::getMobileDeviceSerial()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getDeviceSerial();
#else
    return QString();
#endif
}

/* ************************************************************************** */

int UtilsApp::getMobileStorageCount()
{
#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();
    return storages.size();
#endif

    return 0;
}

QString UtilsApp::getMobileStorageInternal()
{
    QString internal;

#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();

    if (storages.size() > 0)
        internal = storages.at(0);
#endif

    return internal;
}

QString UtilsApp::getMobileStorageExternal(int index)
{
#if defined(Q_OS_ANDROID)
    QStringList storages = UtilsAndroid::get_storages_by_api();

    if (storages.size() > index)
        return storages.at(1 + index);
#endif

    Q_UNUSED(index)
    return QString();
}

QStringList UtilsApp::getMobileStorageExternals()
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
