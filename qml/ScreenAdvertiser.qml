import QtQuick
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenAdvertiser

    ////////////////

    function loadScreen() {
        screenAdvertiser.active = true
        appContent.state = "Advertiser"
    }

    function backAction() {
        if (screenAdvertiser.status === Loader.Ready)
            screenAdvertiser.item.backAction()
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
                width: screenAdvertiser.width * 0.666
                visible: true
            }

            ////
        }
    }

    ////////////////
}
