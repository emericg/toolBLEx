/*!
 * Copyright (c) 2025 Emeric Grange
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

#ifndef PERMISSION_MANAGER_H
#define PERMISSION_MANAGER_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>

#if !QT_CONFIG(permissions)
#error "QtPermission is not available. Qt 6.6 is required!"
#endif

#include <QPermission>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The PermissionManager class
 *
 * REQUIRES Qt 6.6+
 * https://doc.qt.io/qt-6/permissions.html
 *
 * - https://doc.qt.io/qt-6/qbluetoothpermission.html
 * - https://doc.qt.io/qt-6/qcalendarpermission.html
 * - https://doc.qt.io/qt-6/qcamerapermission.html
 * - https://doc.qt.io/qt-6/qcontactpermission.html
 * - https://doc.qt.io/qt-6/qlocationpermission.html
 * - https://doc.qt.io/qt-6/qmicrophonepermission.html
 */
class PermissionManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool bluetoothPermission READ hasBluetoothPermission NOTIFY bluetoothPermissionChanged)
    Q_PROPERTY(bool calendarPermission READ hasCalendarPermission NOTIFY calendarPermissionChanged)
    Q_PROPERTY(bool cameraPermission READ hasCameraPermission NOTIFY cameraPermissionChanged)
    Q_PROPERTY(bool contactsPermission READ hasContactsPermission NOTIFY contactsPermissionChanged)
    Q_PROPERTY(bool locationPermission READ hasLocationPermission NOTIFY locationPermissionChanged)
    Q_PROPERTY(bool microphonePermission READ hasMicrophonePermission NOTIFY microphonePermissionChanged)

    explicit PermissionManager(QObject *parent = nullptr);

    static const int s_waittimeout = 10000; // in ms
    static const int s_waittimeout_interval = 33; // in ms

    bool m_bluetoothPermission = false;
    bool m_calendarPermission = false;
    bool m_cameraPermission = false;
    bool m_contactsPermission = false;
    bool m_locationPermission = false;
    bool m_microphonePermission = false;

    void setBluetoothPermission(bool perm);
    void setCalendarPermission(bool perm);
    void setCameraPermission(bool perm);
    void setContactsPermission(bool perm);
    void setLocationPermission(bool perm);
    void setMicrophonePermission(bool perm);

    void requestBluetoothPermission_results(const QPermission &permission);
    void requestCameraPermission_results(const QPermission &permission);
    void requestLocationPermission_results(const QPermission &permission);

Q_SIGNALS:
    void bluetoothPermissionChanged();
    void calendarPermissionChanged();
    void cameraPermissionChanged();
    void contactsPermissionChanged();
    void locationPermissionChanged();
    void microphonePermissionChanged();

public:
    static PermissionManager *getInstance();
    static PermissionManager *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    bool hasBluetoothPermission() const { return m_bluetoothPermission; }
    bool hasCalendarPermission() const { return m_calendarPermission; }
    bool hasCameraPermission() const { return m_cameraPermission; }
    bool hasContactsPermission() const { return m_contactsPermission; }
    bool hasLocationPermission() const { return m_locationPermission; }
    bool hasMicrophonePermission() const { return m_microphonePermission; }

    Q_INVOKABLE bool requestBluetoothPermission();
    Q_INVOKABLE bool checkBluetoothPermission();
    Q_INVOKABLE bool waitBluetoothPermission();

    Q_INVOKABLE bool requestCameraPermission();
    Q_INVOKABLE bool checkCameraPermission();
    Q_INVOKABLE bool waitCameraPermission();

    Q_INVOKABLE bool requestLocationPermission();
    Q_INVOKABLE bool checkLocationPermission();
    Q_INVOKABLE bool waitLocationPermission();
};

/* ************************************************************************** */
#endif // PERMISSION_MANAGER_H
