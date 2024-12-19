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

        ////////////////////////////////////////////////////////////////////////

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -(appHeader.height / 2)
            spacing: 32

            ////////

            FrameBox { // not implemented
                width: screenAdvertiser.width * 0.666

                highlighted: true

                Item {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 128
                    height: 128

                    IconSvg {
                        width: 96
                        height: 96
                        anchors.centerIn: parent

                        source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
                        color: Theme.colorSubText
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 128+16
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("This screen is not implemented (yet)")
                        font.pixelSize: Theme.fontSizeContentVeryVeryBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("This is a BLE device emulator. You can broadcast Bluetooth Low Energy Advertisement virtual packets, and create virtual services and associated values.")
                        font.pixelSize: Theme.fontSizeContentBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                }
            }

            ////////
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
