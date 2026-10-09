import QtQuick
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenSimulator

    ////////////////

    function loadScreen() {
        screenSimulator.active = true
        appContent.state = "Simulator"
    }

    function backAction() {
        if (screenSimulator.status === Loader.Ready)
            screenSimulator.item.backAction()
    }

    ////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        function backAction() {
            screenScanner.loadScreen()
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -(appHeader.height / 2)
            spacing: 32

            ////

            WarningNotImplemented {
                width: screenSimulator.width * 0.666
                visible: true
            }

            ////
        }

        ErrorBanner {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            bluetooth: AdapterManager.bluetooth_sim
            bluetoothAdapter: AdapterManager.bluetoothAdapter_sim
            bluetoothEnabled: AdapterManager.bluetoothEnabled_sim
            onRetry: AdapterManager.enableBluetooth_sim()
        }
    }

    ////////////////
}
