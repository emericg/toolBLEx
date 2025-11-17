import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenBluetooth
    anchors.fill: parent

    ////////////////

    function loadScreen() {
        screenBluetooth.active = true
    }

    function unloadScreen() {
        screenBluetooth.active = false
    }

    function backAction() {
        if (screenBluetooth.status === Loader.Ready)
            screenBluetooth.item.backAction()
    }

    ////////////////

    active: false
    asynchronous: true

    sourceComponent: Rectangle {
        anchors.fill: parent

        color: Theme.colorBackground

        opacity: (screenBluetooth.status === Loader.Ready) ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 233 } }

        function backAction() {
            // no action?
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -(appHeader.height / 2)
            spacing: 32

            ////

            WarningNoAdapter {
                width: screenBluetooth.width * 0.66
                height: 128

                visible: !deviceManager.hasAdapters
            }

            ////

            WarningNoBluetooth {
                width: screenBluetooth.width * 0.66
                height: 128

                visible: (deviceManager.hasAdapters && !deviceManager.bluetooth)
            }

            ////

            WarningNoPermission {
                width: screenBluetooth.width * 0.66
                height: 128

                visible: (deviceManager.hasAdapters && !deviceManager.bluetoothPermission)
            }

            ////
        }
    }

    ////////////////
}
