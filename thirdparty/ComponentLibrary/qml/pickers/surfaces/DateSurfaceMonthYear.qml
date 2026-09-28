import QtQuick
import QtQuick.Controls

import ComponentLibrary

/*!
 * \brief Month and year tumblers, to quickly jump far away in time.
 *
 * Same contract as the other picker surfaces: state in (for rendering), picked() out.
 * picked() is only emitted from user interaction, never from a model or state change.
 * Years are listed from maxYear down to minYear.
 */
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.componentHeightXL * 7

    ////////////////

    property var locale: Qt.locale()

    property int month: 0
    property int year: 2000

    property int minYear: 1900
    property int maxYear: 2100

    signal picked(int month, int year)

    ////////////////

    property bool _syncing: false
    property bool _ready: false
    property int _yearCount: 0 // model size at last sync, to tell model changes from user input

    /*!
     * \brief Positions the tumblers on the current month and year, without emitting picked().
     */
    function sync() {
        if (!_ready) return
        _syncing = true
        tumblerMonth.positionViewAtIndex(month, Tumbler.Center)
        tumblerYear.positionViewAtIndex(Math.max(0, maxYear - year), Tumbler.Center)
        _yearCount = tumblerYear.count
        _syncing = false
    }

    onMonthChanged: if (!tumblerMonth.moving) sync()
    onVisibleChanged: if (visible) Qt.callLater(sync)
    onYearChanged: if (!tumblerYear.moving) sync()
    onMinYearChanged: Qt.callLater(sync)
    onMaxYearChanged: Qt.callLater(sync)
    Component.onCompleted: {
        _ready = true
        Qt.callLater(sync) // tumblers content items aren't ready before that
    }

    ////////////////

    Row {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        spacing: Theme.componentMarginXL

        ////////

        TumblerThemed {
            id: tumblerMonth
            width: 128
            height: parent.height
            font.pixelSize: Theme.fontSizeContentVeryBig
            visibleItemCount: 7

            model: 12
            delegate: Text {
                required property var modelData
                required property int index

                text: root.locale.standaloneMonthName(modelData)
                textFormat: Text.PlainText
                font.pixelSize: tumblerMonth.font.pixelSize
                font.capitalization: Font.Capitalize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: (tumblerMonth.currentIndex === index) ? Theme.colorPrimary : Theme.colorText
                Behavior on color { ColorAnimation { duration: Theme.animationSpeedFast } }

                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumblerMonth.visibleItemCount / 2)
            }

            onCurrentIndexChanged: {
                if (!root._ready || root._syncing || !root.visible || currentIndex < 0) return
                if (currentIndex !== root.month) root.picked(currentIndex, root.year)
            }
        }

        ////////

        TumblerThemed {
            id: tumblerYear
            width: 128
            height: parent.height
            font.pixelSize: Theme.fontSizeContentVeryBig
            visibleItemCount: 7
            wrap: false

            model: Math.max(1, root.maxYear - root.minYear + 1)
            delegate: Text {
                required property int index

                text: root.maxYear - index
                textFormat: Text.PlainText
                font: tumblerYear.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: (tumblerYear.currentIndex === index) ? Theme.colorPrimary : Theme.colorText
                Behavior on color { ColorAnimation { duration: Theme.animationSpeedFast } }

                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumblerYear.visibleItemCount / 2)
            }

            onCurrentIndexChanged: {
                if (!root._ready || root._syncing || !root.visible || currentIndex < 0) return
                if (count !== root._yearCount) { Qt.callLater(root.sync); return } // years range changed
                if ((root.maxYear - currentIndex) !== root.year) root.picked(root.month, root.maxYear - currentIndex)
            }
        }

        ////////
    }

    ////////////////
}
