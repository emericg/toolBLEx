cmake_minimum_required(VERSION 3.20)

project(AppUtils LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_NO_PRIVATE_MODULE_WARNING ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

################################################################################

# Optional stuff
option(UTILS_QT_RHI "Qt RHI (Rendering Hardware Interface) utils" OFF)

# Optional stuff (for macOS)
option(UTILS_DOCK_ENABLED "macOS dock utils" OFF)

# Optional stuff (for iOS)
option(UTILS_WIFI_ENABLED "iOS WiFi SSID reading" OFF)
option(UTILS_NOTIFICATIONS_ENABLED "iOS notification handling" OFF)

################################################################################

# Generic dependencies
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick)
set(CORE_LIBRARIES Qt::Core Qt::Gui Qt::Qml Qt::Quick)

# Generic sources
set(CORE_SOURCES
    utils_app.cpp
    utils_app.h
    utils_bits.cpp
    utils_bits.h
    utils_clipboard.cpp
    utils_clipboard.h
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
    utils_wifi.cpp
    utils_wifi.h
    utils_versionchecker.h)

# Qt optional tools
if(UTILS_QT_RHI)
    add_definitions(-DUTILS_QT_RHI)

    find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)
    set(CORE_LIBRARIES ${CORE_LIBRARIES} Qt::GuiPrivate m)                      # to get RHI infos
endif()

# OS specific sources & dependencies
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
        utils_os_linux.cpp
        utils_os_linux.h)

    find_package(Qt6 REQUIRED COMPONENTS DBus)
    set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES} Qt::DBus m)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
        utils_os_android.cpp
        utils_os_android.h)

    find_package(Qt6 REQUIRED COMPONENTS CorePrivate)
    set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES} Qt::CorePrivate m)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
        utils_os_windows.cpp
        utils_os_windows.h)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
        utils_os_macos.mm
        utils_os_macos.h)

    if(UTILS_DOCK_ENABLED)
        set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
            utils_os_macos_dock.mm
            utils_os_macos_dock.h)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "-framework AppKit" m) # dock control
    endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
        utils_os_ios.mm
        utils_os_ios.h)
    set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
        "-framework UIKit" m)

    if(UTILS_NOTIFICATIONS_ENABLED)
        set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
            utils_os_ios_notif.mm
            utils_os_ios_notif.h)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "-framework UserNotifications" m)                                   # show notifications
    endif()

    if(UTILS_WIFI_ENABLED)
        set(PLATFORM_SOURCES ${PLATFORM_SOURCES}
            utils_os_ios_wifi.mm
            utils_os_ios_wifi.h)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "-framework SystemConfiguration" m)                                 # get WiFi SSID
    endif()
endif()

################################################################################

add_library(AppUtils OBJECT ${CORE_SOURCES} ${PLATFORM_SOURCES})
add_library(AppUtils::AppUtils ALIAS AppUtils)

target_compile_definitions(AppUtils PUBLIC APP_NAME=\"${APP_NAME}\" APP_VERSION=\"${APP_VERSION}\")
target_link_libraries(AppUtils PRIVATE ${CORE_LIBRARIES} ${PLATFORM_LIBRARIES})
target_include_directories(AppUtils PUBLIC ${CMAKE_CURRENT_LIST_DIR})
