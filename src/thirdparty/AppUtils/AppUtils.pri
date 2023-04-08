
# Generic utils
SOURCES += $${PWD}/utils_app.cpp \
           $${PWD}/utils_bits.cpp \
           $${PWD}/utils_fpsmonitor.cpp \
           $${PWD}/utils_language.cpp \
           $${PWD}/utils_log.cpp \
           $${PWD}/utils_maths.cpp \
           $${PWD}/utils_screen.cpp \
           $${PWD}/utils_sysinfo.cpp

HEADERS += $${PWD}/utils_app.h \
           $${PWD}/utils_bits.h \
           $${PWD}/utils_fpsmonitor.h \
           $${PWD}/utils_language.h \
           $${PWD}/utils_log.h \
           $${PWD}/utils_maths.h \
           $${PWD}/utils_screen.h \
           $${PWD}/utils_sysinfo.h \
           $${PWD}/utils_versionchecker.h

INCLUDEPATH += $${PWD}

# Linux OS utils
linux:!android {
    QT += dbus

    SOURCES += $${PWD}/utils_os_linux.cpp
    HEADERS += $${PWD}/utils_os_linux.h
}

macx {
    # macOS OS utils
    SOURCES += $${PWD}/utils_os_macos.mm
    HEADERS += $${PWD}/utils_os_macos.h
    LIBS    += -framework IOKit

    # macOS dock click handler
    SOURCES += $${PWD}/utils_os_macosdock.mm
    HEADERS += $${PWD}/utils_os_macosdock.h
    LIBS    += -framework AppKit
}

# Windows OS utils
win32 {
    SOURCES += $${PWD}/utils_os_windows.cpp
    HEADERS += $${PWD}/utils_os_windows.h
}

# Android OS utils
android {
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

# iOS OS utils
ios {
    QT      += gui-private quick
    LIBS    += -framework UIKit

    SOURCES += $${PWD}/utils_os_ios.mm
    HEADERS += $${PWD}/utils_os_ios.h
}
