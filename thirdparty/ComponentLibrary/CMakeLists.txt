cmake_minimum_required(VERSION 3.20)

#project(ComponentLibrary LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

################################################################################

list(APPEND MODULE_QML_FILES
    qml/ThemeEngine.qml

    qml/menus/DesktopHeaderItem.qml
    qml/menus/DesktopSidebarItem.qml
    qml/menus/DesktopSidebarMenu.qml
    qml/menus/DesktopSidebarSubMenu.qml
    qml/menus/MobileMenuItem_horizontal.qml
    qml/menus/MobileMenuItem_vertical.qml
    qml/menus/ActionMenu_bottom.qml
    qml/menus/ActionMenu_floating.qml
    qml/menus/ActionMenuItem_button.qml
    qml/menus/ActionMenuItem_switch.qml
    qml/menus/ActionMenuItem_separator.qml
    qml/menus/DrawerThemed.qml
    qml/menus/DrawerItem.qml
    qml/menus/DrawerButton.qml
    qml/menus/ListItem.qml
    qml/menus/ListItemClickable.qml
    qml/menus/ListSeparator.qml
    qml/menus/ListSeparatorPadded.qml
    qml/menus/ListTitle.qml

    qml/buttons/ButtonDesktop.qml
    qml/buttons/ButtonOutline.qml
    qml/buttons/ButtonClear.qml
    qml/buttons/ButtonFlat.qml
    qml/buttons/ButtonSolid.qml
    qml/buttons/ButtonSunken.qml
    qml/buttons/ButtonWireframe.qml
    qml/buttons/ButtonImpl.qml
    qml/buttons/SquareButtonImpl.qml
    qml/buttons/SquareButtonDesktop.qml
    qml/buttons/SquareButtonOutline.qml
    qml/buttons/SquareButtonClear.qml
    qml/buttons/SquareButtonFlat.qml
    qml/buttons/SquareButtonSolid.qml
    qml/buttons/SquareButtonWireframe.qml
    qml/buttons/SquareButtonSunken.qml
    qml/buttons/RoundButtonDesktop.qml
    qml/buttons/RoundButtonOutline.qml
    qml/buttons/RoundButtonClear.qml
    qml/buttons/RoundButtonFlat.qml
    qml/buttons/RoundButtonSolid.qml
    qml/buttons/RoundButtonWireframe.qml
    qml/buttons/RoundButtonSunken.qml

    qml/generics/BannerButton.qml
    qml/generics/BannerProgressButton.qml
    qml/generics/ButtonChip.qml
    qml/generics/ButtonFab.qml
    qml/generics/ButtonFabExtended.qml
    qml/generics/ButtonToggle.qml
    qml/generics/AndroidButton.qml
    qml/generics/AndroidButtonIcon.qml
    qml/generics/AndroidTextField.qml
    qml/generics/DataBarCompact.qml
    qml/generics/DataBarSolid.qml
    qml/generics/IconSvg.qml
    qml/generics/ItemLicenseBadge.qml
    qml/generics/ItemBadge.qml
    qml/generics/ProgressArc.qml
    qml/generics/ProgressCircle.qml
    qml/generics/ProgressChip.qml
    qml/generics/SelectorMenu.qml
    qml/generics/SelectorMenuSunken.qml
    qml/generics/SelectorMenuItem.qml
    qml/generics/SelectorMenuColorful.qml
    qml/generics/SelectorMenuColorfulItem.qml
    qml/generics/SelectorGrid.qml
    qml/generics/SelectorGridItem.qml
    qml/generics/TextSelectable.qml

    qml/layouts/FrameBox.qml
    qml/layouts/FrameThemed.qml
    qml/layouts/GroupBoxThemed.qml
    qml/layouts/PaneThemed.qml
    qml/layouts/CardBox.qml

    qml/controls/ButtonIconThemed.qml
    qml/controls/ButtonThemed.qml
    qml/controls/CheckBoxThemed.qml
    qml/controls/ComboBoxThemed.qml
    qml/controls/DialThemed.qml
    qml/controls/ItemDelegateThemed.qml
    qml/controls/MiddleSliderArrow.qml
    qml/controls/MiddleSliderThemed.qml
    qml/controls/MiddleSliderValueSolid.qml
    qml/controls/PageIndicatorThemed.qml
    qml/controls/ProgressBarThemed.qml
    qml/controls/RadioButtonThemed.qml
    qml/controls/RangeSliderArrow.qml
    qml/controls/RangeSliderThemed.qml
    qml/controls/RangeSliderValue.qml
    qml/controls/RangeSliderValueSolid.qml
    qml/controls/RippleThemed.qml
    qml/controls/RoundButtonThemed.qml
    qml/controls/RoundButtonIconThemed.qml
    qml/controls/ScrollBarThemed.qml
    qml/controls/SliderArrow.qml
    qml/controls/SliderThemed.qml
    qml/controls/SliderValueSolid.qml
    qml/controls/SpinBoxThemedDesktop.qml
    qml/controls/SpinBoxThemedMobile.qml
    qml/controls/SwitchThemed.qml
    qml/controls/TextAreaThemed.qml
    qml/controls/TextEditThemed.qml
    qml/controls/TextFieldThemed.qml
    qml/controls/ToolTipFlat.qml
    qml/controls/ToolTipThemed.qml
    qml/controls/TumblerThemed.qml

    qml/complex/DatePicker.qml
    qml/complex/FileInputArea.qml
    qml/complex/FolderInputArea.qml

    qml/wip/TagClear.qml
    qml/wip/TagDesktop.qml
    qml/wip/TagFlat.qml
    qml/wip/TagImpl.qml
    qml/wip/TagButtonClear.qml
    qml/wip/TagButtonDesktop.qml
    qml/wip/TagButtonFlat.qml
    qml/wip/TagButtonImpl.qml

    qml/utils/CsdMac.qml
    qml/utils/CsdWindows.qml
    qml/utils/CsdLinux.qml
    qml/utils/FpsMonitor.qml
    qml/utils/MovablePoint.qml
    qml/utils/RectangleDebug.qml
    qml/utils/SwipeArea.qml
    qml/utils/WindowGeometrySaver.qml
)
list(APPEND MODULE_ASSETS
    assets/icons/add.svg
    assets/icons/autorenew.svg
    assets/icons/close.svg
    assets/icons/menu.svg
    assets/icons/remove.svg
)

