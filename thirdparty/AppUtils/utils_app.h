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

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QUrl>
#include <QColor>
#include <QString>
#include <QStringList>

class QQuickWindow;
class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

class UtilsApp : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QString m_appPath;

    QQuickWindow *m_quickwindow = nullptr;

    // Singleton
    explicit UtilsApp(QObject *parent = nullptr);

public:
    static UtilsApp *getInstance();
    static UtilsApp *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    // App info

    static Q_INVOKABLE QString appName();
    static Q_INVOKABLE QString appVersion();

    static Q_INVOKABLE QString appBuildDate();
    static Q_INVOKABLE QString appBuildDateTime();
    static Q_INVOKABLE QString appBuildMode();
    static Q_INVOKABLE QString appBuildModeFull();
    static Q_INVOKABLE bool isDebugBuild();

    // Qt info

    static Q_INVOKABLE QString qtVersion();
    static Q_INVOKABLE QString qtBuildMode();
    static Q_INVOKABLE QString qtArchitecture();
    static Q_INVOKABLE bool qtIsDebug();
    static Q_INVOKABLE bool qtIsRelease();
    static Q_INVOKABLE bool qtIsShared();
    static Q_INVOKABLE bool qtIsStatic();

    Q_INVOKABLE QString qtRhiBackend() const;
    void setQuickWindow(QQuickWindow *window);

    // Helpers

    Q_INVOKABLE QString getAppPath() const { return m_appPath; }
    void setAppPath(const QString &value);

    static Q_INVOKABLE void appExit();
    static Q_INVOKABLE void openWith(const QString &path);

    static Q_INVOKABLE QUrl getStandardPath_url(const QString &type);
    static Q_INVOKABLE QString getStandardPath_string(const QString &type);

    static Q_INVOKABLE bool isColorLight(const int color);
    static Q_INVOKABLE bool isQColorLight(const QColor &color);

    static Q_INVOKABLE bool isOsThemeDark();

    // Android helpers

    static Q_INVOKABLE int getAndroidSdkVersion();
    static Q_INVOKABLE void openAndroidAppInfo(const QString &packageName);
    static Q_INVOKABLE void openAndroidStorageSettings(const QString &packageName);
    static Q_INVOKABLE void openAndroidLocationSettings();
    static Q_INVOKABLE void openAndroidAlarms();
};

/* ************************************************************************** */
#endif // UTILS_APP_H
