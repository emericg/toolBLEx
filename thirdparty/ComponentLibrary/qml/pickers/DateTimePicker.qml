import QtQuick

import ComponentLibrary

/*!
 * \brief An inline date + time picker, combining a DatePicker and a TimePicker.
 *
 * Both pickers work on the same value: selectedDateTime.
 * A selector switches between the date and time pages, unless selectorVisible is false,
 * in which case the owner drives `page` (ex: PopupDateTime puts the selector in its banner).
 * Set a value with loadDateTime(), and read it back with selectedDateTime.
 */
Column {
    id: dateTimePicker

    width: 400 // default, Column owns implicitWidth
    spacing: Theme.componentMargin

    ////////////////

    enum Mode {
        Date,
        Time
    }

    property int page: DateTimePicker.Date

    property var locale: Qt.locale()

    property bool selectorVisible: true

    property alias datePicker: pickerDate
    property alias timePicker: pickerTime
    property alias is24Hour: pickerTime.is24Hour
    property alias cellHeight: pickerDate.cellHeight

    ////////////////

    property date initialDateTime: new Date()
    property date selectedDateTime: new Date()

    /*!
     * \brief Loads a value as both the initial (reset target) and the selected date and time.
     */
    function loadDateTime(datetime) {
        _syncing = true
        initialDateTime = datetime
        selectedDateTime = datetime
        pickerDate.loadDate(datetime)
        pickerTime.loadTime(datetime)
        page = DateTimePicker.Date
        _syncing = false
    }

    /*!
     * \brief Loads a value, then constrains the date to a [min, max] range.
     */
    function loadDateTimeWithLimits(datetime, min, max) {
        loadDateTime(datetime)
        pickerDate.minDate = min
        pickerDate.maxDate = max
    }

    /*!
     * \brief Restores the selection to the loaded date and time.
     */
    function resetDateTime() {
        loadDateTime(initialDateTime)
    }

    ////////////////

    property bool _syncing: false

    /*!
     * \brief Merges the date part of one value with the time part of another.
     */
    function merge(datePart, timePart) {
        const d = new Date(datePart)
        d.setHours(timePart.getHours(), timePart.getMinutes(), timePart.getSeconds())
        return d
    }

    ////////////////

    SelectorMenuColorful {
        anchors.horizontalCenter: parent.horizontalCenter
        height: Theme.componentHeight
        visible: dateTimePicker.selectorVisible

        currentSelection: dateTimePicker.page
        model: ListModel {
            ListElement { idx: DateTimePicker.Date; txt: qsTr("Date"); src: ""; sz: 0; }
            ListElement { idx: DateTimePicker.Time; txt: qsTr("Time"); src: ""; sz: 0; }
        }
        onMenuSelected: (index) => { dateTimePicker.page = index }
    }

    ////////////////

    DatePicker {
        id: pickerDate
        width: parent.width
        visible: (dateTimePicker.page === DateTimePicker.Date)
        locale: dateTimePicker.locale

        onSelectedDateChanged: {
            if (dateTimePicker._syncing) return
            dateTimePicker.selectedDateTime = dateTimePicker.merge(selectedDate, pickerTime.selectedTime)
        }
    }

    ////

    TimePicker {
        id: pickerTime
        width: parent.width
        visible: (dateTimePicker.page === DateTimePicker.Time)

        onSelectedTimeChanged: {
            if (dateTimePicker._syncing) return
            dateTimePicker.selectedDateTime = dateTimePicker.merge(pickerDate.selectedDate, selectedTime)
        }
    }

    ////////////////
}
