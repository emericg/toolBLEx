QT += core network

!defined(QAPPLICATION_CLASS) {
    android:ios {
        # Mobile OS
        DEFINES += QAPPLICATION_CLASS=QGuiApplication
    } else {
        # Desktop OS
        DEFINES += QAPPLICATION_CLASS=QApplication
    }
}

eval(QAPPLICATION_CLASS = QApplication) {
    # QApplication needs QtWidgets
    QT += widgets
}

win32 {
    msvc: LIBS += Advapi32.lib
    gcc: LIBS += -ladvapi32
}

SOURCES += $${PWD}/SingleApplication.cpp \
           $${PWD}/SingleApplication_private.cpp

HEADERS += $${PWD}/SingleApplication.h \
           $${PWD}/SingleApplication_private.h

INCLUDEPATH += $${PWD}
