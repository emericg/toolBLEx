import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Rectangle {
    id: errorBar

    implicitWidth: 512

    height: bluetooth ? 0 : 64
    Behavior on height { NumberAnimation { duration: Theme.animationSpeedMedium } }

    clip: true
    color: Theme.colorWarning

    ////

    // Status of the adapter used by the screen, see AdapterManager _scan and _sim properties
    required property bool bluetooth
    required property bool bluetoothAdapter
    required property bool bluetoothEnabled
    property bool bluetoothPermission: AdapterManager.bluetoothPermission

    // Power on the adapter used by the screen, once the permission is granted
    // (granting the permission already powers on the scan adapter)
    signal retry()

    ////

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.componentMargin

        ////

        Item {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64

            IconSvg { // primary
                anchors.centerIn: parent
                width: 48
                height: 48

                color: "white"
                source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"

                IconSvg { // secondary
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -4
                    width: 24
                    height: 24

                    color: "white"
                    source: {
                        if (!errorBar.bluetoothAdapter) return "qrc:/IconLibrary/material-symbols/memory-fill.svg"
                        if (!errorBar.bluetoothEnabled) return "qrc:/IconLibrary/material-symbols/flaky.svg"
                        if (!errorBar.bluetoothPermission) return "qrc:/IconLibrary/material-symbols/lock-fill.svg"
                        return "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        z: -1

                        radius: width
                        color: "grey"
                        opacity: 0.48
                    }
                }
            }
        }

        ////

        Column {
            Layout.fillWidth: true

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: {
                    if (!errorBar.bluetoothAdapter) return qsTr("No Bluetooth adapter detected")
                    if (!errorBar.bluetoothPermission) return qsTr("Bluetooth permission missing")
                    if (!errorBar.bluetooth) return qsTr("Bluetooth is disabled")
                    return "Error..."
                }
                font.pixelSize: Theme.fontSizeContentBig
                font.bold: true
                wrapMode: Text.WordWrap
                color: "white"
                opacity: 1.0
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right

                text: {
                    if (!errorBar.bluetoothAdapter) {
                        return qsTr("Please check if a Bluetooth adapter is connected and configured on your machine.")
                    } else if (!errorBar.bluetoothPermission) {
                        return qsTr("Please check if the Bluetooth permission has been granted to the application.")
                    }
                    return qsTr("Please enable Bluetooth on your machine and retry.")
                }
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
                color: "white"
                opacity: 0.85
            }
        }

        ////

        Row {
            spacing: Theme.componentMargin

            ButtonClear {
                text: qsTr("Retry")
                color: "white"

                onClicked: {
                    if (errorBar.bluetoothPermission) errorBar.retry()
                    else AdapterManager.requestBluetoothPermission(true)
                }
            }
        }

        ////
    }
}
