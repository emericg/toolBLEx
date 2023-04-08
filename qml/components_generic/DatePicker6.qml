import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: datePicker
    implicitWidth: 320
    implicitHeight: 480

    ////////////////////////////////////////////////////////////////////////////

    //property var locale: Qt.locale()

    property date today: new Date()
    property date initialDate
    property date selectedDate

    property bool isSelectedDateToday: false

    property var minDate: null
    property var maxDate: null

    ////////////////////////////////////////////////////////////////////////////

    signal updateDate(var newdate)

    function openDate(date) {
        //console.log("openDate(" + date + ")")

        today = new Date()
        initialDate = date
        selectedDate = date
        grid.year = date.getFullYear()
        grid.month = date.getMonth()

        minDate = null
        maxDate = null

        printDate()
    }

    function openDate_limits(datetime, min, max) {
        openDate(datetime)

        minDate = min
        maxDate = max
    }

    function printDate() {
        var thismonth = new Date(grid.year, grid.month)
        bigMonth.text = thismonth.toLocaleString(locale, "MMMM")

        if (thismonth.getFullYear() !== today.getFullYear())
            bigMonth.text += " " + thismonth.toLocaleString(locale, "yyyy")

        isSelectedDateToday = (today.toLocaleString(locale, "dd MMMM yyyy") === selectedDate.toLocaleString(locale, "dd MMMM yyyy"))
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: parent

        clip: false
        radius: Theme.componentRadius*2
        color: Theme.colorBackground
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorSeparator

        ////////

        Rectangle {
            id: motw
            anchors.left: parent.left
            anchors.right: parent.right

            z: 3
            height: 48
            radius: Theme.componentRadius*2
            color: Theme.colorSeparator

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: (parent.height / 2)
                color: parent.color
            }

            RoundButtonIcon {
                width: 48; height: 48;
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-chevron_left-24px.svg"

                onClicked: {
                    if (grid.month > 0) {
                        grid.month--
                    } else {
                        grid.month = 11
                        grid.year--
                    }
                    printDate()
                }
            }
            Text {
                id: bigMonth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: selectedDate.toLocaleString(locale, "MMMM") // "Octobre"
                font.capitalization: Font.Capitalize
                font.pixelSize: Theme.fontSizeContentBig
                color: Theme.colorText
            }
            RoundButtonIcon {
                anchors.right: parent.right
                width: 48; height: 48;
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"

                onClicked: {
                    if (grid.month < 11) {
                        grid.month++
                    } else {
                        grid.month = 0
                        grid.year++
                    }
                    printDate()
                }
            }
        }

        ////////

        Rectangle {
            id: dow
            anchors.top: motw.bottom
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentBorderWidth
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentBorderWidth

            z: 2
            height: 48
            color: Qt.lighter(Theme.colorSeparator, 1.1)

            DayOfWeekRow {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter

                Layout.fillWidth: true
                //locale: datePicker.locale

                delegate: Text {
                    anchors.bottom: parent.bottom
                    text: model.shortName.substring(0, 1).toUpperCase()
                    color: Theme.colorText
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        ////////

        MonthGrid {
            id: grid
            anchors.top: dow.bottom
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.bottom: parent.bottom

            Layout.fillWidth: true
            //locale: datePicker.locale

            delegate: Text {
                width: ((grid.width - 8) / 7)
                height: (grid.height / 6)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                property bool isSelected: (model.day === selectedDate.getDate() &&
                                           model.month === selectedDate.getMonth() &&
                                           model.year === selectedDate.getFullYear())

                property bool isToday: (model.day === datePicker.today.getDate() &&
                                        model.month === datePicker.today.getMonth() &&
                                        model.year === datePicker.today.getFullYear())

                text: model.day
                font: grid.font
                //font.bold: isToday
                color: isSelected ? "white" : Theme.colorSubText
                opacity: (model.month === grid.month ? 1 : 0.2)

                Rectangle {
                    z: -1
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width
                    radius: width
                    color: isSelected ? Theme.colorSecondary : "transparent"
                    border.color: Theme.colorSecondary
                    border.width: isToday ? Theme.componentBorderWidth : 0
                }
            }

            onClicked: (date) => {
                if (date.getMonth() === grid.month) {
                    // validate date (min / max)
                    if (minDate && maxDate) {
                        const diffMinTime = (minDate - date)
                        const diffMinDays = -Math.ceil(diffMinTime / (1000 * 60 * 60 * 24) - 1)
                        //console.log(diffMinDays + " diffMinDays")
                        const diffMaxTime = (minDate - date)
                        const diffMaxDays = -Math.ceil(diffMaxTime / (1000 * 60 * 60 * 24) - 1)
                        //console.log(diffMaxDays + " diffMaxDays")

                        if (diffMinDays > -1 && diffMaxDays < 1) {
                            date.setHours(selectedDate.getHours(),
                                          selectedDate.getMinutes(),
                                          selectedDate.getSeconds())
                            selectedDate = date
                            updateDate(selectedDate)
                        }
                    } else {
                        const diffTime = (today - date)
                        const diffDays = -Math.ceil(diffTime / (1000 * 60 * 60 * 24) - 1)
                        //console.log(diffDays + " days")

                        // validate date (-21 / today)
                        if (diffDays > -21 && diffDays < 1) {
                            date.setHours(selectedDate.getHours(),
                                          selectedDate.getMinutes(),
                                          selectedDate.getSeconds())
                            selectedDate = date
                            updateDate(selectedDate)
                        }
                    }

                    printDate()
                }
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
