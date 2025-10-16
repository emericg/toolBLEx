/*!
 * Copyright (c) 2020 Emeric Grange
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

#include "utils_os_android.h"

#if defined(Q_OS_ANDROID)

#include <QtCore/private/qandroidextras_p.h>
#include <QCoreApplication>
#include <QJniEnvironment>
#include <QJniObject>
#include <QDebug>

/* ************************************************************************** */

int UtilsAndroid::getSdkVersion()
{
    return QNativeInterface::QAndroidApplication::sdkVersion();
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermissions_storage()
{
    QFuture<QtAndroidPrivate::PermissionResult> r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    QFuture<QtAndroidPrivate::PermissionResult> w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");

    //r.waitForFinished();
    //w.waitForFinished();

    return (r.result() == QtAndroidPrivate::PermissionResult::Authorized && w.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::checkPermission_storage_read()
{
    QFuture<QtAndroidPrivate::PermissionResult> r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    //r.waitForFinished();

    return (r.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::checkPermission_storage_write()
{
    QFuture<QtAndroidPrivate::PermissionResult> w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    //w.waitForFinished();

    return (w.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermissions_storage()
{
    return (UtilsAndroid::getPermission_storage_read() && UtilsAndroid::getPermission_storage_write());
}

bool UtilsAndroid::getPermission_storage_read()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    //r.waitForFinished();

    if (r.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.READ_EXTERNAL_STORAGE");

        r = QtAndroidPrivate::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
        //r.waitForFinished();

        if (r.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "STORAGE READ PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::getPermission_storage_write()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    //w.waitForFinished();

    if (w.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.WRITE_EXTERNAL_STORAGE");

        w = QtAndroidPrivate::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        //w.waitForFinished();

        if (w.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "STORAGE WRITE PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_storage_filesystem()
{
    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
    {
        return QJniObject::callStaticMethod<jboolean>("android/os/Environment", "isExternalStorageManager");
    }

    return false;
}

bool UtilsAndroid::getPermission_storage_filesystem(const QString &packageName)
{
    //qDebug() << "> getPermission_storage_filesystem(" << packageName << ")";

    bool status = false;

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
    {
        if (!checkPermission_storage_filesystem())
        {
            openStorageSettings(packageName);
        }

        status = checkPermission_storage_filesystem();
    }
    else
    {
        qWarning() << "ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION is not available";
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_camera()
{
    QFuture<QtAndroidPrivate::PermissionResult> cam = QtAndroidPrivate::checkPermission("android.permission.CAMERA");
    //cam.waitForFinished();

    return (cam.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_camera()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> cam = QtAndroidPrivate::checkPermission("android.permission.CAMERA");
    //cam.waitForFinished();

    if (cam.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.CAMERA");
        cam = QtAndroidPrivate::checkPermission("android.permission.CAMERA");
        //cam.waitForFinished();

        if (cam.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "CAMERA PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_notification()
{
    QFuture<QtAndroidPrivate::PermissionResult> notif = QtAndroidPrivate::checkPermission("android.permission.POST_NOTIFICATIONS");
    //cam.waitForFinished();

    return (notif.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_notification()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> notif = QtAndroidPrivate::checkPermission("android.permission.POST_NOTIFICATIONS");
    //notif.waitForFinished();

    if (notif.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.POST_NOTIFICATIONS");
        notif = QtAndroidPrivate::checkPermission("android.permission.POST_NOTIFICATIONS");
        //notif.waitForFinished();

        if (notif.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "POST_NOTIFICATIONS PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_bluetooth()
{
    bool status = false;

    // (up to) Android 11 / SDK 30
    // BLUETOOTH
    // BLUETOOTH_ADMIN

    if (getSdkVersion() <= 30)
    {
        QFuture<QtAndroidPrivate::PermissionResult> ble = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH");
        //ble.waitForFinished();

        QFuture<QtAndroidPrivate::PermissionResult> ble_admin = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH_ADMIN");
        //ble_admin.waitForFinished();

        status = (ble.result() == QtAndroidPrivate::PermissionResult::Authorized) &&
                 (ble_admin.result() == QtAndroidPrivate::PermissionResult::Authorized);
    }

    // (from) Android 12+ / SDK 31
    // BLUETOOTH_SCAN
    // BLUETOOTH_CONNECT

    if (getSdkVersion() >= 31)
    {
        QFuture<QtAndroidPrivate::PermissionResult> ble_scan = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH_SCAN");
        //ble_scan.waitForFinished();

        QFuture<QtAndroidPrivate::PermissionResult> ble_connect = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH_CONNECT");
        //ble_connect.waitForFinished();

        status = (ble_scan.result() == QtAndroidPrivate::PermissionResult::Authorized) &&
                 (ble_connect.result() == QtAndroidPrivate::PermissionResult::Authorized);
    }

    return status;
}

bool UtilsAndroid::getPermission_bluetooth()
{
    if (getSdkVersion() <= 30)
    {
        QFuture<QtAndroidPrivate::PermissionResult> ble = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH");
        if (ble.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            QtAndroidPrivate::requestPermission("android.permission.BLUETOOTH");
        }
        QFuture<QtAndroidPrivate::PermissionResult> ble_admin = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH_ADMIN");
        if (ble_admin.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            QtAndroidPrivate::requestPermission("android.permission.BLUETOOTH_ADMIN");
        }
    }

    if (getSdkVersion() >= 31)
    {
        QFuture<QtAndroidPrivate::PermissionResult> ble_scan = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH_SCAN");
        if (ble_scan.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            QtAndroidPrivate::requestPermission("android.permission.BLUETOOTH_SCAN");
        }
        QFuture<QtAndroidPrivate::PermissionResult> ble_connect = QtAndroidPrivate::checkPermission("android.permission.BLUETOOTH_CONNECT");
        if (ble_connect.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            QtAndroidPrivate::requestPermission("android.permission.BLUETOOTH_CONNECT");
        }
    }

    return checkPermission_bluetooth();
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_location()
{
    QFuture<QtAndroidPrivate::PermissionResult> loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    //loc.waitForFinished();

    return (loc.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_location()
{
    bool status = true;

    QFuture<QtAndroidPrivate::PermissionResult> loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    //loc.waitForFinished();

    if (loc.result() == QtAndroidPrivate::PermissionResult::Denied)
    {
        QtAndroidPrivate::requestPermission("android.permission.ACCESS_FINE_LOCATION");
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
        //loc.waitForFinished();

        if (loc.result() == QtAndroidPrivate::PermissionResult::Denied)
        {
            qWarning() << "FINE LOCATION PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::checkPermission_location_ble()
{
    QFuture<QtAndroidPrivate::PermissionResult> loc;

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    else
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_COARSE_LOCATION");

    //loc.waitForFinished();

    return (loc.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_location_ble()
{
    bool status = true;

    if (!UtilsAndroid::checkPermission_location_ble())
    {
        QFuture<QtAndroidPrivate::PermissionResult> res;

        if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
            res = QtAndroidPrivate::requestPermission("android.permission.ACCESS_FINE_LOCATION");
        else
            res = QtAndroidPrivate::requestPermission("android.permission.ACCESS_COARSE_LOCATION");

        //res.waitForFinished();

        if (!UtilsAndroid::checkPermission_location_ble())
        {
            qWarning() << "FINE/COARSE LOCATION PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::checkPermission_location_background()
{
    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
    {
        QFuture<QtAndroidPrivate::PermissionResult> loc;
        loc = QtAndroidPrivate::checkPermission("android.permission.ACCESS_BACKGROUND_LOCATION");
        //loc.waitForFinished();

        return (loc.result() == QtAndroidPrivate::PermissionResult::Authorized);
    }

    return true;
}

bool UtilsAndroid::getPermission_location_background()
{
    bool status = true;

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
    {
        if (!UtilsAndroid::checkPermission_location_background())
        {
            QFuture<QtAndroidPrivate::PermissionResult> res;
            res = QtAndroidPrivate::requestPermission("android.permission.ACCESS_BACKGROUND_LOCATION");
            //res.waitForFinished();

            if (!UtilsAndroid::checkPermission_location_background())
            {
                qWarning() << "ACCESS_BACKGROUND_LOCATION PERMISSION DENIED";
                status = false;
            }
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_phonestate()
{
    QFuture<QtAndroidPrivate::PermissionResult> ps;
    ps = QtAndroidPrivate::checkPermission("android.permission.READ_PHONE_STATE");
    //ps.waitForFinished();

    return (ps.result() == QtAndroidPrivate::PermissionResult::Authorized);
}

bool UtilsAndroid::getPermission_phonestate()
{
    bool status = true;

    if (!checkPermission_phonestate())
    {
        QFuture<QtAndroidPrivate::PermissionResult> req;
        req = QtAndroidPrivate::requestPermission("android.permission.READ_PHONE_STATE");
        //req.waitForFinished();

        if (!checkPermission_phonestate())
        {
            qWarning() << "READ_PHONE_STATE PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::isGpsEnabled()
{
    bool status = false;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject locationString = QJniObject::fromString("location");
        QJniObject locationService = activity.callObjectMethod("getSystemService",
                                                               "(Ljava/lang/String;)Ljava/lang/Object;",
                                                               locationString.object<jstring>());
        if (locationService.callMethod<jboolean>("isLocationEnabled", "()Z"))
        {
            status = true;
        }
    }

    return status;
}

bool UtilsAndroid::gpsutils_isGpsEnabled()
{
    bool status = false;

    jboolean verified = QJniObject::callStaticMethod<jboolean>(
        "io/emeric/utils/QGpsUtils",
        "checkGpsEnabled",
        "(Landroid/content/Context;)Z",
        QNativeInterface::QAndroidApplication::context());

    if (verified)
    {
        status = true;
    }

    return status;
}

bool UtilsAndroid::gpsutils_forceGpsEnabled()
{
    bool status = false;

    jboolean verified = QJniObject::callStaticMethod<jboolean>(
        "io/emeric/utils/QGpsUtils",
        "forceGpsEnabled",
        "(Landroid/content/Context;)Z",
        QNativeInterface::QAndroidApplication::context());

    if (verified)
    {
        status = true;
    }

    return status;
}

void UtilsAndroid::gpsutils_openLocationSettings()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject intent = QJniObject::callStaticObjectMethod(
            "io/emeric/utils/QGpsUtils",
            "openLocationSettings",
            "()Landroid/content/Intent;",
            activity.object<jobject>());

        QtAndroidPrivate::startActivity(intent, 0);
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

QString UtilsAndroid::getAppInternalStorage()
{
    return QString();
}

QString UtilsAndroid::getAppExternalStorage()
{
    QString storage;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject dir = QJniObject::fromString(QStringLiteral(""));
        QJniObject path = activity.callObjectMethod("getExternalFilesDir",
                                                    "(Ljava/lang/String;)Ljava/io/File;",
                                                    dir.object<jobject>());
        storage = path.toString();
    }

    return storage;
}

QStringList UtilsAndroid::get_storages_by_api() // DEPRECATED
{
    QStringList storages;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject dirs = activity.callObjectMethod("getExternalFilesDirs",
                                                    "(Ljava/lang/String;)[Ljava/io/File;",
                                                    NULL);
        if (dirs.isValid())
        {
            QJniEnvironment env;
            jsize l = env->GetArrayLength(dirs.object<jarray>());
            for (int i = 0; i < l; i++)
            {
                QJniObject dir = env->GetObjectArrayElement(dirs.object<jobjectArray>(), i);
                QString storage = dir.toString();

                storage.truncate(storage.indexOf("/Android/data"));
                if (!storage.isEmpty())
                    storages += storage;
            }
            //qDebug() << "> android_get_storages_by_api()" << storages;
        }
    }

    return storages;
}

QString UtilsAndroid::get_external_storage() // DEPRECATED
{
    QJniObject mediaDir = QJniObject::callStaticObjectMethod("android/os/Environment",
                                                             "getExternalStorageDirectory",
                                                             "()Ljava/io/File;");

    QJniObject mediaPath = mediaDir.callObjectMethod("getAbsolutePath",
                                                     "()Ljava/lang/String;");

    QString external_storage = mediaPath.toString();
    //qDebug() << "> get_external_storage()" << external_storage;

    return external_storage;
}

QString UtilsAndroid::getExternalFilesDirPath()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject file = activity.callObjectMethod("getExternalFilesDir", "(Ljava/lang/String;)Ljava/io/File;", nullptr);

        if (file.isValid())
        {
            QJniObject path = file.callObjectMethod("getAbsolutePath", "()Ljava/lang/String;");
            return path.toString();
        }
    }

    return QString();
}

/* ************************************************************************** */

QString UtilsAndroid::getDeviceModel()
{
    QJniObject manufacturerField = QJniObject::getStaticObjectField<jstring>("android/os/Build", "MANUFACTURER");
    QJniObject modelField = QJniObject::getStaticObjectField<jstring>("android/os/Build", "MODEL");

    QString device_model = manufacturerField.toString() + " " + modelField.toString();
    //qDebug() << "> getDeviceModel()" << device_model;
    return device_model;
}

QString UtilsAndroid::getDeviceSerial()
{
    QString device_serial;

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 29)
    {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            QJniObject contentR = activity.callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");

            QJniObject aidString = QJniObject::fromString("android_id");
            QJniObject aidService = QJniObject::callStaticObjectMethod("android/provider/Settings$Secure", "getString",
                                                                       "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;",
                                                                       contentR.object<jobject>(),
                                                                       aidString.object<jstring>());
            device_serial = aidService.toString();
        }
    }
    else
    {
        QJniObject serialField = QJniObject::callStaticObjectMethod("android/os/Build",
                                                                    "getSerial",
                                                                    "()Ljava/lang/String;");
        device_serial = serialField.toString();
    }

    //qDebug() << "> getDeviceSerial()" << device_serial;
    return device_serial;
}

/* ************************************************************************** */

void UtilsAndroid::screenKeepOn(bool on)
{
    //qDebug() << "> screenKeepOn(" << on << ")";

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
            if (window.isValid())
            {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on)
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                else
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
            }
        }
        QJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });
}

/*
    enum ScreenOrientation_android {
        SCREEN_ORIENTATION_UNSPECIFIED = -1,
        SCREEN_ORIENTATION_LANDSCAPE = 0,
        SCREEN_ORIENTATION_PORTRAIT = 1,
        SCREEN_ORIENTATION_SENSOR_LANDSCAPE = 6,
        SCREEN_ORIENTATION_SENSOR_PORTRAIT = 7,
        SCREEN_ORIENTATION_REVERSE_LANDSCAPE = 8,
        SCREEN_ORIENTATION_REVERSE_PORTRAIT = 9,
    };
*/

void UtilsAndroid::screenLockOrientation(int orientation)
{
    //qDebug() << "> screenLockOrientation(" << orientation << ")";

    int value = 1;
    if (orientation != 0) value = 0;

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }
}

void UtilsAndroid::screenLockOrientation(int orientation, bool autoRotate)
{
    //qDebug() << "> screenLockOrientation(" << orientation << "-" << autoRotate << ")";

    int value = -1;

    if (orientation)
    {
        if (autoRotate)
        {
            if (orientation == 1 || orientation == 2) value = 7;
            else if (orientation == 4 || orientation == 8) value = 6;
        }
        else
        {
            if (orientation == 1) value = 1;
            else if (orientation == 2) value = 9;
            else if (orientation == 4) value = 0;
            else if (orientation == 8) value = 8;
        }
    }

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }
}

/* ************************************************************************** */

void UtilsAndroid::vibrate(int milliseconds)
{
    if (milliseconds > 100) milliseconds = 100;

    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid())
        {
            QJniObject vibratorString = QJniObject::fromString("vibrator");
            QJniObject vibratorService = activity.callObjectMethod("getSystemService",
                                                                   "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                   vibratorString.object<jstring>());
            if (vibratorService.callMethod<jboolean>("hasVibrator", "()Z"))
            {
                if (QNativeInterface::QAndroidApplication::sdkVersion() < 26)
                {
                    // vibrate (long milliseconds) // Deprecated in API level 26

                    jlong ms = milliseconds;
                    vibratorService.callMethod<void>("vibrate", "(J)V", ms);
                }
                else
                {
                    // vibrate(VibrationEffect vibe) // Added in API level 26

                    jint effect = 0x00000002;
                    QJniObject vibrationEffect = QJniObject::callStaticObjectMethod("android/os/VibrationEffect",
                                                                                    "createPredefined",
                                                                                    "(I)Landroid/os/VibrationEffect;",
                                                                                    effect);

                    vibratorService.callMethod<void>("vibrate",
                                                     "(Landroid/os/VibrationEffect;)V",
                                                     vibrationEffect.object<jobject>());
                }
            }
        }
        QJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });
}

/* ************************************************************************** */

QString UtilsAndroid::getWifiSSID()
{
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject wifiManager = activity.callObjectMethod("getSystemService",
                                                           "(Ljava/lang/String;)Ljava/lang/Object;",
                                                           QJniObject::fromString("wifi").object());

        if (wifiManager.isValid())
        {
            QJniObject wifiInfo = wifiManager.callObjectMethod("getConnectionInfo",
                                                               "()Landroid/net/wifi/WifiInfo;");

            if (wifiInfo.isValid())
            {
                QString ssid = wifiInfo.callObjectMethod("getSSID", "()Ljava/lang/String;").toString();

                if (ssid.startsWith("\"")) ssid.removeFirst();
                if (ssid.endsWith("\"")) ssid.removeLast();

                if (ssid == "<unknown ssid>") ssid.clear();
                if (ssid.startsWith("<") && ssid.endsWith(">")) ssid.clear();

                return ssid;
            }
            else
            {
                qDebug() << "Failed to get WiFi Info";
            }
        }
        else
        {
            qDebug() << "Failed to get WifiManager";
        }
    }
    else
    {
        qDebug() << "Invalid Activity";
    }

    return QString();
}

/* ************************************************************************** */

void UtilsAndroid::openStorePage(const QString &packageName)
{
    //qDebug() << "> openStorePage(" << packageName << ")";

    QJniObject jappPackage = QJniObject::fromString("market://details?id=" + packageName);

    QJniObject intent = QJniObject::callStaticObjectMethod("android/content/Intent", "parseUri",
                                                           "(Ljava/lang/String;I)Landroid/content/Intent;",
                                                           jappPackage.object<jstring>(), 0);
    if (!intent.isValid())
    {
        qWarning("Unable to create Intent object for the store page");
        return;
    }

    QtAndroidPrivate::startActivity(intent, 0);
}

/* ************************************************************************** */

void UtilsAndroid::openApplicationInfo(const QString &packageName)
{
    //qDebug() << "> openApplicationInfo(" << packageName << ")";

    QJniObject jpackageName = QJniObject::fromString("package:" + packageName);
    QJniObject jintentName = QJniObject::fromString("android.settings.APPLICATION_DETAILS_SETTINGS");

    QJniObject juri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse",
                                                         "(Ljava/lang/String;)Landroid/net/Uri;",
                                                         jpackageName.object<jstring>());
    if (!juri.isValid())
    {
        qWarning("Unable to create Uri object for APPLICATION_DETAILS_SETTINGS");
        return;
    }

    QJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", jintentName.object<jstring>());
    if (!intent.isValid())
    {
        qWarning("Unable to create Intent object for APPLICATION_DETAILS_SETTINGS");
        return;
    }

    intent.callObjectMethod("addCategory", "(Ljava/lang/String;)Landroid/content/Intent;",
                            QJniObject::fromString("android.intent.category.DEFAULT").object<jstring>());

    intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;",
                            juri.object<jobject>());

    QtAndroidPrivate::startActivity(intent, 0);
}

/* ************************************************************************** */

void UtilsAndroid::openStorageSettings(const QString &packageName)
{
    //qDebug() << "> openStorageSettings(" << packageName << ")";

    if (QNativeInterface::QAndroidApplication::sdkVersion() >= 30)
    {
        QJniObject jpackageName = QJniObject::fromString("package:" + packageName);
        QJniObject jintentObject = QJniObject::getStaticObjectField("android/provider/Settings",
                                                                    "ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION",
                                                                    "Ljava/lang/String;");

        QJniObject juri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse",
                                                             "(Ljava/lang/String;)Landroid/net/Uri;",
                                                             jpackageName.object<jstring>());
        if (!juri.isValid())
        {
            qWarning("Unable to create Uri object for ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
            return;
        }

        QJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", jintentObject.object<jobject>());
        if (!intent.isValid())
        {
            qWarning("Unable to create Intent object for ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
            return;
        }

        intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;",
                                juri.object<jobject>());

        QtAndroidPrivate::startActivity(intent, 0);
    }
}

/* ************************************************************************** */

void UtilsAndroid::openLocationSettings()
{
    //qDebug() << "> openLocationSettings()";

    QJniObject jintentObject = QJniObject::getStaticObjectField("android/provider/Settings",
                                                                "ACTION_LOCATION_SOURCE_SETTINGS",
                                                                "Ljava/lang/String;");

    QJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", jintentObject.object<jobject>());
    if (!intent.isValid())
    {
        qWarning("Unable to create Intent object for ACTION_LOCATION_SOURCE_SETTINGS");
        return;
    }

    jint jflag = QJniObject::getStaticField<jint>("android/content/Intent", "FLAG_ACTIVITY_NEW_TASK");
    intent.callObjectMethod("setFlags", "(I)Landroid/content/Intent;", jflag);

    QtAndroidPrivate::startActivity(intent, 0);
}

/* ************************************************************************** */
#endif // Q_OS_ANDROID
