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

#ifndef UTILS_OS_H
#define UTILS_OS_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QString>
#include <QStringList>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

class UtilsOS : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    uint32_t m_screensaverId = 0;

    // Singleton
    explicit UtilsOS(QObject *parent = nullptr);

public:
    static UtilsOS *getInstance();
    static UtilsOS *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    // Actions

    /*!
     * \brief Screen saver inhibitor.
     * \param on: keep screen on or off.
     * \param application: the name of the application requesting to disable screensaver.
     * \param explanation: the reason why the application is requesting to disable screensaver.
     */
    Q_INVOKABLE void keepScreenOn(bool on,
                                  const QString &application = QString(),
                                  const QString &explanation = QString());

    //! Haptic feedback styles that can be triggered through hapticFeedback().
    enum HapticFeedback {
        HapticSelection = 0,    //!< A light tick, for a selection moving between values.
        HapticLight,            //!< A light impact (small UI element).
        HapticMedium,           //!< A medium impact.
        HapticHeavy,            //!< A heavy impact (large UI element).
        HapticSuccess,          //!< A "task succeeded" notification feedback.
        HapticWarning,          //!< A "warning" notification feedback.
        HapticError,            //!< An "error / task failed" notification feedback.
    };
    Q_ENUM(HapticFeedback)

    /*!
     * \brief Trigger a haptic feedback.
     * \param type: Default is a "light" feedback.
     * \note: iPads have no haptic engine.
     */
    static Q_INVOKABLE void hapticFeedback(const HapticFeedback type = HapticLight);

    // Mobile permissions related

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
#endif // UTILS_OS_H
