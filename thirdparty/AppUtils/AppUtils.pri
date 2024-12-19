
# Optional stuff (for macOS)
#CONFIG += UTILS_DOCK_ENABLED

# Optional stuff (for iOS)
#CONFIG += UTILS_WIFI_ENABLED
#CONFIG += UTILS_NOTIFICATIONS_ENABLED

# Generic utils
SOURCES += $${PWD}/utils_app.cpp \
           $${PWD}/utils_bits.cpp \
           $${PWD}/utils_clipboard.cpp \
           $${PWD}/utils_fpsmonitor.cpp \
           $${PWD}/utils_language.cpp \
           $${PWD}/utils_log.cpp \
           $${PWD}/utils_maths.cpp \
           $${PWD}/utils_screen.cpp \
           $${PWD}/utils_sysinfo.cpp \
           $${PWD}/utils_wifi.cpp

HEADERS += $${PWD}/utils_app.h \
           $${PWD}/utils_bits.h \
           $${PWD}/utils_clipboard.h \
           $${PWD}/utils_fpsmonitor.h \
           $${PWD}/utils_language.h \
           $${PWD}/utils_log.h \
           $${PWD}/utils_maths.h \
           $${PWD}/utils_screen.h \
           $${PWD}/utils_sysinfo.h \
           $${PWD}/utils_versionchecker.h \
           $${PWD}/utils_wifi.h

INCLUDEPATH += $${PWD}

versionAtLeast(QT_VERSION, 6.6) {
    QT += gui-private # to get RHI info
}

# Linux OS utils
linux:!android {
    QT += dbus

    SOURCES += $${PWD}/utils_os_linux.cpp
    HEADERS += $${PWD}/utils_os_linux.h
}

# macOS utils
macx {
    LIBS    += -framework IOKit
    SOURCES += $${PWD}/utils_os_macos.mm
    HEADERS += $${PWD}/utils_os_macos.h

    # macOS dock click handler (optional)
    UTILS_DOCK_ENABLED {
        DEFINES += UTILS_DOCK_ENABLED
        LIBS    += -framework AppKit
        SOURCES += $${PWD}/utils_os_macos_dock.mm
        HEADERS += $${PWD}/utils_os_macos_dock.h
    }
}

# Windows OS utils
win32 {
    DEFINES += _USE_MATH_DEFINES
    SOURCES += $${PWD}/utils_os_windows.cpp
    HEADERS += $${PWD}/utils_os_windows.h
}

# Android OS utils
android {
    DEFINES += UTILS_NOTIFICATIONS_ENABLED UTILS_WIFI_ENABLED

    versionAtLeast(QT_VERSION, 6.0) {
        QT += core-private

        SOURCES += $${PWD}/utils_os_android_qt6.cpp
        HEADERS += $${PWD}/utils_os_android.h
    } else {
        QT += androidextras

        SOURCES += $${PWD}/utils_os_android_qt5.cpp
        HEADERS += $${PWD}/utils_os_android.h
    }
}

# iOS utils
ios {
    LIBS    += -framework UIKit
    SOURCES += $${PWD}/utils_os_ios.mm
    HEADERS += $${PWD}/utils_os_ios.h

    # iOS notifications (optional)
    UTILS_NOTIFICATIONS_ENABLED {
        DEFINES += UTILS_NOTIFICATIONS_ENABLED
        LIBS    += -framework UserNotifications
        SOURCES += $${PWD}/utils_os_ios_notif.mm
        HEADERS += $${PWD}/utils_os_ios_notif.h
    }

    # iOS WiFi SSID (optional)
    UTILS_WIFI_ENABLED {
        DEFINES += UTILS_WIFI_ENABLED
        LIBS    += -framework SystemConfiguration
        SOURCES += $${PWD}/utils_os_ios_wifi.mm
        HEADERS += $${PWD}/utils_os_ios_wifi.h
    }
}
