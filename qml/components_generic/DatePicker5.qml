import QtQuick 2.15

import Qt.labs.calendar 1.0

import ThemeEngine 1.0

Item {
    id: datePicker
    implicitWidth: 320
    implicitHeight: 480

    ////////////////////////////////////////////////////////////////////////////

    //property var locale: Qt.locale()

    property var today: new Date()
    property bool isToday: false

    property var minDate: null
    property var maxDate: null

    property date initialDate
    property date currentDate

    signal updateDate(var newdate)

    function openDate(date) {
        //console.log("openDate(" + date + ")")
        minDate = null
        maxDate = null

        initialDate = date
        currentDate = date

        today = new Date()
        grid.month = date.getMonth()

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

        isToday = (today.toLocaleString(locale, "dd MMMM yyyy") === currentDate.toLocaleString(locale, "dd MMMM yyyy"))
    }

    Component.onCompleted: {
        openDate(new Date())
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
                text: currentDate.toLocaleString(locale, "MMMM") // "Octobre"
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

            //locale: datePicker.locale

            delegate: Text {
                width: ((grid.width - 8) / 7)
                height: (grid.height / 6)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                opacity: (model.month === grid.month ? 1 : 0.2)
                text: model.day
                font: grid.font
                //font.bold: model.isToday
                color: selected ? "white" : Theme.colorSubText

                property bool selected: (model.day === currentDate.getDate() &&
                                         model.month === currentDate.getMonth() &&
                                         model.year === currentDate.getFullYear())

                Rectangle {
                    z: -1
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width
                    radius: width
                    color: selected ? Theme.colorSecondary : "transparent" //Theme.colorBackground
                    border.color: Theme.colorSecondary
                    border.width: model.isToday ? Theme.componentBorderWidth : 0
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
                            date.setHours(currentDate.getHours(),
                                          currentDate.getMinutes(),
                                          currentDate.getSeconds())
                            currentDate = date
                            updateDate(currentDate)
                        }
                    } else {
                        const diffTime = (today - date)
                        const diffDays = -Math.ceil(diffTime / (1000 * 60 * 60 * 24) - 1)
                        //console.log(diffDays + " days")

                        // validate date (-15 / today)
                        if (diffDays > -15 && diffDays < 1) {
                            date.setHours(currentDate.getHours(),
                                          currentDate.getMinutes(),
                                          currentDate.getSeconds())
                            currentDate = date
                            updateDate(currentDate)
                        }
                    }

                    printDate()
                }
            }
        }

        ////////
    }
}
