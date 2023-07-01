import QtQuick
import QtQuick.Controls

import ThemeEngine

Loader {
    id: screenAdvertiser

    ////////

    function loadScreen() {
        screenAdvertiser.active = true
        appContent.state = "Advertiser"
    }

    ////////

    function backAction() {
        if (screenAdvertiser.status === Loader.Ready)
            screenAdvertiser.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

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

            ////////////////

            Rectangle { // not implemented
                width: screenAdvertiser.width * 0.666
                height: 128
                radius: 4

                clip: false
                color: Theme.colorBox
                border.width: 2
                border.color: Theme.colorBoxBorder

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom

                    width: 8
                    radius: 2
                    color: Theme.colorPrimary
                }

                Item {
                    anchors.left: parent.left
                    width: 128
                    height: 128

                    IconSvg {
                        width: 96
                        height: 96
                        anchors.centerIn: parent

                        source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                        color: Theme.colorSubText
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 128
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

            ////////////////
        }
    }
}
