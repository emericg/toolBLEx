cmake_minimum_required(VERSION 3.20)

project(toolBLEx VERSION 0.17 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(APP_NAME ${PROJECT_NAME})
set(APP_VERSION ${PROJECT_VERSION})

################################################################################

message(STATUS ">>> BUILDING ${PROJECT_NAME} v${PROJECT_VERSION} >>>")
message(STATUS "[CMAKE] CMAKE_VERSION               = ${CMAKE_VERSION}")
message(STATUS "[CMAKE] CMAKE_PREFIX_PATH           = ${CMAKE_PREFIX_PATH}")
message(STATUS "[BUILD] QT_HOST_PATH                = ${QT_HOST_PATH}")
message(STATUS "[BUILD] TOOLCHAIN_FILE              = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[BUILD] BUILD_TYPE                  = ${CMAKE_BUILD_TYPE}")
message(STATUS "[SYSTEM] (HOST) SYSTEM NAME         = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (HOST) SYSTEM VERSION      = ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "[SYSTEM] (HOST) SYSTEM PROCESSOR    = ${CMAKE_HOST_SYSTEM_PROCESSOR}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM NAME       = ${CMAKE_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM VERSION    = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM PROCESSOR  = ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "[TOP PROJECT] CMAKE_PROJECT_NAME    = ${CMAKE_PROJECT_NAME}")
message(STATUS "[TOP PROJECT] CMAKE_PROJECT_VERSION = ${CMAKE_PROJECT_VERSION}")
message(STATUS "[TOP PROJECT] CMAKE_SOURCE_DIR      = ${CMAKE_SOURCE_DIR}")
message(STATUS "[PROJECT] PROJECT_NAME              = ${PROJECT_NAME}")
message(STATUS "[PROJECT] PROJECT_VERSION           = ${PROJECT_VERSION}")
message(STATUS "[PROJECT] PROJECT_SOURCE_DIR        = ${PROJECT_SOURCE_DIR}")
message(STATUS "[PROJECT] CMAKE_CURRENT_SOURCE_DIR  = ${CMAKE_CURRENT_SOURCE_DIR}")

################################################################################

find_package(Qt6 REQUIRED COMPONENTS Core Gui Svg Qml Quick QuickControls2 QuickPrivate)
find_package(Qt6 REQUIRED COMPONENTS Sql Bluetooth Graphs Widgets)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(REQUIRES 6.8
                          I18N_SOURCE_LANGUAGE en
                          I18N_TRANSLATED_LANGUAGES en fr ru)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0002 NEW)
qt_policy(SET QTP0003 NEW)
qt_policy(SET QTP0004 NEW)

set(SOURCES
    src/main.cpp
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/MenubarManager.cpp src/MenubarManager.h
    src/SettingsManager.cpp src/SettingsManager.h

    src/DeviceManager.cpp src/DeviceManager.h
    src/DeviceManager_advertisement.cpp src/DeviceManager_rssigraph.cpp
    src/DeviceFilter.cpp src/DeviceFilter.h src/DeviceHeader.h
    src/BleServiceInfo.cpp src/BleServiceInfo.h
    src/BleCharacteristicInfo.cpp src/BleCharacteristicInfo.h
    src/VendorsDatabase.cpp src/VendorsDatabase.h

    src/adapter.cpp src/adapter.h
    src/device.cpp src/device.h src/device_utils.h
    src/device_toolblex.cpp src/device_toolblex.h
    src/device_toolblex_adv.cpp src/device_toolblex_adv.h
    src/DeviceAdvModel.cpp src/DeviceAdvModel.h
    src/DeviceLogModel.cpp src/DeviceLogModel.h

    src/ubertooth.cpp src/ubertooth.h
    src/ColormapFactory.cpp src/ColormapFactory.h
    src/WaterfallGraph_QuickItem.cpp src/WaterfallGraph_QuickItem.h
    src/SpectrumGraph3D_SurfaceHandler.cpp src/SpectrumGraph3D_SurfaceHandler.h
    src/PhosphorPersistenceGraph_QuickItem.cpp src/PhosphorPersistenceGraph_QuickItem.h

    assets/assets.qrc
    assets/vendors.qrc

    thirdparty/IconLibrary/IconLibrary_bootstrap.qrc
    thirdparty/IconLibrary/IconLibrary_material.qrc
)

if(NOT IOS AND NOT ANDROID)
    # Desktop app icons
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        set(app_icon_windows "${PROJECT_SOURCE_DIR}/assets/windows/${PROJECT_NAME}.rc")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(app_icon_macos "${PROJECT_SOURCE_DIR}/assets/macos/${PROJECT_NAME}.icns")
    endif()

    # Desktop only source files
    set(SOURCES_DESKTOP
        ${app_icon_windows}
        ${app_icon_macos}
    )
endif()

qt_add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${SOURCES_DESKTOP}
)

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
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

        qml/graphs/RssiBar.qml
        qml/graphs/RssiGraph.qml
        qml/graphs/ProximityRadar.qml
        qml/graphs/SpectrumGraph3D.qml
        qml/graphs/SpectrumGraph2D.qml
        qml/graphs/FrequencyGraph.qml
        qml/graphs/FrequencyGraphLegend.qml
        qml/graphs/FrequencyGraphOverlayBands.qml
        qml/graphs/FrequencyGraphOverlayClickable.qml
        qml/graphs/PhosphorPersistenceGraph.qml
        qml/graphs/WaterfallGraph.qml
        qml/graphs/WaterfallGraphLabels.qml
        qml/graphs/WaterfallGraphOverlayBands.qml

        qml/components/ButtonScanMenu.qml
        qml/components/ItemActionTag.qml
        qml/components/SelectorMenuThemedItemBadge.qml
        qml/components/DeviceScannerListHeader.qml
        qml/components/DeviceScannerListWidget.qml
        qml/components/DeviceScannerTableHeader.qml
        qml/components/DeviceScannerTableWidget.qml
        qml/components/WarningNoAdapter.qml
        qml/components/WarningNoBluetooth.qml
        qml/components/WarningNoPermission.qml
        qml/components/WarningNotImplemented.qml

        qml/components_js/UtilsBluetooth.js
        qml/components_js/UtilsDeviceSensors.js

        qml/popups/PopupClearDeviceSeenCache.qml
        qml/popups/PopupClearDeviceStructureCache.qml
        qml/popups/PopupExportDeviceData.qml
        qml/popups/PopupExportScannerData.qml
        qml/popups/PopupWriteCharacteristic.qml

        qml/widgets/AdapterWidget.qml
        qml/widgets/AdvertisementDataWidget.qml
        qml/widgets/AdvertisementDataWidgetAdvanced.qml
        qml/widgets/BleServiceWidget.qml
        qml/widgets/BleCharacteristicWidget.qml
        qml/widgets/DeviceLogWidget.qml

    SOURCES
        src/DatabaseManager.cpp src/DatabaseManager.h
        src/MenubarManager.cpp src/MenubarManager.h
        src/SettingsManager.cpp src/SettingsManager.h
        src/ColormapFactory.cpp src/ColormapFactory.h
        src/WaterfallGraph_QuickItem.cpp src/WaterfallGraph_QuickItem.h
        src/SpectrumGraph3D_SurfaceHandler.cpp src/SpectrumGraph3D_SurfaceHandler.h
        src/PhosphorPersistenceGraph_QuickItem.cpp src/PhosphorPersistenceGraph_QuickItem.h
)

