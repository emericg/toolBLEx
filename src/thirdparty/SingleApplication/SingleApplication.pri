QT += core network
CONFIG += c++11

SOURCES += $${PWD}/SingleApplication.cpp \
           $${PWD}/SingleApplication_private.cpp

HEADERS += $${PWD}/SingleApplication.h \
           $${PWD}/SingleApplication_private.h

INCLUDEPATH += $${PWD}

win32 {
    msvc: LIBS += Advapi32.lib
    gcc: LIBS += -ladvapi32
}
