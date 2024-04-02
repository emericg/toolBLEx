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

#ifndef UTILS_WIFI_H
#define UTILS_WIFI_H
/* ************************************************************************** */

#include <QObject>
#include <QString>

/* ************************************************************************** */

/*!
 * \brief The UtilsWiFi class
 *
 * Android need the "ACCESS_WIFI_STATE" and "ACCESS_FINE_LOCATION" manifest permission.
 * iOS need the "NSLocationWhenInUseUsageDescription" plist key and "Wifi Info" capability.
 */
class UtilsWiFi: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString currentSSID READ getCurrentSSID NOTIFY wifiChanged)
    Q_PROPERTY(bool permissionOS READ hasPermissionOS NOTIFY permissionsChanged)

    QString m_currentSSID;
    QString getCurrentSSID() { return m_currentSSID; }

    bool m_permOS = false;
    bool hasPermissionOS() const { return m_permOS; }

    void refreshWiFi_internal();

    // Singleton
    static UtilsWiFi *instance;
    UtilsWiFi();
    ~UtilsWiFi();

Q_SIGNALS:
    void wifiChanged();
    void permissionsChanged();

private slots:
    void requestLocationPermissions_results();

public:
    static UtilsWiFi *getInstance();

    Q_INVOKABLE bool checkLocationPermissions();
    Q_INVOKABLE void requestLocationPermissions();

    Q_INVOKABLE void refreshWiFi();
};

/* ************************************************************************** */
#endif // UTILS_WIFI_H
