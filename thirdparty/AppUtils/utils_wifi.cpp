/*!
 * Copyright (c) 2024 Emeric Grange
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

#include "utils_wifi.h"

#if defined(Q_OS_ANDROID)
#include "utils_os_android.h"
#elif defined(Q_OS_IOS) && defined(UTILS_WIFI_ENABLED)
#include "utils_os_ios_wifi.h"
#endif

#if QT_CONFIG(permissions)
#include <QCoreApplication>
#include <QPermission>
#endif

#include <QDebug>

/* ************************************************************************** */

UtilsWiFi *UtilsWiFi::instance = nullptr;

UtilsWiFi *UtilsWiFi::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsWiFi();
    }

    return instance;
}

UtilsWiFi::UtilsWiFi()
{
    //
}

UtilsWiFi::~UtilsWiFi()
{
    //
}

/* ************************************************************************** */

bool UtilsWiFi::checkLocationPermissions()
{
    //qDebug() << "UtilsWiFi::checkLocationPermissions()";
    bool permOS_was = m_permOS;

#if QT_CONFIG(permissions)
    m_permOS = (qApp->checkPermission(QLocationPermission{}) == Qt::PermissionStatus::Granted);

    if (permOS_was != m_permOS)
    {
        Q_EMIT permissionsChanged();
    }
#endif

    return m_permOS;
}

void UtilsWiFi::requestLocationPermissions()
{
    //qDebug() << "UtilsWiFi::requestLocationPermissions()";

#if QT_CONFIG(permissions)
    qApp->requestPermission(QLocationPermission{},
                            this, &UtilsWiFi::requestLocationPermissions_results);
#endif
}

void UtilsWiFi::requestLocationPermissions_results()
{
    // evaluate the results
    if (checkLocationPermissions())
    {
        refreshWiFi_internal();
    }
    else
    {
        // try again?
        //requestLocationPermissions();
    }
}

/* ************************************************************************** */

void UtilsWiFi::refreshWiFi()
{
    if (checkLocationPermissions())
    {
        refreshWiFi_internal();
    }
    else
    {
        requestLocationPermissions();
    }
}

void UtilsWiFi::refreshWiFi_internal()
{
#if defined(Q_OS_ANDROID)
    m_currentSSID = UtilsAndroid::getWifiSSID();
    Q_EMIT wifiChanged();
#elif defined(Q_OS_IOS) && defined(UTILS_WIFI_ENABLED)
    m_currentSSID = UtilsIOSWiFi::getWifiSSID();
    Q_EMIT wifiChanged();
#else
    m_currentSSID = "";
#endif
}

/* ************************************************************************** */
