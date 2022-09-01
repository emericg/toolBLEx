import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Loader {
    id: screenBluetooth

    ////////

    function loadScreen() {
        screenBluetooth.active = true
    }

    function unloadScreen() {
        screenBluetooth.active = false
    }

    ////////

    function backAction() {
        if (screenBluetooth.status === Loader.Ready)
            screenBluetooth.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Rectangle {
        anchors.fill: parent
        color: Theme.colorBackground
        z: 10

        function backAction() {
            // no action
        }

        ////////////////////////////////////////////////////////////////////////

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -(appHeader.height / 2)
            spacing: 32

            ////////////////

            Rectangle { // no adapter
                width: screenScanner.width * 0.66
                height: 128
                radius: 4
                color: Theme.colorBox

                visible: !deviceManager.hasAdapters

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
                        color: Theme.colorIcon
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 128
                    anchors.right: parent.right
                    anchors.rightMargin: 128
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("No Bluetooth adapter detected")
                        font.pixelSize: Theme.fontSizeContentVeryVeryBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("Please check if a Bluetooth adapter is connected and configured on your machine.")
                        font.pixelSize: Theme.fontSizeContentBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                }

                Item {
                    anchors.right: parent.right
                    width: 128
                    height: 128

                    ButtonWireframe {
                        anchors.centerIn: parent

                        text: qsTr("Retry")
                        fullColor: true
                        onClicked: deviceManager.enableBluetooth()
                    }
                }
            }

            ////////////////

            Rectangle { // adapter disabled
                width: screenScanner.width * 0.66
                height: 128
                radius: 4
                color: Theme.colorBox

                visible: !deviceManager.btE

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
                        color: Theme.colorIcon
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 128
                    anchors.right: parent.right
                    anchors.rightMargin: 128
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("Bluetooth is disabled")
                        font.pixelSize: Theme.fontSizeContentVeryVeryBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("Please enable Bluetooth on your machine and retry.")
                        font.pixelSize: Theme.fontSizeContentBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                }

                Item {
                    anchors.right: parent.right
                    width: 128
                    height: 128

                    ButtonWireframe {
                        anchors.centerIn: parent

                        text: qsTr("Retry")
                        fullColor: true
                        onClicked: deviceManager.enableBluetooth()
                    }
                }
            }

            ////////////////

            Rectangle { // missing permissions
                width: screenScanner.width * 0.66
                height: 128
                radius: 4
                color: Theme.colorBox

                visible: !deviceManager.btP

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

                        source: "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                        color: Theme.colorIcon
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 128
                    anchors.right: parent.right
                    anchors.rightMargin: 128
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("Bluetooth permissions missing")
                        font.pixelSize: Theme.fontSizeContentVeryVeryBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("Please check if the Bluetooth permissions have been granted to the application.")
                        font.pixelSize: Theme.fontSizeContentBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                }

                Item {
                    anchors.right: parent.right
                    width: 128
                    height: 128

                    ButtonWireframe {
                        anchors.centerIn: parent

                        text: qsTr("Retry")
                        fullColor: true
                        onClicked: deviceManager.enableBluetooth()
                    }
                }
            }
        }
    }
}
