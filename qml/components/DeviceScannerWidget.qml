import QtQuick
import QtQuick.Layouts

import ThemeEngine 1.0
import DeviceUtils 1.0

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Item {
    id: deviceScannerWidget
    implicitWidth: 720
    implicitHeight: 32

    property var boxDevice: pointer

    property bool isSelected: boxDevice.selected

    property bool showAddress: (Qt.platform.os !== "osx")
    property bool showManufacturer: (Qt.platform.os !== "osx")

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: {
            if (isSelected) return Theme.colorLVselected
            if (index % 2 === 1) return Theme.colorLVimpair
            return Theme.colorLVpair
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onClicked: (mouse) => {
            if (typeof boxDevice === "undefined" || !boxDevice) return

            devicesView.forceActiveFocus()

            if (mouse.button === Qt.LeftButton) {
                // multi selection?
                if ((mouse.modifiers & Qt.ControlModifier)) {
                    return
                }

                // regular click
                if (typeof selectedDevice === "undefined" || !selectedDevice) {
                    //console.log("selecting " + boxDevice.deviceAddress)
                    selectedDevice = boxDevice
                    selectedDevice.selected = true
                } else {
                    if (selectedDevice === boxDevice) {
                        //console.log("DE-selecting " + selectedDevice.deviceAddress)
                        selectedDevice.selected = false
                        selectedDevice = null
                    } else {
                        selectedDevice.selected = false
                        selectedDevice = boxDevice
                        selectedDevice.selected = true
                    }
                }
            }

            if (mouse.button === Qt.MiddleButton) {
               // multi selection?
               return
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16

        opacity: (boxDevice.rssi < 0) ? 1 : 0.4

        ////

        Item { // color
            width: 16; height: 32;

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 24
                radius: 2
                color: boxDevice.userColor
            }
        }

        ////

        Text { // address
            anchors.verticalCenter: parent.verticalCenter
            width: ref.contentWidth

            visible: showAddress

            text: boxDevice.deviceAddress
            textFormat: Text.PlainText
            font.family: fontMonospace
            color: isSelected ? "white" : Theme.colorText
            elide: Text.ElideMiddle

            Text {
                id: ref
                visible: false
                text: (Qt.platform.os === "osx") ?
                          "329562a2-d357-470a-862c-6f6b73397607" :
                          "00:11:22:33:44:55"
                textFormat: Text.PlainText
                font.family: fontMonospace
            }
        }

        ////

        RowLayout { // icons + name
            width: 220
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            IconSvg { // device
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                visible: (source.toString().length)
                source: {
                    if (boxDevice.isBeacon) return "qrc:/assets/icons_bootstrap/tags.svg"
                    if (boxDevice.majorClass) return UtilsBluetooth.getBluetoothMinorClassIcon(boxDevice.majorClass, boxDevice.minorClass)
                    return ""
                }
                opacity: 0.8
                color: isSelected ? "white" : Theme.colorIcon
            }

            Text { // name
                Layout.fillWidth: true

                text: (boxDevice.deviceName.length) ? boxDevice.deviceName : qsTr("Unavailable")
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: {
                    if (isSelected) return "white"
                    if (boxDevice.deviceName.length === 0) return Theme.colorSubText
                    return Theme.colorText
                }
            }

            //IconSvg { // battery
            //    Layout.preferredWidth: 18
            //    Layout.preferredHeight: 20
            //    visible: (boxDevice.hasBattery && boxDevice.deviceBattery >= 0)
            //
            //    source: UtilsDeviceSensors.getDeviceBatteryIcon(boxDevice.deviceBattery)
            //    color: isSelected ? "white" : Theme.colorIcon
            //    rotation: 90
            //    fillMode: Image.PreserveAspectCrop
            //}

            IconSvg { // starred
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignRight
                visible: (boxDevice.isStarred)

                opacity: 0.8
                source: "qrc:/assets/icons_material/baseline-stars-24px.svg"
                color: isSelected ? "white" : Theme.colorIcon
            }
        }

        ////

        Text { // mac vendor
            anchors.verticalCenter: parent.verticalCenter
            width: 220

            visible: showAddress

            text: boxDevice.deviceManufacturer
            textFormat: Text.PlainText
            color: isSelected ? "white" : Theme.colorText
            elide: Text.ElideRight
        }

        ////

        Item { // rssi
            anchors.verticalCenter: parent.verticalCenter
            width: 180
            height: 16

            Row {
                visible: (boxDevice.rssi !== 0)
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32

                    text: "-" + Math.abs(boxDevice.rssi)
                    textFormat: Text.PlainText
                    color: isSelected ? "white" : Theme.colorText
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "dBm"
                    textFormat: Text.PlainText
                    color: isSelected ? "white" : Theme.colorSubText
                    font.pixelSize: 12
                }
            }

            RssiBar {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 105

                visible: (boxDevice.rssi !== 0)
                value: -Math.abs(boxDevice.rssi)
                value2: -Math.abs(boxDevice.rssiMax)
            }
        }

        ////

        Item { // interval
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: 32

            Row {
                anchors.verticalCenter: parent.verticalCenter
                visible: (boxDevice.advInterval !== 0)
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: boxDevice.advInterval
                    textFormat: Text.PlainText
                    color: isSelected ? "white" : Theme.colorText
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: "ms"
                    textFormat: Text.PlainText
                    color: isSelected ? "white" : Theme.colorSubText
                    font.pixelSize: 12
                }
            }
        }

        ////

        Item { // last seen
            width: 120
            height: 32

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: boxDevice.lastSeen.toLocaleTimeString(locale, "hh:mm")
                textFormat: Text.PlainText
                color: isSelected ? "white" : Theme.colorText
            }
        }

        ////

        Item { // first seen
            width: 120
            height: 32

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: boxDevice.firstSeen.toLocaleString(locale, "dd/MM hh:mm")
                textFormat: Text.PlainText
                color: isSelected ? "white" : Theme.colorText
            }
        }

        ////
    }

    ////////////////////////////////////////////////////////////////////////////
}
