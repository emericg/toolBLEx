qt_add_library(ComponentLibrary STATIC)

# Use that find_package() call in the root project:
find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick QuickControls2)

################################################################################

list(APPEND MODULE_ASSETS
    #
)

list(APPEND MODULE_QML_FILES
    ThemeEngine.qml

    menus/DesktopHeaderItem.qml
    menus/DesktopSidebarItem.qml
    menus/DesktopSidebarMenu.qml
    menus/DesktopSidebarSubMenu.qml
    menus/MobileMenuItem_horizontal.qml
    menus/MobileMenuItem_vertical.qml
    menus/ActionMenu_bottom.qml
    menus/ActionMenu_floating.qml
    menus/ActionMenuItem_button.qml
    menus/ActionMenuItem_switch.qml
    menus/ActionMenuItem_separator.qml
    menus/DrawerThemed.qml
    menus/DrawerItem.qml
    menus/DrawerButton.qml
    menus/ListItem.qml
    menus/ListItemClickable.qml
    menus/ListSeparator.qml
    menus/ListSeparatorPadded.qml
    menus/ListTitle.qml

    buttons/ButtonDesktop.qml
    buttons/ButtonOutline.qml
    buttons/ButtonClear.qml
    buttons/ButtonFlat.qml
    buttons/ButtonSolid.qml
    buttons/ButtonSunken.qml
    buttons/ButtonWireframe.qml
    buttons/ButtonImpl.qml
    buttons/RoundButtonDesktop.qml
    buttons/RoundButtonOutline.qml
    buttons/RoundButtonClear.qml
    buttons/RoundButtonFlat.qml
    buttons/RoundButtonSolid.qml
    buttons/RoundButtonWireframe.qml
    buttons/RoundButtonSunken.qml
    buttons/RoundButtonImpl.qml
    buttons/SquareButtonDesktop.qml
    buttons/SquareButtonOutline.qml
    buttons/SquareButtonClear.qml
    buttons/SquareButtonFlat.qml
    buttons/SquareButtonSolid.qml
    buttons/SquareButtonWireframe.qml
    buttons/SquareButtonSunken.qml
    buttons/SquareButtonImpl.qml

    generic/ButtonChip.qml
    generic/ButtonFab.qml
    generic/ButtonFabExtended.qml
    generic/ButtonToggle.qml
    generic/AndroidButton.qml
    generic/AndroidButtonIcon.qml
    generic/AndroidTextField.qml
    generic/DataBarCompact.qml
    generic/DataBarSolid.qml
    generic/IconSvg.qml
    generic/ItemLicenseBadge.qml
    generic/ItemBadge.qml
    generic/ProgressArc.qml
    generic/ProgressCircle.qml
    generic/ProgressChip.qml
    generic/SelectorMenu.qml
    generic/SelectorMenuSunken.qml
    generic/SelectorMenuItem.qml
    generic/SelectorMenuColorful.qml
    generic/SelectorMenuColorfulItem.qml
    generic/SelectorGrid.qml
    generic/SelectorGridItem.qml

    layouts/FrameBox.qml
    layouts/FrameThemed.qml
    layouts/GroupBoxThemed.qml
    layouts/PaneThemed.qml
    layouts/CardBox.qml

    controls/ButtonIconThemed.qml
    controls/ButtonThemed.qml
    controls/CheckBoxThemed.qml
    controls/ComboBoxThemed.qml
    controls/DialThemed.qml
    controls/ItemDelegateThemed.qml
    controls/MiddleSliderArrow.qml
    controls/MiddleSliderThemed.qml
    controls/MiddleSliderValueSolid.qml
    controls/PageIndicatorThemed.qml
    controls/ProgressBarThemed.qml
    controls/RadioButtonThemed.qml
    controls/RangeSliderArrow.qml
    controls/RangeSliderThemed.qml
    controls/RangeSliderValue.qml
    controls/RangeSliderValueSolid.qml
    controls/RippleThemed.qml
    controls/RoundButtonThemed.qml
    controls/RoundButtonIconThemed.qml
    controls/ScrollBarThemed.qml
    controls/SliderArrow.qml
    controls/SliderThemed.qml
    controls/SliderValueSolid.qml
    controls/SpinBoxThemedDesktop.qml
    controls/SpinBoxThemedMobile.qml
    controls/SwitchThemed.qml
    controls/TextAreaThemed.qml
    controls/TextEditThemed.qml
    controls/TextFieldThemed.qml
    controls/ToolTipFlat.qml
    controls/ToolTipThemed.qml
    controls/TumblerThemed.qml

    complex/DatePicker.qml
    complex/FileInputArea.qml
    complex/FolderInputArea.qml

    wip/TagClear.qml
    wip/TagDesktop.qml
    wip/TagFlat.qml
    wip/TagImpl.qml
    wip/TagButtonClear.qml
    wip/TagButtonDesktop.qml
    wip/TagButtonFlat.qml
    wip/TagButtonImpl.qml

    utils/CsdMac.qml
    utils/CsdWindows.qml
    utils/CsdLinux.qml
    utils/FpsMonitor.qml
    utils/MovablePoint.qml
    utils/RectangleDebug.qml
    utils/SwipeArea.qml
    utils/WindowGeometrySaver.qml
)

if(TARGET Qt::Location)
    list(APPEND MODULE_QML_FILES
        maps/MapButton.qml
        maps/MapButtonCompass.qml
        maps/MapButtonZoom.qml
        maps/MapFrameArea.qml
        maps/MapMarker.qml
        maps/MapScale.qml
    )
else()
    message(STATUS "ComponentLibrary > Skipping the mapping components as Qt6::Location is not used by the root project.")
endif()

list(APPEND MODULE_QML_FILES
    deprecated/ButtonCompactable.qml
    deprecated/ButtonImage.qml
    deprecated/ButtonText.qml
    deprecated/SwitchThemedMobile.qml
    deprecated/RoundButtonIcon.qml
    deprecated/RoundButtonText.qml
)

list(APPEND MODULE_JS_FILES
    utils/UtilsMedia.js
    utils/UtilsNumber.js
    utils/UtilsPath.js
    utils/UtilsString.js
)

list(APPEND MODULE_SOURCES
    #
)

################################################################################

set_source_files_properties(${MODULE_QML_FILES} ${MODULE_JS_FILES} PROPERTIES
    QT_QML_SKIP_CACHEGEN TRUE
)

set_source_files_properties(ThemeEngine.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_QML_SOURCE_TYPENAME Theme
)

set_target_properties(ComponentLibrary PROPERTIES AUTOMOC ON)
set_target_properties(ComponentLibrary PROPERTIES AUTORCC ON)

target_include_directories(ComponentLibrary PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(ComponentLibrary PRIVATE Qt6::Core Qt6::Quick Qt6::QuickControls2)

qt_add_qml_module(ComponentLibrary
    URI ComponentLibrary
    VERSION 1.0
    DEPENDENCIES QtCore QtQuick
    QML_FILES ${MODULE_QML_FILES} ${MODULE_JS_FILES}
    RESOURCES ${MODULE_ASSETS}
    SOURCES ${MODULE_SOURCES}
)
