import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Item {
    id: proximityRadar

    clip: true

    property var hoveredDevice: null
    property var pinnedDevice: null
    property var bannerDevice: hoveredDevice ?? pinnedDevice

    Rectangle {
        anchors.centerIn: cc
        width: (SettingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 1.0) : (parent.height * 1.8)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 0.16
        border.width: 2
        border.color: Theme.colorLowContrast
    }
    Rectangle {
        anchors.centerIn: cc
        width: (SettingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.75) : (parent.height * 1.33)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 0.33
        border.width: 2
        border.color: Theme.colorLowContrast
    }
    Rectangle {
        anchors.centerIn: cc
        width: (SettingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.45) : (parent.height *0.75)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 0.6
        border.width: 2
        border.color: Theme.colorLowContrast
    }
    Rectangle {
        anchors.centerIn: cc
        width: (SettingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.2) : (parent.height * 0.4)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 1.0
        border.width: 2
        border.color: Theme.colorLowContrast
    }

    Rectangle {
        id: ra
        anchors.centerIn: cc
        width: 0
        height: width
        radius: width
        color: Theme.colorSeparator

        ParallelAnimation {
            alwaysRunToEnd: true
            loops: Animation.Infinite
            running: (deviceManager.scanning && !deviceManager.scanningPaused && hostMenu.currentIndex === 1)
            NumberAnimation { target: ra; property: "width"; from: 0; to: proximityRadar.width*3; duration: 2500; }
            NumberAnimation { target: ra; property: "opacity"; from: 0.85; to: 0; duration: 2500; }
        }
    }

    Rectangle {
        id: cc
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.bottom
        anchors.verticalCenterOffset: -40
        width: 80
        height: 80
        radius: 80
        color: Theme.colorBackground
        border.width: 2
        border.color: Theme.colorSeparator

        IconSvg {
            anchors.centerIn: parent
            source: "qrc:/IconLibrary/material-icons/duotone/devices.svg"
            color: Theme.colorIcon
        }
    }

    ////////

    Repeater {
        anchors.fill: parent
        anchors.margins: 24

        enabled: (deviceManager.scanning && !deviceManager.scanningPaused && hostMenu.currentIndex === 1)

        model: deviceManager.devicesList
        delegate: Rectangle {
            id: circleDelegate

            property var circleDevice: pointer

            property bool hovered: (proximityRadar.hoveredDevice === circleDevice)
            property bool pinned: (proximityRadar.pinnedDevice === circleDevice)

            property real alpha: Math.random() * (3.14/2) + (3.14/4)
            property real a: c * Math.cos(alpha)
            property real b: c * Math.sin(alpha)
            property real c: proximityRadar.height * Math.abs(((circleDevice.rssi)+12) / 100)

            x: (proximityRadar.width / 2) - a
            y: proximityRadar.height - b

            width: 32
            height: 32
            radius: 32

            opacity: (circleDevice.rssi < 0) ? 1 : 0.66
            visible: (circleDevice.rssi !== 0)

            border.width: circleDevice.selected ? 6 : 2
            border.color: circleDevice.selected ? Theme.colorSecondary : Qt.darker(color, 1.2)

            color: {
                if (circleDelegate.pinned) return Theme.colorPrimary
                if (Math.abs(circleDevice.rssi) < 65) return Theme.colorGreen
                if (Math.abs(circleDevice.rssi) < 85) return Theme.colorOrange
                if (Math.abs(circleDevice.rssi) < 100) return Theme.colorRed
                return Theme.colorRed
            }

            ////

            Loader {
                anchors.centerIn: parent

                active: (circleDevice.isStarred || circleDevice.isBeacon || circleDevice.majorClass)
                asynchronous: false

                sourceComponent: IconSvg {
                    anchors.centerIn: parent
                    width: (circleDevice.isStarred) ? 32 : 20
                    height: width
                    opacity: 0.66
                    color: "white"
                    source: {
                        if (circleDevice.isStarred) return "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                        if (circleDevice.isBeacon) return "qrc:/IconLibrary/bootstrap/tags.svg"
                        if (circleDevice.majorClass) return UtilsBluetooth.getBluetoothMinorClassIcon(circleDevice.majorClass, circleDevice.minorClass)
                        return ""
                    }
                }
            }

            ////

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onContainsMouseChanged: {
                    if (containsMouse) proximityRadar.hoveredDevice = circleDelegate.circleDevice
                    else if (proximityRadar.hoveredDevice === circleDelegate.circleDevice) proximityRadar.hoveredDevice = null
                }
                onClicked: {
                    proximityRadar.pinnedDevice = (proximityRadar.pinnedDevice === circleDelegate.circleDevice) ? null : circleDelegate.circleDevice
                }
            }

            Component.onDestruction: {
                if (circleDelegate.hovered) proximityRadar.hoveredDevice = null
                if (circleDelegate.pinned) proximityRadar.pinnedDevice = null
            }

            ////
        }
    }

    ////////

    Rectangle {
        id: banner
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 36
        color: Theme.colorBox

        opacity: proximityRadar.bannerDevice ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 133 } }

        property var device: null
        Connections {
            target: proximityRadar
            function onBannerDeviceChanged() {
                if (proximityRadar.bannerDevice) banner.device = proximityRadar.bannerDevice
            }
        }

        RowLayout {
            id: bannerColumn
            anchors.fill: parent
            anchors.leftMargin: Theme.componentMargin
            anchors.rightMargin: Theme.componentMarginS
            spacing: Theme.componentMargin

            Text {
                Layout.maximumWidth: implicitWidth
                Layout.fillWidth: true
                text: (banner.device && banner.device.deviceName.length) ? banner.device.deviceName_display : qsTr("Unavailable")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                font.bold: true
                color: Theme.colorText
                elide: Text.ElideRight
            }
            Text {
                text: banner.device ? banner.device.deviceAddress : ""
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
            }

            RssiBar {
                Layout.fillWidth: true
                Layout.minimumWidth: 64
                Layout.maximumWidth: 200

                visible: (banner.device && banner.device.rssi !== 0)
                value: banner.device ? -Math.abs(banner.device.rssi) : 0
                value_max: banner.device ? -Math.abs(banner.device.rssiMax) : 0
            }

            Item { Layout.fillWidth: true }

            RoundButtonSunken {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                visible: (proximityRadar.pinnedDevice !== null)
                source: "qrc:/IconLibrary/material-symbols/close.svg"
                colorBackground: banner.color
                colorIcon: Theme.colorSubText

                onClicked: {
                    proximityRadar.pinnedDevice = null
                    proximityRadar.hoveredDevice = null
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: Theme.colorSeparator
        }
    }

    ////////
}
