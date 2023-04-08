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

#include "utils_os_android.h"

#if defined(Q_OS_ANDROID)

#include <QtAndroid>
#include <QtAndroidExtras>
#include <QAndroidJniObject>
#include <QDebug>

/* ************************************************************************** */

int UtilsAndroid::getSdkVersion()
{
    return QtAndroid::androidSdkVersion();
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermissions_storage()
{
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    QtAndroid::PermissionResult w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    return (r == QtAndroid::PermissionResult::Granted && w == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::checkPermission_storage_read()
{
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    return (r == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::checkPermission_storage_write()
{
    QtAndroid::PermissionResult w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    return (w == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::getPermissions_storage()
{
    return (UtilsAndroid::getPermission_storage_read() && UtilsAndroid::getPermission_storage_write());
}

bool UtilsAndroid::getPermission_storage_read()
{
    bool status = true;

    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
    if (r == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.READ_EXTERNAL_STORAGE");
        r = QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE");
        if (r == QtAndroid::PermissionResult::Denied)
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

    QtAndroid::PermissionResult w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    if (w == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE");
        w = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if (w == QtAndroid::PermissionResult::Denied)
        {
            qWarning() << "STORAGE WRITE PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_camera()
{
    QtAndroid::PermissionResult cam = QtAndroid::checkPermission("android.permission.CAMERA");
    return (cam == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::getPermission_camera()
{
    bool status = true;

    QtAndroid::PermissionResult cam = QtAndroid::checkPermission("android.permission.CAMERA");
    if (cam == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.CAMERA");
        cam = QtAndroid::checkPermission("android.permission.CAMERA");
        if (cam == QtAndroid::PermissionResult::Denied)
        {
            qWarning() << "CAMERA PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_location()
{
    QtAndroid::PermissionResult loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    return (loc == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::getPermission_location()
{
    bool status = true;

    QtAndroid::PermissionResult loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    if (loc == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.ACCESS_FINE_LOCATION");
        loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");
        if (loc == QtAndroid::PermissionResult::Denied)
        {
            qWarning() << "LOCATION READ PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::checkPermission_location_ble()
{
    QtAndroid::PermissionResult loc;

    if (QtAndroid::androidSdkVersion() >= 29)
        loc = QtAndroid::checkPermission("android.permission.ACCESS_FINE_LOCATION");
    else
        loc = QtAndroid::checkPermission("android.permission.ACCESS_COARSE_LOCATION");

    return (loc == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::getPermission_location_ble()
{
    bool status = true;

    if (!UtilsAndroid::checkPermission_location_ble())
    {
        if (QtAndroid::androidSdkVersion() >= 29)
            QtAndroid::requestPermissionsSync(QStringList() << "android.permission.ACCESS_FINE_LOCATION");
        else
            QtAndroid::requestPermissionsSync(QStringList() << "android.permission.ACCESS_COARSE_LOCATION");

        if (!UtilsAndroid::checkPermission_location_ble())
        {
            qWarning() << "LOCATION READ PERMISSION DENIED";
            status = false;
        }
    }

    return status;
}

bool UtilsAndroid::checkPermission_location_background()
{
    return false;
}

bool UtilsAndroid::getPermission_location_background()
{
    return false;
}

/* ************************************************************************** */

bool UtilsAndroid::checkPermission_phonestate()
{
    QtAndroid::PermissionResult ps = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
    return (ps == QtAndroid::PermissionResult::Granted);
}

bool UtilsAndroid::getPermission_phonestate()
{
    bool status = true;

    QtAndroid::PermissionResult ps = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
    if (ps == QtAndroid::PermissionResult::Denied)
    {
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.READ_PHONE_STATE");
        ps = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
        if (ps == QtAndroid::PermissionResult::Denied)
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

    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
    {
        QAndroidJniObject appCtx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
        if (appCtx.isValid())
        {
            QAndroidJniObject locationString = QAndroidJniObject::fromString("location");
            QAndroidJniObject locationService = appCtx.callObjectMethod("getSystemService",
                                                                        "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                        locationString.object<jstring>());
            if (locationService.callMethod<jboolean>("isLocationEnabled", "()Z"))
            {
                status = true;
            }
        }
    }

    return status;
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

    QAndroidJniObject context = QtAndroid::androidContext();

    if (context.isValid())
    {
        QAndroidJniObject dir = QAndroidJniObject::fromString(QStringLiteral(""));
        QAndroidJniObject path = context.callObjectMethod("getExternalFilesDir",
                                                          "(Ljava/lang/String;)Ljava/io/File;",
                                                          dir.object());
        storage = path.toString();
    }

    return storage;
}

QStringList UtilsAndroid::get_storages_by_api()
{
    QStringList storages;

    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
    {
        QAndroidJniObject dirs = activity.callObjectMethod("getExternalFilesDirs",
                                                           "(Ljava/lang/String;)[Ljava/io/File;",
                                                           NULL);
        if (dirs.isValid())
        {
            QAndroidJniEnvironment env;
            jsize l = env->GetArrayLength(dirs.object<jarray>());
            for (int i = 0; i < l; i++)
            {
                QAndroidJniObject dir = env->GetObjectArrayElement(dirs.object<jobjectArray>(), i);
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

QString UtilsAndroid::get_external_storage()
{
    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment",
                                                                           "getExternalStorageDirectory",
                                                                           "()Ljava/io/File;");
    QAndroidJniObject mediaPath = mediaDir.callObjectMethod("getAbsolutePath", "()Ljava/lang/String;");

    QString external_storage = mediaPath.toString();
    //qDebug() << "> get_external_storage()" << external_storage;

    return external_storage;
}

/* ************************************************************************** */

QString UtilsAndroid::getDeviceModel()
{
    QAndroidJniObject manufacturerField = QAndroidJniObject::getStaticObjectField<jstring>("android/os/Build", "MANUFACTURER");
    QAndroidJniObject modelField = QAndroidJniObject::getStaticObjectField<jstring>("android/os/Build", "MODEL");

    QString device_model = manufacturerField.toString() + " " + modelField.toString();
    //qDebug() << "> getDeviceModel()" << device_model;
    return device_model;
}

QString UtilsAndroid::getDeviceSerial()
{
    QString device_serial;

    if (QtAndroid::androidSdkVersion() >= 29)
    {
        QAndroidJniObject activity = QtAndroid::androidActivity();
        QAndroidJniObject appctx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
        QAndroidJniObject contentR = appctx.callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");

        QAndroidJniObject aidString = QAndroidJniObject::fromString("android_id");
        QAndroidJniObject aidService = QAndroidJniObject::callStaticObjectMethod("android/provider/Settings$Secure","getString",
                                                                                 "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;",
                                                                                 contentR.object<jobject>(),
                                                                                 aidString.object<jstring>());
        device_serial = aidService.toString();
    }
    else
    {
        // Deprecated method
        //QAndroidJniObject serialField = QAndroidJniObject::getStaticObjectField<jstring>("android/os/Build", "SERIAL");
        //device_serial = serialField.toString();

        QAndroidJniObject serialField = QAndroidJniObject::callStaticObjectMethod("android/os/Build",
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

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject activity = QtAndroid::androidActivity();
        if (activity.isValid())
        {
            QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
            if (window.isValid())
            {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on)
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                else
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
            }
        }
        QAndroidJniEnvironment env;
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

    QAndroidJniObject activity = QtAndroid::androidActivity();
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

    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (activity.isValid())
    {
        activity.callMethod<void>("setRequestedOrientation", "(I)V", value);
    }
}

/* ************************************************************************** */

void UtilsAndroid::vibrate(int milliseconds)
{
    if (milliseconds > 100) milliseconds = 100;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject activity = QtAndroid::androidActivity();
        if (activity.isValid())
        {
            QAndroidJniObject appCtx = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
            if (appCtx.isValid())
            {
                QAndroidJniObject vibratorString = QAndroidJniObject::fromString("vibrator");
                QAndroidJniObject vibratorService = appCtx.callObjectMethod("getSystemService",
                                                                            "(Ljava/lang/String;)Ljava/lang/Object;",
                                                                            vibratorString.object<jstring>());
                if (vibratorService.callMethod<jboolean>("hasVibrator", "()Z"))
                {
                    jlong ms = milliseconds;
                    vibratorService.callMethod<void>("vibrate", "(J)V", ms);
                }
            }
        }
        QAndroidJniEnvironment env;
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
    });
}

/* ************************************************************************** */

void UtilsAndroid::openApplicationInfo(const QString &packageName)
{
    //qDebug() << "> openApplicationInfo(" << packageName << ")";
}

/* ************************************************************************** */
#endif // Q_OS_ANDROID
