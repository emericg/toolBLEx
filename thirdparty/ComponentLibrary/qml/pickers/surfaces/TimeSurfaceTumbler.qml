import QtQuick
import QtQuick.Controls

import ComponentLibrary

/*!
 * \brief Hours and minutes tumblers, with an optional AM/PM tumbler (12h clock).
 *
 * Same contract as the other picker surfaces: state in (for rendering), picked() out.
 * picked() is only emitted from user interaction, never from a model or state change.
 * Hours are always exchanged in 24h format, the 12h display is internal.
 */
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.singleColumn ? 256 : 320

    ////////////////

    property int hours: 0       // 0..23
    property int minutes: 0     // 0..59
    property bool is24Hour: false

    signal picked(int hours, int minutes)

    property bool _syncing: false
    property bool _ready: false
    property int _hoursCount: 0 // model size at last sync, to tell model changes from user input

    /*!
     * \brief Positions the tumblers on the current time, without emitting picked().
     */
    function sync() {
        if (!_ready) return
        _syncing = true
        if (is24Hour) {
            tumblerHours.positionViewAtIndex(hours, Tumbler.Center)
        } else {
            tumblerHours.positionViewAtIndex(hours % 12, Tumbler.Center)
            tumblerAmPm.positionViewAtIndex(hours < 12 ? 0 : 1, Tumbler.Center)
        }
        tumblerMinutes.positionViewAtIndex(minutes, Tumbler.Center)
        _hoursCount = tumblerHours.count
        _syncing = false
    }

    /*!
     * \brief Emits picked() from the tumblers state.
     *
     * 24h: the index is the hour.
     * 12h: index 0..11 maps to 12, 1..11 and PM adds 12 (12 AM = 0h, 12 PM = 12h).
     */
    function emitPicked() {
        if (!_ready || _syncing || !visible) return
        if (tumblerHours.count !== _hoursCount) { Qt.callLater(sync); return } // 12h / 24h switch
        const h = is24Hour ? tumblerHours.currentIndex
                           : tumblerHours.currentIndex + (tumblerAmPm.currentIndex === 1 ? 12 : 0)
        if (h !== hours || tumblerMinutes.currentIndex !== minutes) picked(h, tumblerMinutes.currentIndex)
    }

    onHoursChanged: if (!tumblerHours.moving && !tumblerAmPm.moving) sync()
    onMinutesChanged: if (!tumblerMinutes.moving) sync()
    onVisibleChanged: if (visible) Qt.callLater(sync)
    onIs24HourChanged: Qt.callLater(sync)
    Component.onCompleted: {
        _ready = true
        Qt.callLater(sync) // tumblers content items aren't ready before that
    }

    ////////////////

    Row {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height

        ////////

        TumblerThemed {
            id: tumblerHours
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: parent.height
            font.pixelSize: Theme.fontSizeContentVeryVeryBig
            visibleItemCount: 7

            model: root.is24Hour ? 24 : [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
            onCurrentIndexChanged: root.emitPicked()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: " : "
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVeryVeryBig
            color: Theme.colorText
        }

        TumblerThemed {
            id: tumblerMinutes
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: parent.height
            font.pixelSize: Theme.fontSizeContentVeryVeryBig
            visibleItemCount: 7

            model: 60
            onCurrentIndexChanged: root.emitPicked()
        }

        Item { width: 8; height: 8; visible: !root.is24Hour } // spacer

        TumblerThemed {
            id: tumblerAmPm
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.is24Hour
            width: 64
            height: 128
            font.pixelSize: Theme.fontSizeContentVeryBig
            visibleItemCount: 2
            wrap: false

            model: ["AM", "PM"]
            onCurrentIndexChanged: root.emitPicked()
        }

        ////////
    }

    ////////////////
}
