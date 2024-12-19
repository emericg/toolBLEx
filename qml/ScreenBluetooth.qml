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

    onStatusChanged: if (screenBluetooth.status === Loader.Ready) screenBluetooth.item.opacity = 1

    sourceComponent: Rectangle {
        anchors.fill: parent

        color: Theme.colorBackground

        opacity: 0
        Behavior on opacity { OpacityAnimator { duration: 233 } }

        function backAction() {
            // no action?
        }

        ////////////////////////////////////////////////////////////////////////

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -(appHeader.height / 2)
            spacing: 32

            ////////////////

            Rectangle { // no adapter
                width: screenBluetooth.width * 0.66
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

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    Item {
                        Layout.preferredWidth: 128
                        Layout.preferredHeight: 128

                        IconSvg {
                            width: 96
                            height: 96
                            anchors.centerIn: parent

                            source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
                            color: Theme.colorIcon
                        }
                    }

                    Column {
                        Layout.fillWidth: true
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

                    Row {
                        spacing: 16

                        ButtonSolid {
                            text: qsTr("Ignore")
                            color: Theme.colorSecondary
                            onClicked: screenBluetooth.unloadScreen()
                        }

                        ButtonSolid {
                            text: qsTr("Retry")
                            onClicked: deviceManager.enableBluetooth()
                        }
                    }
                }
            }

            ////////////////

            Rectangle { // adapter disabled
                width: screenBluetooth.width * 0.66
                height: 128
                radius: 4
                color: Theme.colorBox

                visible: (deviceManager.hasAdapters && !deviceManager.bluetooth)

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

                        source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
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

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    ButtonSolid {
                        text: qsTr("Ignore")
                        color: Theme.colorSecondary
                        onClicked: screenBluetooth.unloadScreen()
                    }

                    ButtonSolid {
                        text: qsTr("Retry")
                        onClicked: deviceManager.enableBluetooth()
                    }
                }
            }

            ////////////////

            Rectangle { // missing permissions
                width: screenBluetooth.width * 0.66
                height: 128
                radius: 4
                color: Theme.colorBox

                visible: (deviceManager.hasAdapters && !deviceManager.bluetoothPermissions)

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

                        source: "qrc:/IconLibrary/material-icons/duotone/settings_bluetooth.svg"
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

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    ButtonSolid {
                        text: qsTr("Ignore")
                        color: Theme.colorSecondary
                        onClicked: screenBluetooth.unloadScreen()
                    }

                    ButtonSolid {
                        text: qsTr("Retry")
                        onClicked: deviceManager.enableBluetooth()
                    }
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
