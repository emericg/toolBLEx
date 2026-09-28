import QtQuick

import ComponentLibrary

/*!
 * \brief A date + time picker popup, wrapping a DateTimePicker.
 *
 * The date / time page selector goes into the banner area, the picker into the body.
 * Open it with openDateTime() and listen to updateDateTime() for the chosen value.
 */
PopupThemed {
    id: popupDateTime

    // settings
    property alias picker: dateTimePicker
    property alias is24Hour: dateTimePicker.is24Hour
    property int cellHeight: 72

    ////////////////

    readonly property alias selectedDateTime: dateTimePicker.selectedDateTime

    signal updateDateTime(var newdatetime)

    /*!
     * \brief Opens the picker on the given date and time.
     * \param datetime: the initially selected value.
     */
    function openDateTime(datetime) {
        dateTimePicker.loadDateTime(datetime)
        popupDateTime.open()
    }

    /*!
     * \brief Opens the picker with the date constrained to a [min, max] range.
     * \param datetime: the initially selected value.
     * \param min, max: the inclusive selectable bounds.
     */
    function openDateTime_limits(datetime, min, max) {
        dateTimePicker.loadDateTimeWithLimits(datetime, min, max)
        popupDateTime.open()
    }

    ////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: Theme.animationSpeedFast; } }

    headerArea.topPadding: Theme.componentMarginS
    headerArea.bottomPadding: Theme.componentMarginS
    headerArea.rightPadding: Theme.componentMarginS

    bannerArea.topPadding: Theme.componentMarginS
    bannerArea.bottomPadding: Theme.componentMarginS

    bodyArea.topPadding: Theme.componentMargin
    bodyArea.leftPadding: 8
    bodyArea.rightPadding: 8

    ////////////////

    header: Item { // datetime recap + reset button
        width: parent.width
        height: Math.max(dateColumn.height, Theme.componentHeightXL)

        Column {
            id: dateColumn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: dateTimePicker.selectedDateTime.toLocaleString(popupDateTime.locale, "hh:mm")
                font.pixelSize: 24
                color: popupDateTime.headerArea.solid ? "white" : Theme.colorText
            }
            Text {
                text: dateTimePicker.selectedDateTime.toLocaleString(popupDateTime.locale, "dddd dd MMMM yyyy")
                font.pixelSize: 20
                font.capitalization: Font.Capitalize
                color: popupDateTime.headerArea.solid ? "white" : Theme.colorSubText
            }
        }

        RoundButtonSunken { // reset
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.componentHeightXL
            height: Theme.componentHeightXL

            visible: (dateTimePicker.selectedDateTime.getTime() !== dateTimePicker.initialDateTime.getTime())
            source: "qrc:/IconLibrary/material-icons/duotone/restart_alt.svg"

            colorBackground: popupDateTime.headerArea.solid ? popupDateTime.headerArea.color : Theme.colorBackground
            colorHighlight: Qt.lighter(colorBackground, 0.95)
            colorIcon: popupDateTime.headerArea.solid ? "white" : Theme.colorIcon

            onClicked: dateTimePicker.resetDateTime()
        }
    }

    ////

    banner: Item { // date / time page selector
        width: parent.width
        height: Theme.componentHeight

        SelectorMenuColorful {
            anchors.centerIn: parent
            height: Theme.componentHeight

            currentSelection: dateTimePicker.page
            model: ListModel {
                ListElement { idx: 0; txt: qsTr("Date"); src: ""; sz: 0; }
                ListElement { idx: 1; txt: qsTr("Time"); src: ""; sz: 0; }
            }
            onMenuSelected: (index) => { dateTimePicker.page = index }
        }
    }

    ////

    DateTimePicker {
        id: dateTimePicker
        width: parent.width
        cellHeight: popupDateTime.cellHeight
        selectorVisible: false
        locale: popupDateTime.locale
    }

    ////

    footer: Flow { // buttons
        width: parent.width
        spacing: Theme.componentMargin

        property int btnCount: 2
        property int btnSize: Theme.singleColumn ? width : ((width - (spacing * (btnCount - 1))) / btnCount)

        ButtonClear {
            width: parent.btnSize

            text: qsTr("Cancel")
            color: Theme.colorGrey

            onClicked: popupDateTime.close()
        }

        ButtonFlat {
            width: parent.btnSize

            text: qsTr("Select")
            color: Theme.colorPrimary

            onClicked: {
                popupDateTime.updateDateTime(dateTimePicker.selectedDateTime)
                popupDateTime.close()
            }
        }
    }

    ////////////////
}
