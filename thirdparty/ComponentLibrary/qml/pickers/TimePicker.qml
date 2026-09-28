import QtQuick

import ComponentLibrary

/*!
 * \brief An inline time picker, usable in any layout or inside PopupTime / PopupDateTime.
 *
 * Picking a time keeps the date of the current selection.
 * Set a time with loadTime(), and read it back with selectedTime.
 */
Column {
    id: timePicker

    width: 320

    // 12h (with AM/PM) or 24h clock toggle
    property bool is24Hour: false

    ////////////////

    property date initialTime: new Date()
    property date selectedTime: new Date()

    /*!
     * \brief Loads a time as both the initial (reset target) and the selected time.
     */
    function loadTime(time) {
        initialTime = time
        selectedTime = time
    }

    /*!
     * \brief Selects a time, keeping the date (and seconds) of the current selection.
     */
    function selectTime(hours, minutes) {
        const d = new Date(selectedTime)
        d.setHours(hours, minutes)
        selectedTime = d
    }

    /*!
     * \brief Restores the selection to the loaded time.
     */
    function resetTime() {
        selectedTime = initialTime
    }

    ////////////////

    TimeSurfaceTumbler {
        width: parent.width

        hours: timePicker.selectedTime.getHours()
        minutes: timePicker.selectedTime.getMinutes()
        is24Hour: timePicker.is24Hour

        onPicked: (h, m) => timePicker.selectTime(h, m)
    }

    ////////////////
}
