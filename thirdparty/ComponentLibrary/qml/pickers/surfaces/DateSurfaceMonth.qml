import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

/*!
 * \brief A month grid (week days header + days), with today and selection highlights.
 *
 * Same contract as the other picker surfaces: state in (for rendering),
 * picked() out, no internal ownership of the state.
 * Days outside of [minDate, maxDate] are dimmed and can't be picked.
 */
ColumnLayout {
    id: root

    spacing: 0

    ////////////////

    property var locale: Qt.locale()

    property int month: 0
    property int year: 2000

    property date today: new Date()
    property date selectedDate
    property var minDate: null
    property var maxDate: null

    // square cells, capped so wide layouts don't get oversized days
    property real cellHeight: Math.min(width / 7, Theme.componentHeightXXL)

    signal picked(date date)

    /*!
     * \brief Tells if a date is within the [minDate, maxDate] bounds, at a day granularity.
     */
    function isSelectable(date) {
        const d = dayValue(date)
        if (minDate && d < dayValue(minDate)) return false
        if (maxDate && d > dayValue(maxDate)) return false
        return true
    }

    /*!
     * \brief Returns the timestamp of a date, truncated to the day.
     */
    function dayValue(date) {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime()
    }

    ////////////////

    DayOfWeekRow {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.componentHeight
        locale: grid.locale

        delegate: Text {
            required property string shortName

            text: shortName.substring(0, 1).toUpperCase()
            textFormat: Text.PlainText
            font.bold: true
            color: Theme.colorText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////

    MonthGrid { // sizes its delegates to its own cells (width / 7, height / 6)
        id: grid
        Layout.fillWidth: true
        Layout.preferredHeight: root.cellHeight * 6

        locale: root.locale
        month: root.month
        year: root.year

        delegate: Text {
            id: dayDelegate

            ////

            required property int day
            required property int month
            required property int year
            required property date date

            property bool isCurrentMonth: (month === grid.month)
            property bool isSelectable: root.isSelectable(date)

            property bool isSelected: (day === root.selectedDate.getDate() &&
                                       month === root.selectedDate.getMonth() &&
                                       year === root.selectedDate.getFullYear())

            property bool isToday: (day === root.today.getDate() &&
                                    month === root.today.getMonth() &&
                                    year === root.today.getFullYear())

            text: day
            textFormat: Text.PlainText
            font: grid.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: isSelected ? "white" : Theme.colorSubText
            opacity: (isCurrentMonth && isSelectable) ? 1 : 0.2

            ////

            Rectangle {
                z: -1
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) - 4
                height: width
                radius: Theme.componentRadius * 2

                color: dayDelegate.isSelected ? Theme.colorSecondary : "transparent"
                opacity: (dayDelegate.isSelected || dayDelegate.isToday) ? 1 : 0.66
                border.color: Theme.colorSecondary
                border.width: {
                    if (dayDelegate.isToday) return Theme.componentBorderWidth
                    if (hover.hovered && dayDelegate.isCurrentMonth && dayDelegate.isSelectable)
                        return Theme.componentBorderWidth
                    return 0
                }
            }

            HoverHandler {
                id: hover
                acceptedDevices: PointerDevice.Mouse
            }

            ////
        }

        onClicked: (date) => {
            if (date.getMonth() === grid.month && root.isSelectable(date)) root.picked(date)
        }
    }

    ////////////////
}
