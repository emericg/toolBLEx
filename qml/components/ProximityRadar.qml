import QtQuick

import ComponentLibrary

import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Item {
    id: proximityRadar

    clip: true

    Rectangle {
        anchors.centerIn: cc
        width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 1.0) : (parent.height * 1.8)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 0.16
        border.width: 2
        border.color: Theme.colorLowContrast
    }
    Rectangle {
        anchors.centerIn: cc
        width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.75) : (parent.height * 1.33)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 0.33
        border.width: 2
        border.color: Theme.colorLowContrast
    }
    Rectangle {
        anchors.centerIn: cc
        width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.45) : (parent.height *0.75)
        height: width
        radius: width
        color: Theme.colorActionbar
        opacity: 0.6
        border.width: 2
        border.color: Theme.colorLowContrast
    }
    Rectangle {
        anchors.centerIn: cc
        width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.2) : (parent.height * 0.4)
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
            running: (deviceManager.scanning && !deviceManager.scanningPaused && hostMenu.currentSelection === 2)
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

        enabled: (deviceManager.scanning && !deviceManager.scanningPaused && hostMenu.currentSelection === 2)

        model: deviceManager.devicesList
        delegate: Rectangle {
            id: circleDelegate

            property var circleDevice: pointer

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
                if (Math.abs(circleDevice.rssi) < 65) return Theme.colorGreen
                if (Math.abs(circleDevice.rssi) < 85) return Theme.colorOrange
                if (Math.abs(circleDevice.rssi) < 100) return Theme.colorRed
                return Theme.colorRed
            }

            Loader {
                anchors.centerIn: parent

                active: (circleDevice.isStarred || circleDevice.isBeacon || circleDevice.majorClass)
                asynchronous: true

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

            //MouseArea {
            //    anchors.fill: parent
            //    onClicked: circleDelegate.selected = !circleDelegate.selected
            //}
        }
    }
}
