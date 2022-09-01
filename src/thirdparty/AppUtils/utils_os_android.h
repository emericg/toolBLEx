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
     * \brief getSdkVersion
     * \return
     */
    static int getSdkVersion();

    /*!
     * \note DEPRECATED in Android 12
     * \return True if R/W permissions on main storage have been previously obtained.
     */
    static bool checkPermissions_storage();
    static bool checkPermission_storage_read();
    static bool checkPermission_storage_write();

    /*!
     * \note DEPRECATED in Android 12
     * \return True if R/W permissions on main storage have been explicitly obtained.
     */
    static bool getPermissions_storage();
    static bool getPermission_storage_read();
    static bool getPermission_storage_write();

    /*!
     * \return True if CAMERA permission has been previously obtained.
     */
    static bool checkPermission_camera();

    /*!
     * \return True if CAMERA permission has been explicitly obtained.
     */
    static bool getPermission_camera();

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

    /*!
     * \return True if device GPS is turned on.
     */
    static bool isGpsEnabled();

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
     * - https://developer.android.com/reference/android/os/Build.html
     */
    static QString getDeviceModel();

    /*!
     * \return The device serial number.
     *
     * Need READ_PHONE_STATE permission.
     * Only work before Android 10 (API < 29).
     *
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
     * \param packageName: the application package, for instance 'com.application.identifier'.
     *
     * Open the Android application info intent for the given package name.
     */
    static void openApplicationInfo(const QString &packageName);
};

/* ************************************************************************** */
#endif // Q_OS_ANDROID
#endif // UTILS_OS_ANDROID_H
