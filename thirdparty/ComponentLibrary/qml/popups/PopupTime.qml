import QtQuick

import ComponentLibrary

/*!
 * \brief A time picker popup, wrapping a TimePicker.
 *
 * Open it with openTime() and listen to updateTime() for the chosen time.
 */
PopupThemed {
    id: popupTime

    // settings
    property alias picker: timePicker
    property alias is24Hour: timePicker.is24Hour

    ////////////////

    readonly property alias selectedTime: timePicker.selectedTime

    signal updateTime(var newtime)

    /*!
     * \brief Opens the picker on the given time.
     * \param time: the initially selected time.
     */
    function openTime(time) {
        timePicker.loadTime(time)
        popupTime.open()
    }

    ////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: Theme.animationSpeedFast; } }

    headerArea.topPadding: Theme.componentMarginS
    headerArea.bottomPadding: Theme.componentMarginS
    headerArea.rightPadding: Theme.componentMarginS

    ////////////////

    header: Item { // datetime recap + reset button
        width: parent.width
        height: Math.max(timeColumn.height, Theme.componentHeightXL)

        Column {
            id: timeColumn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: timePicker.selectedTime.toLocaleString(popupTime.locale, "hh:mm:ss")
                font.pixelSize: 24
                color: popupTime.headerArea.solid ? "white" : Theme.colorText
            }
            Text {
                text: timePicker.selectedTime.toLocaleString(popupTime.locale, "dd MMMM yyyy")
                font.pixelSize: 20
                color: popupTime.headerArea.solid ? "white" : Theme.colorSubText
            }
        }

        RoundButtonSunken { // reset
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.componentHeightXL
            height: Theme.componentHeightXL

            visible: (timePicker.selectedTime.getTime() !== timePicker.initialTime.getTime())
            source: "qrc:/IconLibrary/material-icons/duotone/restart_alt.svg"

            colorBackground: popupTime.headerArea.solid ? popupTime.headerArea.color : Theme.colorBackground
            colorHighlight: Qt.lighter(colorBackground, 0.95)
            colorIcon: popupTime.headerArea.solid ? "white" : Theme.colorIcon

            onClicked: timePicker.resetTime()
        }
    }

    ////

    TimePicker {
        id: timePicker
        width: parent.width
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

            onClicked: popupTime.close()
        }

        ButtonFlat {
            width: parent.btnSize

            text: qsTr("Select")
            color: Theme.colorPrimary

            onClicked: {
                popupTime.updateTime(timePicker.selectedTime)
                popupTime.close()
            }
        }
    }

    ////////////////
}
