cmake_minimum_required(VERSION 3.20)

project(toolBLEx VERSION 0.15 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(APP_NAME ${CMAKE_PROJECT_NAME})
set(APP_VERSION ${CMAKE_PROJECT_VERSION})

################################################################################

message(STATUS "[CMAKE]   CMAKE_VERSION             = ${CMAKE_VERSION}")
message(STATUS "[CMAKE]   CMAKE_PREFIX_PATH         = ${CMAKE_PREFIX_PATH}")
message(STATUS "[SYSTEM]  (HOST) SYSTEM NAME        = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM]  (HOST) SYSTEM VERSION     = ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "[SYSTEM]  (TARGET) SYSTEM NAME      = ${CMAKE_SYSTEM_NAME}")
message(STATUS "[SYSTEM]  (TARGET) SYSTEM VERSION   = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[PROJECT] SOURCE_DIR                = ${CMAKE_SOURCE_DIR}")
message(STATUS "[PROJECT] BUILD_TYPE                = ${CMAKE_BUILD_TYPE}")
message(STATUS "[PROJECT] TOOLCHAIN_FILE            = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[PROJECT] QT_HOST_PATH              = ${QT_HOST_PATH}")

################################################################################

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
find_package(Qt6 REQUIRED COMPONENTS Sql Bluetooth Charts Widgets)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(REQUIRES 6.8
                          I18N_SOURCE_LANGUAGE en
                          I18N_TRANSLATED_LANGUAGES en)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0002 NEW)
qt_policy(SET QTP0003 NEW)
qt_policy(SET QTP0004 NEW)

set(SOURCES
    src/main.cpp
    src/SettingsManager.cpp src/SettingsManager.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/MenubarManager.cpp src/MenubarManager.h

    src/DeviceManager.cpp src/DeviceManager.h
    src/DeviceManager_advertisement.cpp src/DeviceManager_rssigraph.cpp
    src/DeviceFilter.cpp src/DeviceFilter.h src/DeviceHeader.h
    src/BleServiceInfo.cpp src/BleServiceInfo.h
    src/BleCharacteristicInfo.cpp src/BleCharacteristicInfo.h
    src/VendorsDatabase.cpp src/VendorsDatabase.h
    src/ubertooth.cpp src/ubertooth.h
    src/adapter.cpp src/adapter.h

    src/device.cpp src/device.h src/device_utils.h
    src/device_toolblex.cpp src/device_toolblex.h
    src/device_toolblex_adv.cpp src/device_toolblex_adv.h

    assets/assets.qrc
    assets/vendors.qrc

    thirdparty/IconLibrary/IconLibrary_bootstrap.qrc
    thirdparty/IconLibrary/IconLibrary_material.qrc
)

if(NOT IOS AND NOT ANDROID)
    # Set app desktop icons
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        set(app_icon_windows "${CMAKE_SOURCE_DIR}/assets/windows/${CMAKE_PROJECT_NAME}.rc")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(app_icon_macos "${CMAKE_SOURCE_DIR}/assets/macos/${CMAKE_PROJECT_NAME}.icns")
    endif()

    set(SOURCES_DESKTOP
        ${app_icon_windows}
        ${app_icon_macos}
    )
endif()

qt_add_executable(${CMAKE_PROJECT_NAME}
    ${SOURCES}
    ${SOURCES_DESKTOP}
)

qt_add_qml_module(${CMAKE_PROJECT_NAME}
    URI ${CMAKE_PROJECT_NAME}
    NO_PLUGIN
    QML_FILES
        qml/DesktopApplication.qml
        qml/DesktopHeader.qml
        qml/ScreenBluetooth.qml
        qml/ScreenUbertooth.qml
        qml/ScreenScanner.qml
        qml/ScreenAdvertiser.qml
        qml/ScreenSettings.qml
        qml/PanelDevice.qml
        qml/PanelDeviceInfos.qml
        qml/PanelDeviceAdvertisement.qml
        qml/PanelDeviceServices.qml
        qml/PanelDeviceLog.qml
        qml/PanelScanner.qml

        qml/components/ItemActionTag.qml
        qml/components/SelectorMenuThemedItemBadge.qml
        qml/components/TextSelectable.qml
        qml/components/ButtonScanMenu.qml

        qml/components/DeviceScannerListHeader.qml
        qml/components/DeviceScannerListWidget.qml
        qml/components/DeviceScannerTableHeader.qml
        qml/components/DeviceScannerTableWidget.qml
        qml/components/FrequencyGraph.qml
        qml/components/FrequencyGraphLegend.qml
        qml/components/ProximityRadar.qml
        qml/components/RssiBar.qml
        qml/components/RssiGraph.qml
        qml/components/WarningNoAdapter.qml
        qml/components/WarningNoBluetooth.qml
        qml/components/WarningNoPermission.qml
        qml/components/WarningNotImplemented.qml

        qml/components_js/UtilsBluetooth.js
        qml/components_js/UtilsDeviceSensors.js

        qml/popups/PopupClearDeviceSeenCache.qml
        qml/popups/PopupClearDeviceStructureCache.qml
        qml/popups/PopupExportDeviceData.qml
        qml/popups/PopupWriteCharacteristic.qml

        qml/widgets/AdapterWidget.qml
        qml/widgets/AdvertisementDataWidget.qml
        qml/widgets/AdvertisementDataWidgetAdvanced.qml
        qml/widgets/BleServiceWidget.qml
        qml/widgets/BleCharacteristicWidget.qml
        qml/widgets/DeviceLogWidget.qml
)

qt_add_translations(${CMAKE_PROJECT_NAME}
    TS_FILE_BASE ${CMAKE_PROJECT_NAME}
    TS_FILE_DIR ${CMAKE_SOURCE_DIR}/i18n/
    RESOURCE_PREFIX "/i18n"
)

################################################################################

# 'Other Files" macro
function(add_other_files target)
    foreach(file IN LISTS ARGN)
        target_sources(${target} PRIVATE ${file})
        source_group("Other Files" FILES ${file})
    endforeach()
endfunction()

add_other_files(${CMAKE_PROJECT_NAME}
    README.md LICENSE.md
    deploy_linux.sh deploy_macos.sh deploy_windows.sh
    .github/workflows/builds_desktop.yml
    .github/workflows/flatpak.yml
    .gitignore
)

################################################################################

# SingleApplication
set(QAPPLICATION_CLASS QApplication)
add_subdirectory(thirdparty/SingleApplication)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE SingleApplication)