if(TARGET Qt6::Location)
    list(APPEND MODULE_QML_FILES
        qml/maps/MapButton.qml
        qml/maps/MapButtonCompass.qml
        qml/maps/MapButtonZoom.qml
        qml/maps/MapFrameArea.qml
        qml/maps/MapMarker.qml
        qml/maps/MapScale.qml
    )
    list(APPEND MODULE_ASSETS
        assets/maps/compass_top.svg
        assets/maps/compass_bottom.svg
        assets/maps/gps_marker.svg
        assets/maps/gps_marker_bearing.svg
    )
else()
    message(STATUS "ComponentLibrary > Skipping the mapping components as Qt6::Location is not used by the root project.")
endif()

list(APPEND MODULE_QML_FILES
    qml/deprecated/ButtonCompactable.qml
    qml/deprecated/ButtonImage.qml
    qml/deprecated/ButtonText.qml
    qml/deprecated/RoundButtonIcon.qml
    qml/deprecated/RoundButtonText.qml
    qml/deprecated/SwitchThemedMobile.qml
)

list(APPEND MODULE_JS_FILES
    qml/utils/UtilsMedia.js
    qml/utils/UtilsNumber.js
    qml/utils/UtilsPath.js
    qml/utils/UtilsString.js
)

list(APPEND MODULE_SOURCES
    #
)

list(APPEND MODULE_ASSETS
    #
)

################################################################################

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Do not compile QML files to byte code for debug targets # Way too slow...
    set_source_files_properties(${MODULE_QML_FILES} ${MODULE_JS_FILES} PROPERTIES
        QT_QML_SKIP_CACHEGEN TRUE
    )
endif()

set_source_files_properties(qml/ThemeEngine.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_QML_SOURCE_TYPENAME Theme
)

################################################################################

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Quick QuickControls2)
find_package(Qt6 6.8 REQUIRED COMPONENTS LinguistTools)

qt_add_library(ComponentLibrary STATIC)

qt_add_qml_module(ComponentLibrary
    URI ComponentLibrary
    VERSION 1.0
    DEPENDENCIES QtCore QtQuick
    PLUGIN_TARGET ComponentLibrary_plugin
    QML_FILES ${MODULE_QML_FILES} ${MODULE_JS_FILES}
    RESOURCES ${MODULE_ASSETS}
    SOURCES ${MODULE_SOURCES}
)

target_link_libraries(ComponentLibrary PUBLIC Qt6::Core Qt6::Quick Qt6::QuickControls2)

target_include_directories(ComponentLibrary PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################

# The library ships its own translations catalog, embedded in its own resources
# At runtime the host application must install a QTranslator for this catalog:
#   QTranslator t;
#   t.load(":/i18n/ComponentLibrary_" + <lang> + ".qm");
#   qApp->installTranslator(&t);

qt_add_translations(ComponentLibrary
    SOURCE_TARGETS ComponentLibrary # pins lupdate to this module so it doesn't scan the whole project
    TS_FILE_BASE ComponentLibrary
    TS_FILE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/i18n/
    RESOURCE_PREFIX "/i18n"
    #LUPDATE_OPTIONS -no-obsolete
    LUPDATE_TARGET ComponentLibrary_lupdate
    LRELEASE_TARGET ComponentLibrary_lrelease
)

################################################################################
