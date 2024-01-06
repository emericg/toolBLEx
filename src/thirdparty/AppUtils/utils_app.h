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

#ifndef UTILS_APP_H
#define UTILS_APP_H
/* ************************************************************************** */

#include <QObject>
#include <QUrl>
#include <QColor>
#include <QString>
#include <QStringList>

/* ************************************************************************** */

class UtilsApp : public QObject
{
    Q_OBJECT

    QString m_appPath;

    // Singleton
    static UtilsApp *instance;
    UtilsApp();
    ~UtilsApp();

public:
    static UtilsApp *getInstance();

    // app info

    static Q_INVOKABLE QString appName();
    static Q_INVOKABLE QString appVersion();

    static Q_INVOKABLE QString appBuildDate();
    static Q_INVOKABLE QString appBuildDateTime();
    static Q_INVOKABLE QString appBuildMode();
    static Q_INVOKABLE QString appBuildModeFull();
    static Q_INVOKABLE bool isDebugBuild();

    static Q_INVOKABLE QString qtVersion();

    // tools
    QString getAppPath() const { return m_appPath; }
    void setAppPath(const QString &value);

    static Q_INVOKABLE void appExit();
    static Q_INVOKABLE void openWith(const QString &path);

    static Q_INVOKABLE QUrl getStandardPath_url(const QString &type);
    static Q_INVOKABLE QString getStandardPath_string(const QString &type);

    static Q_INVOKABLE bool isColorLight(const int color);
    static Q_INVOKABLE bool isQColorLight(const QColor &color);

    // mobile related

    static Q_INVOKABLE int getAndroidSdkVersion();

    static Q_INVOKABLE void openAndroidAppInfo(const QString &packageName);
    static Q_INVOKABLE void openAndroidStorageSettings(const QString &packageName);
    static Q_INVOKABLE void openAndroidLocationSettings();

    static Q_INVOKABLE void vibrate(int ms);

    static Q_INVOKABLE bool checkMobileStoragePermissions();
    static Q_INVOKABLE bool getMobileStoragePermissions();
    static Q_INVOKABLE bool checkMobileStorageReadPermission();
    static Q_INVOKABLE bool getMobileStorageReadPermission();
    static Q_INVOKABLE bool checkMobileStorageWritePermission();
    static Q_INVOKABLE bool getMobileStorageWritePermission();

    static Q_INVOKABLE bool checkMobileStorageFileSystemPermission();
    static Q_INVOKABLE bool getMobileStorageFileSystemPermission(const QString &packageName);

    static Q_INVOKABLE bool checkMobileBluetoothPermission();
    static Q_INVOKABLE bool getMobileBluetoothPermission();

    static Q_INVOKABLE bool checkMobileLocationPermission();
    static Q_INVOKABLE bool getMobileLocationPermission();

    static Q_INVOKABLE bool checkMobileBleLocationPermission();
    static Q_INVOKABLE bool getMobileBleLocationPermission();

    static Q_INVOKABLE bool checkMobileBackgroundLocationPermission();
    static Q_INVOKABLE bool getMobileBackgroundLocationPermission();

    static Q_INVOKABLE bool checkMobilePhoneStatePermission();
    static Q_INVOKABLE bool getMobilePhoneStatePermission();

    static Q_INVOKABLE bool checkMobileCameraPermission();
    static Q_INVOKABLE bool getMobileCameraPermission();

    static Q_INVOKABLE bool checkMobileNotificationPermission();
    static Q_INVOKABLE bool getMobileNotificationPermission();

    static Q_INVOKABLE bool isMobileGpsEnabled();
    static Q_INVOKABLE void forceMobileGpsEnabled();

    static Q_INVOKABLE QString getMobileDeviceModel();
    static Q_INVOKABLE QString getMobileDeviceSerial();

    static Q_INVOKABLE int getMobileStorageCount();
    static Q_INVOKABLE QString getMobileStorageInternal();
    static Q_INVOKABLE QString getMobileStorageExternal(int index = 0);
    static Q_INVOKABLE QStringList getMobileStorageExternals();
};

/* ************************************************************************** */
#endif // UTILS_APP_H
