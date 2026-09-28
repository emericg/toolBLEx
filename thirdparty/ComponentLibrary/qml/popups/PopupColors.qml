pragma ComponentBehavior: Bound

import QtQuick

import ComponentLibrary

/*!
 * \brief A color picker popup, wrapping a ColorPicker, plus a settings page to tune it.
 *
 * Open it with openColor() and listen to updateColor() for the chosen color.
 * The inner picker is exposed as `picker` for anything not aliased here.
 */
PopupThemed {
    id: popupColors

    // Page available: colors, settings
    property string pageVisible: "colors"

    // settings
    property bool enableSettings: true
    property alias picker: colorPicker
    property alias pickerStyle: colorPicker.pickerStyle
    property alias fieldMode: colorPicker.fieldMode
    property alias enableAlpha: colorPicker.enableAlpha
    property alias enablePresets: colorPicker.enablePresets
    property alias enableRecents: colorPicker.enableRecents
    property alias enableHarmonies: colorPicker.enableHarmonies
    property alias enableContrasts: colorPicker.enableContrasts

    ////////////////

    property alias initialColor: colorPicker.initialColor
    readonly property alias selectedColor: colorPicker.selectedColor

    signal updateColor(var newColor)

    /*!
     * \brief Opens the popup on the given color.
     * \param color: the initial color, also used as the reset target.
     */
    function openColor(color) {
        pageVisible = "colors"
        colorPicker.loadColor(color)
        popupColors.open()
    }

    ////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: Theme.animationSpeedFast; } }

    headerArea.color: popupColors.selectedColor
    headerArea.topPadding: Theme.componentMarginS
    headerArea.bottomPadding: Theme.componentMarginS
    headerArea.rightPadding: Theme.componentMarginS

    ////////////////

    header: Item { // title + reset / settings toggle
        id: headerBar
        width: parent.width
        height: Math.max(titleColumn.height, Theme.componentHeightXL)

        property color colorContent: popupColors.headerArea.solid ? UtilsColor.contrastColor(popupColors.selectedColor) : Theme.colorText
        property color colorArea: popupColors.headerArea.solid ? popupColors.selectedColor : Theme.colorBackground

        Column {
            id: titleColumn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: qsTr("Pick a color")
                font.pixelSize: 24
                color: headerBar.colorContent
            }
            Text {
                text: UtilsColor.colorToHex(popupColors.selectedColor, popupColors.enableAlpha).toUpperCase()
                font.pixelSize: 20
                color: headerBar.colorContent
                opacity: 0.8
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            RoundButtonSunken { // reset
                width: Theme.componentHeightXL
                height: Theme.componentHeightXL

                visible: (UtilsColor.colorToHex(popupColors.selectedColor, popupColors.enableAlpha) !==
                          UtilsColor.colorToHex(popupColors.initialColor, popupColors.enableAlpha))
                source: "qrc:/IconLibrary/material-icons/duotone/restart_alt.svg"

                colorBackground: headerBar.colorArea
                colorIcon: headerBar.colorContent

                onClicked: colorPicker.resetColor()
            }

            RoundButtonSunken { // colors / settings page toggle
                width: Theme.componentHeightXL
                height: Theme.componentHeightXL

                visible: popupColors.enableSettings
                source: (popupColors.pageVisible === "colors") ?
                            "qrc:/IconLibrary/material-icons/duotone/tune.svg" :
                            "qrc:/IconLibrary/material-icons/duotone/style.svg"

                colorBackground: headerBar.colorArea
                colorIcon: headerBar.colorContent

                onClicked: popupColors.pageVisible = (popupColors.pageVisible === "colors") ? "settings" : "colors"
            }
        }
    }

    ////

    Column {
        id: columnSettings

        width: parent.width
        spacing: Theme.componentMarginXL
        visible: (popupColors.pageVisible === "settings")

        SelectorMenuColorful { // picker style
            readonly property var styles: [ "wheel", "square", "ring", "sliders" ]

            height: Theme.componentHeight

            currentSelection: styles.indexOf(popupColors.pickerStyle)
            model: ListModel {
                ListElement { idx: 0; src: "qrc:/IconLibrary/material-symbols/media/panorama_fish_eye.svg"; sz: 22; }
                ListElement { idx: 1; src: "qrc:/IconLibrary/material-symbols/crop_square.svg"; sz: 22; }
                ListElement { idx: 2; src: "qrc:/IconLibrary/material-symbols/trip_origin.svg"; sz: 22; }
                ListElement { idx: 3; src: "qrc:/IconLibrary/material-symbols/sliders.svg"; sz: 22; }
            }
            onMenuSelected: (index) => popupColors.pickerStyle = styles[index]
        }

        SelectorMenuColorful { // field mode
            readonly property var modes: [ "rgb", "hsv", "hsl" ]

            height: Theme.componentHeight

            currentSelection: modes.indexOf(popupColors.fieldMode)
            model: ListModel {
                ListElement { idx: 0; txt: "RGB"; }
                ListElement { idx: 1; txt: "HSV"; }
                ListElement { idx: 2; txt: "HSL"; }
            }
            onMenuSelected: (index) => popupColors.fieldMode = modes[index]
        }

        Repeater { // picker features, toggling the matching popup property
            model: [
                { text: qsTr("Enable Alpha"), setting: "enableAlpha" },
                { text: qsTr("Enable Presets"), setting: "enablePresets" },
                { text: qsTr("Enable Recents"), setting: "enableRecents" },
                { text: qsTr("Enable Harmonies"), setting: "enableHarmonies" },
                { text: qsTr("Enable Contrasts"), setting: "enableContrasts" },
            ]

            SwitchThemed {
                required property var modelData

                text: modelData.text
                checked: popupColors[modelData.setting]
                onToggled: popupColors[modelData.setting] = checked
            }
        }
    }

    ////

    ColorPicker {
        id: colorPicker
        width: parent.width

        visible: (popupColors.pageVisible === "colors")
    }

    ////

    footer: Flow { // buttons
        width: parent.width
        spacing: Theme.componentMargin

        property int btnCount: 2
        property int btnSize: Theme.singleColumn ? width : ((width-(spacing*(btnCount-1))) / btnCount)

        ButtonClear {
            width: parent.btnSize

            text: qsTr("Cancel")
            color: Theme.colorGrey

            onClicked: popupColors.close()
        }

        ButtonFlat {
            width: parent.btnSize

            text: qsTr("Select")
            color: Theme.colorPrimary

            onClicked: {
                colorPicker.addRecent(popupColors.selectedColor)
                popupColors.updateColor(popupColors.selectedColor)
                popupColors.close()
            }
        }
    }

    ////////////////
}
