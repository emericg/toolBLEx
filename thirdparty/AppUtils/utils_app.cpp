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
#if defined(UTILS_NOTIFICATIONS_ENABLED)
#include "utils_os_ios_notif.h"
#endif
#endif

#include <QDir>
#include <QSize>
#include <QColor>

#include <QCoreApplication>
#include <QDesktopServices>
#include <QStandardPaths>
#include <QLibraryInfo>
#include <QSysInfo>

#include <QGuiApplication>
#include <QQuickWindow>
#include <QStyleHints>
#include <QQmlEngine>
#include <QPalette>

#if defined(UTILS_QT_RHI)
#include <rhi/qrhi.h>
#endif

/* ************************************************************************** */
/* ************************************************************************** */

UtilsApp *UtilsApp::getInstance()
{
    static UtilsApp *instance = new UtilsApp(QCoreApplication::instance());
    return instance;
}

UtilsApp *UtilsApp::create(QQmlEngine *, QJSEngine *)
{
    UtilsApp *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

UtilsApp::UtilsApp(QObject *parent) : QObject(parent)
{
    // Set default application path
    m_appPath = QCoreApplication::applicationDirPath();

    // Make sure the path is terminated with a separator?
    //if (!m_appPath.endsWith('/')) m_appPath += '/';
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
    return QStringLiteral("DEBUG");
#endif

    return QString();
}

QString UtilsApp::appBuildModeFull()
{
#if defined(QT_NO_DEBUG) || defined(NDEBUG)
    return QStringLiteral("RELEASE");
#endif

    return QStringLiteral("DEBUG");
}

bool UtilsApp::isDebugBuild()
{
#if defined(QT_NO_DEBUG) || defined(NDEBUG)
    return false;
#endif

    return true;
}

/* ************************************************************************** */
/* ************************************************************************** */

QString UtilsApp::qtVersion()
{
    return QString(qVersion());
}

QString UtilsApp::qtBuildMode()
{
    if (QLibraryInfo::isDebugBuild())
    {
        return QStringLiteral("DEBUG");
    }

    return QStringLiteral("RELEASE");
}

QString UtilsApp::qtArchitecture()
{
    return QSysInfo::buildCpuArchitecture();
}

bool UtilsApp::qtIsDebug()
{
    return QLibraryInfo::isDebugBuild();
}

bool UtilsApp::qtIsRelease()
{
    return !QLibraryInfo::isDebugBuild();
}

bool UtilsApp::qtIsStatic()
{
    return !QLibraryInfo::isSharedBuild();
}

bool UtilsApp::qtIsShared()
{
    return QLibraryInfo::isSharedBuild();
}

QString UtilsApp::qtRhiBackend() const
{
#if defined(UTILS_QT_RHI)
    if (m_quickwindow && m_quickwindow->rhi())
    {
        return m_quickwindow->rhi()->backendName();
    }
#endif

    return QString();
}

void UtilsApp::setQuickWindow(QQuickWindow *window)
{
    if (window)
    {
        m_quickwindow = window;
    }
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

bool UtilsApp::isOsThemeDark()
{
    const QStyleHints *styleHints = QGuiApplication::styleHints();
    return (styleHints && styleHints->colorScheme() == Qt::ColorScheme::Dark);
}

/* ************************************************************************** */
/* ************************************************************************** */

int UtilsApp::getAndroidSdkVersion()
{
#if defined(Q_OS_ANDROID)
    return UtilsAndroid::getSdkVersion();
#endif

    return 0;
}

/* ************************************************************************** */

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

void UtilsApp::openAndroidAlarms()
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::openAlarmClock();
#endif
}

/* ************************************************************************** */
/* ************************************************************************** */
