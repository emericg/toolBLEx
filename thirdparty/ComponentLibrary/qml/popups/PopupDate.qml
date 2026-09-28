import QtQuick

import ComponentLibrary

/*!
 * \brief A date picker popup, wrapping a DatePicker.
 *
 * The month navigation goes into the banner area, the picker into the body.
 * Set `mode: DatePicker.Birthdate` for the birthdate variant.
 * Open it with openDate() and listen to updateDate() for the chosen date.
 */
PopupThemed {
    id: popupDate

    // settings
    property alias picker: datePicker
    property alias mode: datePicker.mode
    property alias today: datePicker.today
    property alias minDate: datePicker.minDate
    property alias maxDate: datePicker.maxDate
    property int cellHeight: 72

    ////////////////

    readonly property alias selectedDate: datePicker.selectedDate

    signal updateDate(var newdate)

    /*!
     * \brief Opens the picker on the given date, resetting any min/max limit.
     * \param date: the initially selected date.
     */
    function openDate(date) {
        datePicker.loadDate(date)
        popupDate.open()
    }

    /*!
     * \brief Opens the picker constrained to a [min, max] date range.
     * \param date: the initially selected date.
     * \param min, max: the inclusive selectable bounds.
     */
    function openDate_limits(date, min, max) {
        datePicker.loadDateWithLimits(date, min, max)
        popupDate.open()
    }

    ////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: Theme.animationSpeedFast; } }

    headerArea.topPadding: Theme.componentMarginS
    headerArea.bottomPadding: Theme.componentMarginS
    headerArea.rightPadding: Theme.componentMarginS

    bannerArea.topPadding: 0
    bannerArea.bottomPadding: 0
    bannerArea.leftPadding: 2
    bannerArea.rightPadding: 2

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
                text: datePicker.selectedDate.toLocaleString(datePicker.locale, "dddd")
                font.pixelSize: 24
                font.capitalization: Font.Capitalize
                color: popupDate.headerArea.solid ? "white" : Theme.colorText
            }
            Text {
                text: datePicker.selectedDate.toLocaleString(datePicker.locale, "dd MMMM yyyy")
                font.pixelSize: 20
                color: popupDate.headerArea.solid ? "white" : Theme.colorSubText
            }
        }

        RoundButtonSunken { // reset
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.componentHeightXL
            height: Theme.componentHeightXL

            visible: (datePicker.view !== 0 ||
                      datePicker.displayedYear !== datePicker.today.getFullYear() ||
                      datePicker.displayedMonth !== datePicker.today.getMonth())
            source: "qrc:/IconLibrary/material-icons/duotone/restart_alt.svg"

            colorBackground: popupDate.headerArea.solid ? popupDate.headerArea.color : Theme.colorBackground
            colorHighlight: Qt.lighter(colorBackground, 0.95)
            colorIcon: popupDate.headerArea.solid ? "white" : Theme.colorIcon

            onClicked: datePicker.resetView()
        }
    }

    ////

    banner: DatePickerNavigator {
        width: parent.width
        picker: datePicker
        bannerVisible: false
        bannerColor: popupDate.bannerArea.solid ? popupDate.bannerArea.color : Theme.colorBackground
    }

    ////

    DatePicker {
        id: datePicker
        width: parent.width
        cellHeight: popupDate.cellHeight
        navigationVisible: false
        locale: popupDate.locale
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

            onClicked: popupDate.close()
        }

        ButtonFlat {
            width: parent.btnSize

            text: qsTr("Select")
            color: Theme.colorPrimary

            onClicked: {
                popupDate.updateDate(datePicker.selectedDate)
                popupDate.close()
            }
        }
    }

    ////////////////
}
