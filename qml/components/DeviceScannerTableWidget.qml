import QtQuick
import Qt.labs.qmlmodels

import ThemeEngine
import DeviceUtils

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

DelegateChooser {
    id: deviceScannerTableWidget

    // (row === devicesView.currentRow) OR row === devicesView.currentRow

    DelegateChoice {
        column: 0

        delegate: Rectangle { // color
            color: {
                if (row === devicesView.currentRow) return Theme.colorLVselected
                if (row % 2 === 1) return Theme.colorLVimpair
                return Theme.colorLVpair
            }

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 24
                radius: 2
                color: pointer.userColor
            }
        }
    }

    DelegateChoice {
        column: 1

        delegate: Text { // address
            rightPadding: 8
            leftPadding: 8

            text: address
            textFormat: Text.PlainText
            font.family: fontMonospace
            color: (row === devicesView.currentRow) ? "white" : Theme.colorText
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle

            Rectangle {
                anchors.fill: parent
                z: -1
                color: {
                    if (row === devicesView.currentRow) return Theme.colorLVselected
                    if (row % 2 === 1) return Theme.colorLVimpair
                    return Theme.colorLVpair
                }
            }
        }
    }

    DelegateChoice {
        column: 2

        delegate: Text { // icons + name
            rightPadding: 8
            leftPadding: 8

            text: name
            textFormat: Text.PlainText
            color: (row === devicesView.currentRow) ? "white" : Theme.colorText
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                z: -1
                color: {
                    if ((row === devicesView.currentRow)) return Theme.colorLVselected
                    if (row === devicesView.currentRow) return Theme.colorLVselected
                    if (row % 2 === 1) return Theme.colorLVimpair
                    return Theme.colorLVpair
                }
            }
        }
    }

    DelegateChoice {
        column: 3

        delegate: Text { // manufacturer
            rightPadding: 8
            leftPadding: 8

            text: manufacturer
            textFormat: Text.PlainText
            color: (row === devicesView.currentRow) ? "white" : Theme.colorText
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                z: -1
                color: {
                    if (row === devicesView.currentRow) return Theme.colorLVselected
                    if (row % 2 === 1) return Theme.colorLVimpair
                    return Theme.colorLVpair
                }
            }
        }
    }

    DelegateChoice {
        column: 4

        delegate: Rectangle { // rssi
            implicitWidth: r.width

            color: {
                if (row === devicesView.currentRow) return Theme.colorLVselected
                if (row % 2 === 1) return Theme.colorLVimpair
                return Theme.colorLVpair
            }

            Row {
                id: r
                anchors.verticalCenter: parent.verticalCenter

                leftPadding: 8
                rightPadding: 8
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "-" + Math.abs(rssi).toFixed(0)
                    textFormat: Text.PlainText
                    color: (row === devicesView.currentRow) ? "white" : Theme.colorText
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "dBm"
                    textFormat: Text.PlainText
                    color: (row === devicesView.currentRow) ? "white" : Theme.colorSubText
                    font.pixelSize: 12
                }

                RssiBar {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 105
                    visible: (rssi !== 0)
                    value: -Math.abs(rssi)
                    value2: -Math.abs(pointer.rssiMax)
                }
            }
        }
    }

    DelegateChoice {
        column: 5

        delegate: Rectangle { // interval
            implicitWidth: rr.width

            color: {
                if (row === devicesView.currentRow) return Theme.colorLVselected
                if (row % 2 === 1) return Theme.colorLVimpair
                return Theme.colorLVpair
            }

            Row {
                id: rr
                anchors.verticalCenter: parent.verticalCenter

                leftPadding: 8
                rightPadding: 8
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: interval
                    textFormat: Text.PlainText
                    color: (row === devicesView.currentRow) ? "white" : Theme.colorText
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: "ms"
                    textFormat: Text.PlainText
                    color: (row === devicesView.currentRow) ? "white" : Theme.colorSubText
                    font.pixelSize: 12
                }
            }
        }
    }

    DelegateChoice {
        column: 6

        delegate: Text { // last seen
            rightPadding: 8
            leftPadding: 8

            text: pointer.lastSeenToday ?
                    pointer.lastSeen.toLocaleTimeString(locale, "hh:mm") :
                    pointer.lastSeen.toLocaleString(locale, "dd/MM hh:mm")
            textFormat: Text.PlainText
            color: (row === devicesView.currentRow) ? "white" : Theme.colorText
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                z: -1
                color: {
                    if (row === devicesView.currentRow) return Theme.colorLVselected
                    if (row % 2 === 1) return Theme.colorLVimpair
                    return Theme.colorLVpair
                }
            }
        }
    }
    DelegateChoice {
        column: 7

        delegate: Text { // first seen
            rightPadding: 8
            leftPadding: 8

            text: pointer.firstSeen.toLocaleString(locale, "dd/MM hh:mm")
            textFormat: Text.PlainText
            color: (row === devicesView.currentRow) ? "white" : Theme.colorText
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                z: -1
                color: {
                    if (row === devicesView.currentRow) return Theme.colorLVselected
                    if (row % 2 === 1) return Theme.colorLVimpair
                    return Theme.colorLVpair
                }
            }
        }
    }
}
