import QtQuick

import ComponentLibrary

/*!
 * \brief An inline date picker, usable in any layout or inside PopupDate / PopupDateTime.
 *
 * Calendar mode shows a month grid, with an optional [minDate, maxDate] range.
 * Birthdate mode adds a year/month tumbler view, and forbids dates after today (unless maxDate is set).
 * Picking a day keeps the time of the current selection.
 * Set a date with loadDate(), and read it back with selectedDate.
 */
Column {
    id: datePicker

    width: 400 // default, Column owns implicitWidth
    spacing: Theme.componentMargin

    ////////////////

    enum Mode {
        Calendar,
        Birthdate
    }
    enum View {
        Days,
        MonthYear
    }

    property var locale: Qt.locale()

    property int mode: DatePicker.Calendar
    property int view: DatePicker.Days
    property bool navigationVisible: true

    property date today: new Date()
    property date initialDate: new Date()
    property date selectedDate: new Date()

    property var minDate: null
    property var maxDate: null
    readonly property var effectiveMaxDate: {
        if (maxDate) return maxDate
        if (mode === DatePicker.Birthdate) return today
        return null
    }

    // month shown by the grid (independent from the selection)
    property int displayedMonth: selectedDate.getMonth()
    property int displayedYear: selectedDate.getFullYear()

    property alias cellHeight: monthSurface.cellHeight
    readonly property bool monthyearViewEnabled: (mode === DatePicker.Birthdate)

    readonly property bool isSelectedDateToday: sameDay(today, selectedDate)

    readonly property bool canGoPrevious: !minDate ||
        (displayedYear * 12 + displayedMonth) > (minDate.getFullYear() * 12 + minDate.getMonth())
    readonly property bool canGoNext: !effectiveMaxDate ||
        (displayedYear * 12 + displayedMonth) < (effectiveMaxDate.getFullYear() * 12 + effectiveMaxDate.getMonth())

    ////////////////

    /*!
     * \brief Loads a date as both the initial (reset target) and the selected date.
     *
     * Also refreshes today, clears the min/max range, and brings the grid to that date.
     * \param date: the date to load.
     */
    function loadDate(date) {
        today = new Date()
        minDate = null
        maxDate = null

        initialDate = date
        selectedDate = date
        showDate(date)
        view = DatePicker.Days
    }

    /*!
     * \brief Loads a date, then constrains the selection to a [min, max] range.
     * \param date: the date to load.
     * \param min, max: the inclusive selectable bounds, null for no bound.
     */
    function loadDateWithLimits(date, min, max) {
        loadDate(date)
        minDate = min
        maxDate = max
    }

    /*!
     * \brief Brings the grid to the month of a date, without changing the selection.
     */
    function showDate(date) {
        displayedMonth = date.getMonth()
        displayedYear = date.getFullYear()
    }

    /*!
     * \brief Selects a date, keeping the time of the current selection.
     * \return true if the date is within bounds and got selected.
     */
    function selectDate(date) {
        if (!monthSurface.isSelectable(date)) return false

        const d = new Date(date)
        d.setHours(selectedDate.getHours(), selectedDate.getMinutes(), selectedDate.getSeconds())
        selectedDate = d
        return true
    }

    /*!
     * \brief Shows the previous month in the grid.
     */
    function previousMonth() {
        if (displayedMonth > 0) displayedMonth--
        else { displayedMonth = 11; displayedYear-- }
    }

    /*!
     * \brief Shows the next month in the grid.
     */
    function nextMonth() {
        if (displayedMonth < 11) displayedMonth++
        else { displayedMonth = 0; displayedYear++ }
    }

    /*!
     * \brief Brings the grid back to the current month.
     */
    function resetView() {
        view = DatePicker.Days
        showDate(today)
    }

    /*!
     * \brief Restores the selection to the loaded date, and shows it.
     */
    function resetDate() {
        selectedDate = initialDate
        showDate(initialDate)
    }

    /*!
     * \brief Tells if two dates are on the same day.
     */
    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
    }

    ////////////////

    DatePickerNavigator {
        width: parent.width
        visible: datePicker.navigationVisible
        picker: datePicker
    }

    ////

    DateSurfaceMonth {
        id: monthSurface
        width: parent.width
        visible: (datePicker.view === DatePicker.Days)

        locale: datePicker.locale
        month: datePicker.displayedMonth
        year: datePicker.displayedYear
        today: datePicker.today
        selectedDate: datePicker.selectedDate
        minDate: datePicker.minDate
        maxDate: datePicker.effectiveMaxDate

        onPicked: (date) => datePicker.selectDate(date)
    }

    ////

    DateSurfaceMonthYear {
        width: parent.width
        height: monthSurface.implicitHeight
        visible: (datePicker.view === DatePicker.MonthYear)

        locale: datePicker.locale
        month: datePicker.displayedMonth
        year: datePicker.displayedYear
        minYear: datePicker.minDate ? datePicker.minDate.getFullYear() : datePicker.today.getFullYear() - 120
        maxYear: datePicker.effectiveMaxDate ? datePicker.effectiveMaxDate.getFullYear() : datePicker.today.getFullYear() + 50

        onPicked: (month, year) => {
            datePicker.displayedMonth = month
            datePicker.displayedYear = year

            // follow in the selection, clamping the day to the new month length
            const d = new Date(datePicker.selectedDate)
            const dim = new Date(year, month + 1, 0).getDate()
            d.setFullYear(year, month, Math.min(d.getDate(), dim))
            datePicker.selectDate(d)
        }
    }

    ////////////////
}
