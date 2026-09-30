cmake_minimum_required(VERSION 3.24)

project(ComponentLibrary LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL ON)

################################################################################

list(APPEND MODULE_QML_FILES
    qml/ThemeEngine.qml

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
    qml/generics/ButtonChipBig.qml
    qml/generics/ButtonSimple.qml
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
    qml/generics/ButtonBadge.qml
    qml/generics/SelectorMenu.qml
    qml/generics/SelectorMenuSunken.qml
    qml/generics/SelectorMenuItem.qml
    qml/generics/SelectorMenuColorful.qml
    qml/generics/SelectorMenuColorfulItem.qml
    qml/generics/SelectorGrid.qml
    qml/generics/SelectorGridItem.qml
    qml/generics/TextSelectable.qml
    qml/generics/TipLine.qml

    qml/backgrounds/GradientPresets.qml
    qml/backgrounds/GradientComponent.qml
    qml/backgrounds/GradientRectangle.qml
    qml/backgrounds/HazardBand.qml
    qml/backgrounds/RectangleDebug.qml
    qml/backgrounds/RectangleHazard.qml
    qml/backgrounds/RectangleGradient.qml

    qml/cards/AboutHeader.qml
    qml/cards/CardActionRow.qml
    qml/cards/CardSquare.qml
    qml/cards/MediaCardBackground.qml
    qml/cards/MediaCardBottom.qml
    qml/cards/MediaCardCompact.qml
    qml/cards/MediaCardCompactInset.qml
    qml/cards/MediaCardLeft.qml
    qml/cards/MediaCardTop.qml
    qml/cards/MediaCardTopInset.qml
    qml/cards/SimpleCardTop.qml
    qml/cards/SimpleCardLeftRight.qml
    qml/cards/SimpleCardList.qml

    qml/controls/ButtonIconThemed.qml
    qml/controls/ButtonThemed.qml
    qml/controls/CheckBoxThemed.qml
    qml/controls/ComboBoxThemed.qml
    qml/controls/DialThemed.qml
    qml/controls/ItemDelegateThemed.qml
    qml/controls/ListElementThemed.qml
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
    qml/controls/RippleCustom.qml
    qml/controls/RippleThemed.qml
    qml/controls/RoundButtonThemed.qml
    qml/controls/RoundButtonIconThemed.qml
    qml/controls/ScrollBarThemed.qml
    qml/controls/SliderArrow.qml
    qml/controls/SliderGraduation.qml
    qml/controls/SliderThemed.qml
    qml/controls/SliderValueSolid.qml
    qml/controls/SpinBoxThemedDesktop.qml
    qml/controls/SpinBoxThemedMobile.qml
    qml/controls/SwitchThemed.qml
    qml/controls/SwitchThemedSmall.qml
    qml/controls/SwitchThemedSquare.qml
    qml/controls/TextAreaThemed.qml
    qml/controls/TextEditThemed.qml
    qml/controls/TextFieldThemed.qml
    qml/controls/ToolTipFlat.qml
    qml/controls/ToolTipThemed.qml
    qml/controls/TumblerThemed.qml

    qml/complex/FileInputArea.qml
    qml/complex/FolderInputArea.qml

    qml/layouts/FrameBox.qml
    qml/layouts/FrameHazard.qml
    qml/layouts/FrameSolid.qml
    qml/layouts/FrameStackColumn.qml
    qml/layouts/FrameStackDecorations.qml
    qml/layouts/FrameStackItem.qml
    qml/layouts/FrameStackRow.qml
    qml/layouts/FrameThemed.qml
    qml/layouts/GroupBoxThemed.qml
    qml/layouts/ListItem.qml
    qml/layouts/ListItemClickable.qml
    qml/layouts/ListSeparator.qml
    qml/layouts/ListSeparatorPadded.qml
    qml/layouts/ListSpacer.qml
    qml/layouts/ListTitle.qml
    qml/layouts/PaneThemed.qml
    qml/layouts/SectionHeader.qml
    qml/layouts/SectionExpandable.qml

    qml/menus/DesktopHeaderItem.qml
    qml/menus/DesktopSidebarItem_icon.qml
    qml/menus/DesktopSidebarItem_menu.qml
    qml/menus/DesktopSidebarItem_button.qml
    qml/menus/DesktopSidebarItem_combobox.qml
    qml/menus/DesktopSidebarItem_header.qml
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
    qml/menus/DrawerItem_menu.qml
    qml/menus/DrawerItem_button.qml
    qml/menus/TabBarThemed.qml
    qml/menus/TabButtonThemed.qml

    qml/pickers/ColorPicker.qml
    qml/pickers/DatePicker.qml
    qml/pickers/DatePickerNavigator.qml
    qml/pickers/DateTimePicker.qml
    qml/pickers/TimePicker.qml
    qml/pickers/surfaces/ColorCheckerBoard.qml
    qml/pickers/surfaces/ColorHueConicalGradient.qml
    qml/pickers/surfaces/ColorHueGradient.qml
    qml/pickers/surfaces/ColorSurface.qml
    qml/pickers/surfaces/ColorSurfaceArea.qml
    qml/pickers/surfaces/ColorSurfaceHandle.qml
    qml/pickers/surfaces/ColorSurfaceRingSquare.qml
    qml/pickers/surfaces/ColorSurfaceSlider.qml
    qml/pickers/surfaces/ColorSurfaceSliders.qml
    qml/pickers/surfaces/ColorSurfaceSquare.qml
    qml/pickers/surfaces/ColorSurfaceSVSquare.qml
    qml/pickers/surfaces/ColorSurfaceWheel.qml
    qml/pickers/surfaces/DateSurfaceMonth.qml
    qml/pickers/surfaces/DateSurfaceMonthYear.qml
    qml/pickers/surfaces/TimeSurfaceTumbler.qml

    qml/popups/PopupThemed.qml
    qml/popups/PopupMessage.qml
    qml/popups/PopupChoice.qml
    qml/popups/PopupDate.qml
    qml/popups/PopupDateTime.qml
    qml/popups/PopupTime.qml
    qml/popups/PopupColors.qml
    qml/popups/DialogThemed.qml

    qml/tags/CardTagLabel.qml
    qml/tags/CardTagClearIcon.qml
    qml/tags/TagClear.qml
    qml/tags/TagDesktop.qml
    qml/tags/TagFlat.qml
    qml/tags/TagImpl.qml
    qml/tags/TagButtonClear.qml
    qml/tags/TagButtonDesktop.qml
    qml/tags/TagButtonFlat.qml
    qml/tags/TagButtonImpl.qml

    qml/utils/CsdMac.qml
    qml/utils/CsdWindows.qml
    qml/utils/CsdLinux.qml
    qml/utils/FpsMonitor.qml
    qml/utils/MovablePoint.qml
    qml/utils/SwipeArea.qml
    qml/utils/WindowGeometrySaver.qml
)
list(APPEND MODULE_QML_FILES # DEPRECATED
    qml/deprecated/ButtonCompactable.qml
    qml/deprecated/ButtonImage.qml
    qml/deprecated/ButtonText.qml
    #qml/deprecated/RoundButtonIcon.qml
    #qml/deprecated/RoundButtonText.qml
)
list(APPEND MODULE_QML_FILES # WIP
    #qml/wip/FileInputArea_complex.qml
)

