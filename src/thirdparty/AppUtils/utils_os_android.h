/*!
 * Copyright (c) 2019 Emeric Grange
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

#ifndef UTILS_OS_ANDROID_H
#define UTILS_OS_ANDROID_H

#include <QtGlobal>

#if defined(Q_OS_ANDROID)
/* ************************************************************************** */

#include <QString>
#include <QStringList>

/*!
 * \brief Android utils
 *
 * Qt5 needs this in the project file:
 * android { QT += androidextras }
 *
 * Qt6 needs this in the project file:
 * android { QT += core-private }
 */
class UtilsAndroid
{
public:
    /*!
     * \brief Get Android SDK / API level
     * \return See https://apilevels.com/
     */
    static int getSdkVersion();

    static bool getPermissions_storage();
    static bool checkPermissions_storage();

    /*!
     * \note DEPRECATED in Android 12
     * \return True if R/W permissions on main storage have been previously or explicitly obtained.
     */
    static bool checkPermission_storage_read();
    static bool getPermission_storage_read();
    static bool checkPermission_storage_write();
    static bool getPermission_storage_write();

    /*!
     * \param packageName: the application package, for instance 'com.application.identifier'.
     * \return True if filesystem access have been previously or explicitly obtained.
     */
    static bool checkPermission_storage_filesystem();
    static bool getPermission_storage_filesystem(const QString &packageName);

    /*!
     * \return True if CAMERA permission has been previously obtained.
     */
    static bool checkPermission_camera();

    /*!
     * \return True if CAMERA permission has been explicitly obtained.
     */
    static bool getPermission_camera();

    /*!
     * \return True if POST_NOTIFICATIONS permission has been previously obtained.
     */
    static bool checkPermission_notification();

    /*!
     * \return True if POST_NOTIFICATIONS permission has been explicitly obtained.
     */
    static bool getPermission_notification();

    /*!
     * \return True if Bluetooth permission has been previously obtained.
     */
    static bool checkPermission_bluetooth();

    /*!
     * \return True if Bluetooth permission has been explicitly obtained.
     */
    static bool getPermission_bluetooth();

    /*!
     * \return True if ACCESS_FINE_LOCATION permission has been previously obtained.
     */
    static bool checkPermission_location();

    /*!
     * \return True if ACCESS_FINE_LOCATION permission has been explicitly obtained.
     */
    static bool getPermission_location();

    /*!
     * \return True if location permission (FINE for Android 10+, COARSE for Android 6+) has been previously obtained.
     */
    static bool checkPermission_location_ble();

    /*!
     * \return True if location permission (FINE for Android 10+, COARSE for Android 6+) has been explicitly obtained.
     */
    static bool getPermission_location_ble();

    /*!
     * \return True if ACCESS_BACKGROUND_LOCATION permission has been previously obtained (for Android 10+).
     */
    static bool checkPermission_location_background();

    /*!
     * \return True if ACCESS_BACKGROUND_LOCATION permission has been explicitly obtained (for Android 10+).
     */
    static bool getPermission_location_background();

    /*!
     * \return True if READ_PHONE_STATE permission has been previously obtained.
     */
    static bool checkPermission_phonestate();

    /*!
     * \return True if READ_PHONE_STATE permission has been explicitly obtained.
     */
    static bool getPermission_phonestate();

    /* ********************************************************************** */

    /*!
     * \return True if device GPS is turned on.
     */
    static bool isGpsEnabled();

    /*!
     * \return True if device GPS is turned on (using QGpsUtils.java).
     */
    static bool gpsutils_isGpsEnabled();

    /*!
     * \return True if device GPS has been turned on turned on (using QGpsUtils.java).
     */
    static bool gpsutils_forceGpsEnabled();

    /*!
     * \brief Open the Android location settings intent (using QGpsUtils.java).
     */
    static void gpsutils_openLocationSettings();

    /* ********************************************************************** */

    /*!
     * \return The path to the app internal storage folder.
     */
    static QString getAppInternalStorage();

    /*!
     * \return The path to the app external storage folder.
     */
    static QString getAppExternalStorage();

    /*!
     * \note DEPRECATED won't work with Android 12+
     * \return The path to the external storage.
     *
     * Search for storage devices using native API, using:
     * - https://developer.android.com/reference/android/content/Context.html#getExternalFilesDir(java.lang.String)
     */
    static QStringList get_storages_by_api();

    /*!
     * \note DEPRECATED won't work with Android 12+
     * \return The path to the external storage.
     *
     * Search for storage devices using native API, using:
     * - https://developer.android.com/reference/android/os/Environment#getExternalStorageDirectory()
     *
     * It might get complicated:
     * - https://source.android.com/devices/storage/
     */
    static QString get_external_storage();

    /* ********************************************************************** */

    /*!
     * \return The device manufacturer + model.
     *
     * Documentation:
     * - https://developer.android.com/reference/android/os/Build.html
     */
    static QString getDeviceModel();

    /*!
     * \return The device serial number.
     *
     * Need READ_PHONE_STATE permission.
     * Only work before Android 10 (API < 29).
     *
     * Documentation:
     * - https://developer.android.com/reference/android/os/Build#getSerial()
     */
    static QString getDeviceSerial();

    /* ********************************************************************** */

    /*!
     * \param on: screen on or off.
     */
    static void screenKeepOn(bool on);

    /*!
     * \param orientation: 0 is for landscape, 1 for portrait.
     *
     * Lock screen orientation, using:
     * - https://developer.android.com/reference/android/app/Activity.html#setRequestedOrientation(int)
     *
     * You can achieve similar functionality through application manifest:
     * - https://developer.android.com/guide/topics/manifest/activity-element.html#screen
     */
    static void screenLockOrientation(int orientation);

    /*!
     * \param orientation: see ScreenOrientation enum.
     * \param autoRotate: false to disable auto-rotation completely, true to let some degree of auto-rotation.
     */
    static void screenLockOrientation(int orientation, bool autoRotate);

    /* ********************************************************************** */

    /*!
     * \param milliseconds: vibration duration.
     *
     * Need VIBRATE permission.
     *
     * - 25 is a small 'keyboard like' vibration
     * - 100 is a regular 'notification' vibration
     */
    static void vibrate(int milliseconds);

    /* ********************************************************************** */

    /*!
     * \brief Open the Android application info intent for the given package name.
     * \param packageName: the application package, for instance 'com.application.identifier'.
     */
    static void openApplicationInfo(const QString &packageName);

    /*!
     * \brief Open the Android "manage all files" intent for the given package name.
     * \param packageName: the application package, for instance 'com.application.identifier'.
     *
     * Documentation:
     * - https://developer.android.com/training/data-storage/manage-all-files
     */
    static void openStorageSettings(const QString &packageName);

    /*!
     * \brief Open the Android location settings intent.
     */
    static void openLocationSettings();
};

/* ************************************************************************** */
#endif // Q_OS_ANDROID
#endif // UTILS_OS_ANDROID_H
