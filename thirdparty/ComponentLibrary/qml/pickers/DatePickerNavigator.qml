import QtQuick

import ComponentLibrary

/*!
 * \brief Month navigation bar for a DatePicker: previous / current month / next.
 *
 * Used inside the DatePicker itself, or outside of it (ex: in a PopupThemed banner area).
 * When the picker allows it (Birthdate mode), the center switches between the days and the year/month views.
 */
Item {
    id: navigator

    implicitWidth: 320
    implicitHeight: Theme.componentHeightXL

    ////////////////

    property var picker: null

    property bool bannerVisible: true
    property color bannerColor: Theme.colorComponentBackground

    ////////////////

    Rectangle { // banner
        anchors.fill: parent
        visible: navigator.bannerVisible
        radius: Theme.componentRadius
        color: navigator.bannerColor
    }

    ////////////////

    SquareButtonSunken { // previous month
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.componentHeightL
        height: Theme.componentHeightL

        visible: navigator.picker !== null && navigator.picker.view === 0
        enabled: navigator.picker !== null && navigator.picker.canGoPrevious
        colorBackground: navigator.bannerColor
        colorHighlight: Theme.colorBackground
        source: "qrc:/IconLibrary/material-symbols/chevron_left.svg"

        onClicked: navigator.picker.previousMonth()
    }

    ////

    Text { // month (+ year when not the current one)
        anchors.centerIn: parent
        visible: navigator.picker !== null && !navigator.picker.monthyearViewEnabled

        text: {
            if (!navigator.picker) return ""
            const d = new Date(navigator.picker.displayedYear, navigator.picker.displayedMonth)
            let txt = d.toLocaleString(navigator.picker.locale, "MMMM")
            if (navigator.picker.displayedYear !== navigator.picker.today.getFullYear())
                txt += " " + navigator.picker.displayedYear
            return txt
        }
        textFormat: Text.PlainText
        font.capitalization: Font.Capitalize
        font.pixelSize: Theme.fontSizeContentBig
        color: Theme.colorText
    }

    ////

    Row { // days / year+month views switch (birthdate mode)
        anchors.centerIn: parent
        spacing: Theme.componentMarginXL
        visible: navigator.picker !== null && navigator.picker.monthyearViewEnabled

        ButtonSunken {
            anchors.verticalCenter: parent.verticalCenter

            text: navigator.picker ? navigator.picker.selectedDate.toLocaleString(navigator.picker.locale, "dd") : ""
            font.pixelSize: Theme.fontSizeContentBig

            colorBackground: (navigator.picker && navigator.picker.view === 0) ? Theme.colorBackground : navigator.bannerColor
            colorHighlight: Theme.colorBackground
            colorBorder: (navigator.picker && navigator.picker.view === 0) ? Theme.colorComponentBorder : colorBackground

            onClicked: navigator.picker.view = 0
        }
        ButtonSunken {
            anchors.verticalCenter: parent.verticalCenter

            text: {
                if (!navigator.picker) return ""
                const d = new Date(navigator.picker.displayedYear, navigator.picker.displayedMonth)
                return d.toLocaleString(navigator.picker.locale, "MMMM yyyy")
            }
            font.capitalization: Font.Capitalize
            font.pixelSize: Theme.fontSizeContentBig

            colorBackground: (navigator.picker && navigator.picker.view === 1) ? Theme.colorBackground : navigator.bannerColor
            colorHighlight: Theme.colorBackground
            colorBorder: (navigator.picker && navigator.picker.view === 1) ? Theme.colorComponentBorder : colorBackground

            onClicked: navigator.picker.view = 1
        }
    }

    ////

    SquareButtonSunken { // next month
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.componentHeightL
        height: Theme.componentHeightL

        visible: navigator.picker !== null && navigator.picker.view === 0
        enabled: navigator.picker !== null && navigator.picker.canGoNext
        colorBackground: navigator.bannerColor
        colorHighlight: Theme.colorBackground
        source: "qrc:/IconLibrary/material-symbols/chevron_right.svg"

        onClicked: navigator.picker.nextMonth()
    }

    ////////////////
}
