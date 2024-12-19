/*!
 * Copyright (c) 2022 Emeric Grange
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

#include "utils_screen.h"

#include <cmath>

#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <QWindow>
#include <QDebug>

#if defined(Q_OS_ANDROID)
#include "utils_os_android.h"
#elif defined(Q_OS_IOS)
#include "utils_os_ios.h"
//#include <QtGui/qpa/qplatformwindow.h>
#elif defined(Q_OS_MACOS)
#include "utils_os_macos.h"
#elif defined(Q_OS_LINUX)
#include "utils_os_linux.h"
#elif defined(Q_OS_WINDOWS)
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
    if (qApp)
    {
        connect(qApp, &QGuiApplication::primaryScreenChanged, this, &UtilsScreen::getScreenInfos);

        getScreenInfos(qApp->primaryScreen());
    }
    else
    {
        qWarning() << "UtilsScreen::UtilsScreen() QGuiApplication is NULL";
    }
}

UtilsScreen::~UtilsScreen()
{
    //
}

/* ************************************************************************** */

void UtilsScreen::getScreenInfos(const QScreen *scr)
{
    if (scr)
    {
        //qDebug() << "UtilsScreen::getScreenInfos()";

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

        if (m_screenWidth >= m_screenHeight) {
            m_screenDar = m_screenWidth / static_cast<double>(m_screenHeight);
        } else {
            m_screenDar = m_screenHeight / static_cast<double>(m_screenWidth);
            //m_screenDarInverted = true;
        }

        if (m_screenDar > 0.99f && m_screenDar < 1.01f) {
            m_screenDarStr = "1:1";
        } else if (m_screenDar > 1.24f && m_screenDar < 1.26) {
            m_screenDarStr = "5:4";
        } else if (m_screenDar > 1.323f && m_screenDar < 1.343f) {
            m_screenDarStr = "4:3";
        } else if (m_screenDar > 1.49f && m_screenDar < 1.51f) {
            m_screenDarStr = "3:2";
        } else if (m_screenDar > 1.59f && m_screenDar < 1.61f) {
            m_screenDarStr = "16:10";
        } else if (m_screenDar > 1.767f && m_screenDar < 1.787f) {
            m_screenDarStr = "16:9";
        } else if (m_screenDar > 1.99f && m_screenDar < 2.01f) {
            m_screenDarStr = "2:1";
        } else if (m_screenDar > 2.1 && m_screenDar < 2.12f) {
            m_screenDarStr = "19:9";
        } else if (m_screenDar > 2.15f && m_screenDar < 2.17f) {
            m_screenDarStr = "19.5:9";
        } else if (m_screenDar > 2.21f && m_screenDar < 2.23f) {
            m_screenDarStr = "20:9";
        } else if (m_screenDar > 2.33f && m_screenDar < 2.40f) {
            m_screenDarStr = "21:9";
        } else if (m_screenDar > 3.5f && m_screenDar < 2.34f) {
            m_screenDarStr = "32:9";
        }

        Q_EMIT screenChanged();
    }
    else
    {
        qWarning() << "UtilsScreen::getScreenInfos() QScreen is NULL";
    }
}

void UtilsScreen::printScreenInfos()
{
    if (m_scr)
    {
        qDebug() << "UtilsScreen::printScreenInfos()";
        qDebug() << "-" << m_scr->name() << m_scr->model() << m_scr->manufacturer();

        qDebug() << "- screen size (diagonal, inches)   " << m_screenSizeInch;
        qDebug() << "- screen size (physical, mm)       " << m_scr->physicalSize();
        qDebug() << "- screen refresh rate (Hz)         " << m_scr->refreshRate();

        qDebug() << "- screen geometry      " << m_scr->size();
        qDebug() << "- screen geometry (dpi corrected)  " << m_scr->size() * m_scr->devicePixelRatio();

        qDebug() << "- screen dpi (physical)" << m_scr->physicalDotsPerInch();
        qDebug() << "- screen dpi (logical) " << m_scr->logicalDotsPerInch();

        qDebug() << "- screen pixel ratio   " << m_scr->devicePixelRatio();
    }
    else
    {
        qWarning() << "UtilsScreen::printScreenInfos() Unable to get screen infos, NULL QScreen";
    }
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
