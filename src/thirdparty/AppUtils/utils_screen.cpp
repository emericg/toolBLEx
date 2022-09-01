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
 * \date      2019
 */

#include "utils_screen.h"

#include <cmath>

#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <QWindow>
#include <QDebug>

#if defined(Q_OS_ANDROID)
#include "utils_os_android.h"
#endif
#if defined(Q_OS_IOS)
#include "utils_os_ios.h"
#include <QtGui/qpa/qplatformwindow.h>
#endif
#if defined(Q_OS_MACOS)
#include "utils_os_macos.h"
#endif
#if defined(Q_OS_LINUX)
#include "utils_os_linux.h"
#endif
#if defined(Q_OS_WINDOWS)
#include "utils_os_windows.h"
#endif

/* ************************************************************************** */

UtilsScreen *UtilsScreen::instance = nullptr;

UtilsScreen *UtilsScreen::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsScreen();
    }

    return instance;
}

UtilsScreen::UtilsScreen()
{
    setAppWindow(qApp);
}

UtilsScreen::~UtilsScreen()
{
    //
}

/* ************************************************************************** */

void UtilsScreen::setAppWindow(QGuiApplication *app)
{
    if (!app) return;

    m_app = app;
    connect(m_app, &QGuiApplication::primaryScreenChanged, this, &UtilsScreen::getScreenInfos);

    getScreenInfos(m_app->primaryScreen());
}

/* ************************************************************************** */

void UtilsScreen::getScreenInfos(QScreen *scr)
{
    //qDebug() << "UtilsScreen::getScreenInfos()";

    if (scr)
    {
        m_scr = scr;

        m_screenWidth = scr->size().width();
        m_screenHeight = scr->size().height();
        m_screenDepth = scr->depth();
        m_screenRefreshRate = scr->refreshRate();

        m_screenDpi = scr->physicalDotsPerInch();
        m_screenPar = scr->devicePixelRatio();
        m_screenSizeInch = std::sqrt(std::pow(scr->physicalSize().width(), 2.0) +
                                     std::pow(scr->physicalSize().height(), 2.0)) / (2.54 * 10.0);

        // TODO // On Android, physicalSize().height seems to ignore the buttons and/or status bar

        Q_EMIT screenChanged();
    }
    else
    {
        qWarning() << "UtilsScreen::getScreenInfos() Unable to get screen infos, NULL QScreen";
    }
}

void UtilsScreen::printScreenInfos()
{
    qDebug() << "UtilsScreen::printScreenInfos()";

    if (m_scr)
    {
        qDebug() << "- screen geometry    " << m_scr->size();
        qDebug() << "- screen geometry (dpi corrected)  " << m_scr->size() * m_scr->devicePixelRatio();
        qDebug() << "- screen dpi         " << m_scr->physicalDotsPerInch();
        qDebug() << "- screen pixel ratio " << m_scr->devicePixelRatio();

        qDebug() << "- screen size (physical, mm)       " << m_scr->physicalSize();
        qDebug() << "- screen size (diagonal in inches) " << m_screenSizeInch;
    }
    else
    {
        qWarning() << "UtilsScreen::printScreenInfos() Unable to get screen infos, NULL QScreen";
    }
}

/* ************************************************************************** */

QVariantMap UtilsScreen::getSafeAreaMargins(QQuickWindow *window)
{
    QVariantMap map;

    if (window)
    {
#if defined(Q_OS_IOS)
        QPlatformWindow *platformWindow = static_cast<QPlatformWindow *>(window->handle());
        if (platformWindow)
        {
            QMargins margins = platformWindow->safeAreaMargins();
            map["top"] = margins.top();
            map["right"] = margins.right();
            map["bottom"] = margins.bottom();
            map["left"] = margins.left();
            map["total"] = margins.top() + margins.right() + margins.bottom() + margins.left();
        }
        else
        {
            qDebug() << "getSafeAreaMargins() No QPlatformWindow available";
        }
#endif // defined(Q_OS_IOS)
    }
    else
    {
        qDebug() << "getSafeAreaMargins() No QQuickWindow available";
    }

    return map;
}

/* ************************************************************************** */

void UtilsScreen::keepScreenOn(bool on, const QString &application, const QString &explanation)
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

void UtilsScreen::lockScreenOrientation(int orientation)
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::screenLockOrientation(orientation);
#elif defined(Q_OS_IOS)
    UtilsIOS::screenLockOrientation(orientation);
#else
    Q_UNUSED(orientation)
#endif
}

void UtilsScreen::lockScreenOrientation(UtilsScreen::ScreenOrientation orientation, bool autoRotate)
{
#if defined(Q_OS_ANDROID)
    UtilsAndroid::screenLockOrientation(static_cast<int>(orientation), autoRotate);
#elif defined(Q_OS_IOS)
    UtilsIOS::screenLockOrientation(static_cast<int>(orientation), autoRotate);
#else
    Q_UNUSED(orientation)
    Q_UNUSED(autoRotate)
#endif
}

/* ************************************************************************** */