# AppUtils
set(UTILS_QT_RHI ON)
set(UTILS_DOCK_ENABLED ON)
add_subdirectory(thirdparty/AppUtils)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE AppUtils)

# ComponentLibrary
add_subdirectory(thirdparty/ComponentLibrary)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ComponentLibraryplugin)

# Qt libraries
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    Qt6::Sql
    Qt6::Bluetooth
    Qt6::Charts
    Qt6::Widgets
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE src/)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE thirdparty/)

################################################################################

## Release build? Set "no debug" macros
if(CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
        NDEBUG
        QT_NO_DEBUG
        QT_NO_DEBUG_OUTPUT
    )
endif()

## Linux
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # System install rules
    install(TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION bin/)
    install(FILES ${CMAKE_SOURCE_DIR}/assets/linux/${CMAKE_PROJECT_NAME}.desktop DESTINATION share/applications/)
    install(FILES ${CMAKE_SOURCE_DIR}/assets/linux/${CMAKE_PROJECT_NAME}.appdata.xml DESTINATION share/appdata/)
    install(FILES ${CMAKE_SOURCE_DIR}/assets/linux/${CMAKE_PROJECT_NAME}.svg DESTINATION share/pixmaps/)
    install(FILES ${CMAKE_SOURCE_DIR}/assets/linux/${CMAKE_PROJECT_NAME}.svg DESTINATION share/icons/hicolor/scalable/apps/)
    install(FILES ${CMAKE_SOURCE_DIR}/LICENSE.md DESTINATION share/licenses/${CMAKE_PROJECT_NAME}/)
endif()

## macOS
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    #set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0")

    set(app_icon_macos "${CMAKE_SOURCE_DIR}/assets/macos/${CMAKE_PROJECT_NAME}.icns")
    set_source_files_properties(${app_icon_macos} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/assets/macos/Info.plist"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "io.emeric.toolBLEx"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${CMAKE_PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${CMAKE_PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS             "${CMAKE_SOURCE_DIR}/assets/macos/${CMAKE_PROJECT_NAME}.entitlements"
    )
endif()

## Windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

################################################################################

# Output (build)
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    #ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib"
    #LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
)

################################################################################
