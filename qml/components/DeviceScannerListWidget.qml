import QtQuick
import QtQuick.Layouts

import ComponentLibrary
import DeviceUtils

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Item {
    id: deviceScannerListWidget

    implicitWidth: 800
    implicitHeight: 32

    width: deviceManager.deviceHeader.width

    property var boxDevice: pointer

    property bool showAddress: (Qt.platform.os !== "osx")

    ////////

    Rectangle { // background
        anchors.fill: parent
        color: {
            if (boxDevice.selected && !boxDevice.connected) {
                return Theme.colorLVselected
            }
            if (boxDevice.selected && boxDevice.connected) {
                if (Theme.currentTheme === Theme.THEME_DESKTOP_LIGHT)
                    return Theme.colorMaterialTeal
                if (Theme.currentTheme === Theme.THEME_DESKTOP_DARK)
                    return Theme.colorMaterialPurple
            }
            if (boxDevice.connected) {
                if (Theme.currentTheme === Theme.THEME_DESKTOP_LIGHT)
                    return Qt.lighter(Theme.colorGreen, 1.1)
                if (Theme.currentTheme === Theme.THEME_DESKTOP_DARK)
                    return Qt.darker(Theme.colorGreen, 1.1)
            }
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

    ////////

    Row { // content
        anchors.left: parent.left
        anchors.leftMargin: deviceManager.deviceHeader.margin
        anchors.right: parent.right
        anchors.rightMargin: deviceManager.deviceHeader.margin
        anchors.verticalCenter: parent.verticalCenter
        spacing: deviceManager.deviceHeader.spacing

        opacity: (boxDevice.connected || boxDevice.selected || boxDevice.rssi < 0) ? 1 : 0.4

        Item { // color ////////////////////////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colColor
            height: 32

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 24
                radius: 2
                color: boxDevice.userColor
            }
        }

        Text { // address //////////////////////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colAddress

            visible: showAddress

            text: boxDevice.deviceAddress
            textFormat: Text.PlainText
            font.family: fontMonospace
            color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorText
            elide: Text.ElideMiddle
        }

        RowLayout { // icons + name ////////////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colName
            height: 32
            spacing: 8

            IconSvg { // device
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                visible: (source.toString().length)
                source: {
                    if (boxDevice.isBeacon) return "qrc:/IconLibrary/bootstrap/tags.svg"
                    if (boxDevice.majorClass) return UtilsBluetooth.getBluetoothMinorClassIcon(boxDevice.majorClass, boxDevice.minorClass)
                    return ""
                }
                opacity: 0.8
                color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorIcon
            }

            Text { // name
                Layout.fillWidth: true

                text: (boxDevice.deviceName.length) ? boxDevice.deviceName_display : qsTr("Unavailable")
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: {
                    if (boxDevice.connected || boxDevice.selected) return "white"
                    if (boxDevice.deviceName.length === 0) return Theme.colorSubText
                    return Theme.colorText
                }
            }

            Row { // status icons
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignRight
                opacity: 0.8

                //IconSvg { // battery
                //    Layout.preferredWidth: 18
                //    Layout.preferredHeight: 20
                //    visible: (boxDevice.hasBattery && boxDevice.deviceBattery >= 0)
                //
                //    source: UtilsDeviceSensors.getDeviceBatteryIcon(boxDevice.deviceBattery)
                //    color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorIcon
                //    rotation: 90
                //    fillMode: Image.PreserveAspectCrop
                //}

                IconSvg { // connected
                    width: 20
                    height: 20
                    visible: (boxDevice.connected)

                    source: "qrc:/IconLibrary/material-icons/duotone/bluetooth_connected.svg"
                    color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorIcon
                }

                IconSvg { // starred
                    width: 20
                    height: 20
                    visible: (boxDevice.isStarred)

                    source: "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                    color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorIcon
                }

                IconSvg { // paired
                    width: 20
                    height: 20
                    visible: (boxDevice.isPaired)

                    source: "qrc:/IconLibrary/material-symbols/link.svg"
                    color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorIcon
                }
            }
        }

        Text { // mac vendor ///////////////////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colManuf

            visible: showAddress

            text: boxDevice.deviceManufacturer
            textFormat: Text.PlainText
            color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorText
            elide: Text.ElideRight
        }

        RowLayout { // rssi ////////////////////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colRssi
            clip: true

            Item { // fake item so the RowLayout doesn't have a null width when the content is invisible
                width: deviceManager.deviceHeader.colRssi
                height: 32
                visible: (boxDevice.rssi === 0)
            }

            Row {
                visible: (boxDevice.rssi !== 0)
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32

                    text: "-" + Math.abs(boxDevice.rssi)
                    textFormat: Text.PlainText
                    color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorText
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("dBm")
                    textFormat: Text.PlainText
                    color: (boxDevice.connected || boxDevice.selected) ? "#ddd" : Theme.colorSubText
                    font.pixelSize: 12
                }
            }

            RssiBar {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight

                visible: (boxDevice.rssi !== 0)
                value: -Math.abs(boxDevice.rssi)
                value2: -Math.abs(boxDevice.rssiMax)
            }
        }

        Item { // interval /////////////////////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colInterval
            height: 32
            clip: true

            Row {
                anchors.verticalCenter: parent.verticalCenter
                visible: (boxDevice.advInterval !== 0)
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: boxDevice.advInterval
                    textFormat: Text.PlainText
                    color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorText
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("ms")
                    textFormat: Text.PlainText
                    color: (boxDevice.connected || boxDevice.selected) ? "#ddd" : Theme.colorSubText
                    font.pixelSize: 12
                }
            }
        }

        Item { // last seen ////////////////////////////////////////////////////
            width: deviceManager.deviceHeader.colLastSeen
            height: 32

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: boxDevice.lastSeenToday ?
                          boxDevice.lastSeen.toLocaleTimeString(locale, "hh:mm") :
                          boxDevice.lastSeen.toLocaleString(locale, "dd/MM hh:mm")
                textFormat: Text.PlainText
                color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorText
            }
        }

        Item { // first seen ///////////////////////////////////////////////////
            width: deviceManager.deviceHeader.colFirstSeen
            height: 32

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: boxDevice.firstSeen.toLocaleString(locale, "dd/MM hh:mm")
                textFormat: Text.PlainText
                color: (boxDevice.connected || boxDevice.selected) ? "white" : Theme.colorText
            }
        }
    }

    ////////
}
