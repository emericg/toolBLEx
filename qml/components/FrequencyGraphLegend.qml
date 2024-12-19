import QtQuick
import QtCharts

import ComponentLibrary

Item { // legend 2.4 GHz
    id: legend24
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    anchors.left: parent.left
    anchors.leftMargin: UtilsNumber.mapNumber_nocheck(2400,
                                                      ubertooth.freqMin, ubertooth.freqMax,
                                                      0, frequencyGraph.plotArea.width)
    anchors.right: parent.right
    anchors.rightMargin: frequencyGraph.plotArea.width - UtilsNumber.mapNumber_nocheck(2500,
                                                             ubertooth.freqMin, ubertooth.freqMax,
                                                             0, frequencyGraph.plotArea.width)

    ////////////////////////////////////////////////////////////////////////////

    Row { // wifi // 802.11b
        anchors.left: parent.left
        anchors.leftMargin: ((legend24.width / 100) * 1)
        anchors.bottom: parent.bottom
        spacing: -((legend24.width / 100) * 17)

        visible: (actionBar.wifi && actionBar.wifi_b)

        Repeater {
            model: 16

            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: ((legend24.width / 100) * 11)

                width: ((legend24.width / 100) * 22)
                height: ((legend24.width / 100) * 22)
                radius: width

                opacity: 0.66
                color: (index === 13 || index === 14) ? "transparent" : Theme.colorBackground
                border.width: 2
                border.color: {
                    if (index === 13 || index === 14) return Theme.colorBackground
                    if (index === 15) return Theme.colorBlue
                    if ((index % 5) == 0) return Theme.colorRed
                    if ((index % 5) == 1) return Theme.colorOrange
                    if ((index % 5) == 2) return Theme.colorYellow
                    if ((index % 5) == 3) return Theme.colorGreen
                    if ((index % 5) == 4) return Theme.colorBlue
                }

                Text {
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 12
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: {
                        if (index === 15) return "14"
                        return (index + 1)
                    }
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: "white"

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: 4
                        z: -1
                        opacity: 0.66
                        color: parent.parent.border.color
                    }
                }
            }
        }
    }

    Row { // wifi // 802.11g/n
        anchors.left: parent.left
        anchors.leftMargin: ((legend24.width / 100) * 1)
        anchors.bottom: parent.bottom

        height: 400
        spacing: -((legend24.width / 100) * 15)

        visible: (actionBar.wifi && actionBar.wifi_gn)

        Repeater {
            model: 16

            Item {
                anchors.top: parent.top
                anchors.topMargin: {
                    if ((index % 5) === 0) return 12
                    if ((index % 5) === 1) return 72
                    if ((index % 5) === 2) return 132
                    if ((index % 5) === 3) return 192
                    if ((index % 5) === 4) return 252
                }

                width: (legend24.width / 100) * 20
                height: 48

                Rectangle {
                    anchors.fill: parent
                    opacity: (index === 13 || index === 14) ? 0 : 0.2
                    color: Theme.colorYellow
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    text: {
                        if (index === 13 || index === 14) return ""
                        if (index === 15) return "14"
                        return (index + 1)
                    }
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    font.bold: true
                    color: "white"
                }
            }
        }
    }

    Row { // wifi // 802.11n
        anchors.left: parent.left
        anchors.leftMargin: ((legend24.width / 100) * 1)
        anchors.bottom: parent.bottom
        spacing: -(legend24.width / 100) * 17

        visible: (actionBar.wifi && actionBar.wifi_n)
    }

    ////////////////////////////////////////////////////////////////////////////

    Row { // bluetooth // low energy
        anchors.left: parent.left
        anchors.leftMargin: ((legend24.width / 100) * 1.5)
        anchors.bottom: parent.bottom

        visible: (actionBar.bluetooth && actionBar.bluetooth_lowenergy)
        spacing: (legend24.width / 100)

        Repeater {
            model: 40
            Item {
                width: (legend24.width / 100)
                height: 256

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.2
                    color: {
                        if (index === 0 || index === 12 || index === 39) return Theme.colorYellow
                        return Theme.colorBlue
                    }
                }
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    anchors.left:parent.left
                    anchors.leftMargin: 4
                    anchors.right:parent.right
                    anchors.rightMargin: 4

                    visible: (parent.width > 12)

                    text: {
                        if (index === 0) return "37"
                        if (index === 12) return "38"
                        if (index === 39) return "39"
                        if (index < 12) return (index - 1)
                        if (index < 39) return (index - 2)
                        return (1 + index)
                    }
                    textFormat: Text.PlainText
                    fontSizeMode: Text.Fit
                    font.pixelSize: Theme.fontSizeContentSmall
                    minimumPixelSize: Theme.fontSizeContentVeryVerySmall
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
            }
        }
    }

    Row { // bluetooth // classic
        anchors.left: parent.left
        anchors.leftMargin: ((legend24.width / 100) * 1.5)
        anchors.bottom: parent.bottom

        visible: (actionBar.bluetooth && actionBar.bluetooth_classic)
        spacing: 0

        Repeater {
            model: 79
            Item {
                width: (legend24.width / 100)
                height: 256

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.2
                    color: Theme.colorBlue
                    border.width: 1
                    border.color: Theme.colorBackground
                }
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    anchors.left:parent.left
                    anchors.leftMargin: 4
                    anchors.right:parent.right
                    anchors.rightMargin: 4

                    visible: (parent.width > 12)

                    text: (1 + index)
                    textFormat: Text.PlainText
                    fontSizeMode: Text.Fit
                    font.pixelSize: Theme.fontSizeContentSmall
                    minimumPixelSize: Theme.fontSizeContentVeryVerySmall
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row { // zigbee
        anchors.left: parent.left
        anchors.leftMargin: ((legend24.width / 100) * 4)
        anchors.bottom: parent.bottom

        visible: actionBar.zigbee
        spacing: ((legend24.width / 100) * 3)

        Repeater {
            model: 16

            Item {
                width: ((legend24.width / 100) * 2)
                height: 256

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.2
                    color: Theme.colorYellow
                }
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left:parent.left
                    anchors.leftMargin: 4
                    anchors.right:parent.right
                    anchors.rightMargin: 4

                    visible: (parent.width > 16)

                    text: (11 + index)
                    textFormat: Text.PlainText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContent
                    minimumPixelSize: Theme.fontSizeContentSmall
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