qt_add_translations(${PROJECT_NAME}
    TS_FILE_BASE ${PROJECT_NAME}
    TS_FILE_DIR ${PROJECT_SOURCE_DIR}/i18n/
    RESOURCE_PREFIX "/i18n"
)

################################################################################

# "Other Files" macro
function(add_other_files target)
    foreach(file IN LISTS ARGN)
        target_sources(${target} PRIVATE ${file})
        source_group("Other Files" FILES ${file})
    endforeach()
endfunction()

add_other_files(${PROJECT_NAME}
    README.md TODO.md LICENSE.md
    deploy_linux.sh deploy_macos.sh deploy_windows.sh
    .github/workflows/builds_desktop.yml
    .github/workflows/flatpak.yml
    .gitignore
)

################################################################################

# SingleApplication
set(QAPPLICATION_CLASS QApplication)
add_subdirectory(thirdparty/SingleApplication)
target_link_libraries(${PROJECT_NAME} PRIVATE SingleApplication)

# AppUtils
set(UTILS_QT_RHI ON CACHE BOOL "UTILS_QT_RHI" FORCE)
set(UTILS_DOCK_ENABLED ON CACHE BOOL "UTILS_DOCK_ENABLED" FORCE)
add_subdirectory(thirdparty/AppUtils)
target_link_libraries(${PROJECT_NAME} PRIVATE AppUtils)

# ComponentLibrary
add_subdirectory(thirdparty/ComponentLibrary)
target_link_libraries(${PROJECT_NAME} PRIVATE ComponentLibrary_plugin)

# Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Svg
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickPrivate
    Qt6::Sql
    Qt6::Bluetooth
    Qt6::Graphs
    Qt6::Widgets
)

target_include_directories(${PROJECT_NAME} PRIVATE src/)
target_include_directories(${PROJECT_NAME} PRIVATE thirdparty/)

# Qt official hacks...
set(QML_IMPORT_PATH
    "${CMAKE_BINARY_DIR}/thirdparty/"
    "${CMAKE_BINARY_DIR}/thirdparty/MobileUI"
    "${CMAKE_BINARY_DIR}/thirdparty/ComponentLibrary"
    CACHE STRING "QML Modules import paths" FORCE)

# Qt official hacks...
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

################################################################################

## Release build? Set "no debug" macros
target_compile_definitions(${PROJECT_NAME} PRIVATE
    $<$<CONFIG:Release>:NDEBUG>
    $<$<CONFIG:Release>:QT_NO_DEBUG>
    $<$<CONFIG:Release>:QT_NO_DEBUG_OUTPUT>
)

################################################################################

include(GNUInstallDirs)

## Linux
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.desktop DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications/)
    install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.appdata.xml DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/appdata/)
    install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.svg DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pixmaps/)
    install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.svg DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/scalable/apps/)
    install(FILES ${PROJECT_SOURCE_DIR}/LICENSE.md DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/${PROJECT_NAME}/)
endif()

## macOS
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0")
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")

    set(app_icon_macos "${PROJECT_SOURCE_DIR}/assets/macos/${PROJECT_NAME}.icns")
    set_source_files_properties(${app_icon_macos} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/assets/macos/Info.plist"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "io.emeric.toolBLEx"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS             "${PROJECT_SOURCE_DIR}/assets/macos/${PROJECT_NAME}.entitlements"
    )
endif()

## Windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

################################################################################

# Output (build)
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin"
)

# Output (install)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

################################################################################