list(APPEND MODULE_JS_FILES
    qml/utils/UtilsColor.js
    qml/utils/UtilsMedia.js
    qml/utils/UtilsNumber.js
    qml/utils/UtilsPath.js
    qml/utils/UtilsString.js
)

list(APPEND MODULE_SOURCES
    #
)

list(APPEND MODULE_ASSETS
    # embedded icons
    assets/icons/add.svg
    assets/icons/arrow_right.svg
    assets/icons/autorenew.svg
    assets/icons/check.svg
    assets/icons/chevron_right.svg
    assets/icons/circle.svg
    assets/icons/circle-fill.svg
    assets/icons/close.svg
    assets/icons/label.svg
    assets/icons/menu.svg
    assets/icons/remove.svg
    # embedded background patterns
    assets/patterns/basketweave.svg
    assets/patterns/chevrons.svg
    assets/patterns/circles.svg
    assets/patterns/circles-concentric.svg
    assets/patterns/cubes.svg
    assets/patterns/cubes-lines.svg
    assets/patterns/diamonds.svg
    assets/patterns/dots.svg
    assets/patterns/grid.svg
    assets/patterns/grid-diagonal.svg
    assets/patterns/hexagons.svg
    assets/patterns/hexagons-maze.svg
    assets/patterns/honeycomb.svg
    assets/patterns/labyrinth.svg
    assets/patterns/maze.svg
    assets/patterns/peaks.svg
    assets/patterns/squares-grid.svg
    assets/patterns/squares-mosaic.svg
    assets/patterns/stripes.svg
    assets/patterns/topography.svg
    assets/patterns/topography_light.svg
    assets/patterns/topography_ultralight.svg
    assets/patterns/triangles.svg
    assets/patterns/triangles-grid.svg
    assets/patterns/triangles-mosaic.svg
    assets/patterns/truchet-contours.svg
    assets/patterns/truchet-ribbons.svg
    assets/patterns/truchet.svg
)

if(TARGET Qt6::Location)
    list(APPEND MODULE_QML_FILES # mapping components (optional)
        qml/maps/MapButton.qml
        qml/maps/MapButtonCompass.qml
        qml/maps/MapButtonZoom.qml
        qml/maps/MapFrameArea.qml
        qml/maps/MapMarker.qml
        qml/maps/MapScale.qml
    )
    list(APPEND MODULE_ASSETS # mapping assets (optional)
        assets/maps/compass_top.svg
        assets/maps/compass_bottom.svg
        assets/maps/gps_marker.svg
        assets/maps/gps_marker_bearing.svg
    )
else()
    message(STATUS "ComponentLibrary > Skipping the mapping components as Qt6::Location is not used by the root project.")
endif()

################################################################################

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Do not compile QML files to byte code for debug targets # Way too slow...
    set_source_files_properties(${MODULE_QML_FILES} ${MODULE_JS_FILES} PROPERTIES
        QT_QML_SKIP_CACHEGEN TRUE
    )
endif()

# Mark ThemeEngine as singleton
set_source_files_properties(qml/ThemeEngine.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_QML_SOURCE_TYPENAME Theme
)
# Mark GradientPresets as singleton
set_source_files_properties(qml/backgrounds/GradientPresets.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
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
    SOURCES ${MODULE_SOURCES}
)

qt_add_resources(ComponentLibrary "ComponentLibraryAssets"
    PREFIX "/ComponentLibraryAssets"
    BASE assets
    FILES ${MODULE_ASSETS}
)

target_link_libraries(ComponentLibrary PUBLIC Qt6::Core Qt6::Quick Qt6::QuickControls2)

target_include_directories(ComponentLibrary PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################

qt_add_translations(ComponentLibrary
    SOURCE_TARGETS ComponentLibrary # pins lupdate to this module only
    TS_FILE_BASE ComponentLibrary
    TS_FILE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/i18n/
    RESOURCE_PREFIX "/i18n"
    #LUPDATE_OPTIONS -no-obsolete
    LUPDATE_TARGET ComponentLibrary_lupdate
    LRELEASE_TARGET ComponentLibrary_lrelease
)

################################################################################
