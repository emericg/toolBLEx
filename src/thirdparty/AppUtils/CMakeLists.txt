cmake_minimum_required(VERSION 3.12)

project(AppUtils LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_AUTOMOC ON)

################################################################################

if(NOT QT_DEFAULT_MAJOR_VERSION)
    set(QT_DEFAULT_MAJOR_VERSION 6 CACHE STRING "Qt version to use (5 or 6), defaults to 6")
endif()

# Generic dependencies
set(CORE_COMPONENTS Core Gui Qml Quick)
find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS ${CORE_COMPONENTS})

set(CORE_LIBRARIES
    Qt::Core
    Qt::Gui
    Qt::GuiPrivate
    Qt::Qml
    Qt::Quick
)

# Generic sources
set(CORE_SOURCES
    utils_app.cpp
    utils_app.h
    utils_bits.cpp
    utils_bits.h
    utils_fpsmonitor.cpp
    utils_fpsmonitor.h
    utils_language.cpp
    utils_language.h
    utils_log.cpp
    utils_log.h
    utils_maths.cpp
    utils_maths.h
    utils_screen.cpp
    utils_screen.h
    utils_sysinfo.cpp
    utils_sysinfo.h
    utils_versionchecker.h)

# OS specific sources & dependencies
if(CMAKE_SYSTEM_NAME STREQUAL Linux)
if(NOT ANDROID)
    set(PLATFORM_SOURCES
        utils_os_linux.cpp
        utils_os_linux.h)

    find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS DBus)
    set(PLATFORM_LIBRARIES Qt::DBus m)
endif()
endif()

if(ANDROID)
if(QT_DEFAULT_MAJOR_VERSION EQUAL 6)
    set(PLATFORM_SOURCES
        utils_os_android_qt6.cpp
        utils_os_android.h)

    set(PLATFORM_LIBRARIES Qt::CorePrivate m)
elseif(QT_DEFAULT_MAJOR_VERSION EQUAL 5)
    set(PLATFORM_SOURCES
        utils_os_android_qt5.cpp
        utils_os_android.h)

    find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS AndroidExtra)
    set(PLATFORM_LIBRARIES Qt::AndroidExtra m)
endif()
endif()

if(WIN32)
    set(PLATFORM_SOURCES
        utils_os_windows.cpp
        utils_os_windows.h)
endif()

if(APPLE AND NOT IOS)
    set(PLATFORM_SOURCES
        utils_os_macos.mm
        utils_os_macos.h
        utils_os_macos_dock.mm
        utils_os_macos_dock.h)

    set(PLATFORM_LIBRARIES "-framework AppKit" m)
endif()

if(IOS)
    set(PLATFORM_SOURCES
        utils_os_ios.mm
        utils_os_ios.h
        utils_os_ios_notif.mm
        utils_os_ios_notif.h)

    find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS Quick)
    set(PLATFORM_LIBRARIES Qt::Quick)
    set(PLATFORM_LIBRARIES Qt::GuiPrivate)
    set(PLATFORM_LIBRARIES "-framework UIKit" m)
endif()

################################################################################

add_library(AppUtils OBJECT ${CORE_SOURCES} ${PLATFORM_SOURCES})
add_library(AppUtils::AppUtils ALIAS AppUtils)

target_compile_definitions(AppUtils PUBLIC APP_NAME=\"${APP_NAME}\" APP_VERSION=\"${APP_VERSION}\")
target_link_libraries(AppUtils PRIVATE ${CORE_LIBRARIES} ${PLATFORM_LIBRARIES})
target_include_directories(AppUtils PUBLIC ${CMAKE_CURRENT_LIST_DIR})
