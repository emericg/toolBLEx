import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

FrameBox {
    width: 720
    height: 128

    highlighted: true
    padding: Theme.componentMarginL

    ////////////////

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.componentMarginL

        ////

        Item {
            Layout.preferredWidth: 96
            Layout.preferredHeight: 128

            IconSvg {
                anchors.centerIn: parent
                width: 96
                height: 96

                source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
                color: Theme.colorIcon
            }
        }

        ////

        Column {
            Layout.fillWidth: true
            spacing: Theme.componentMarginXS

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

        ////

        Row {
            spacing: Theme.componentMargin

            ButtonSolid {
                text: qsTr("Ignore")
                color: Theme.colorSecondary
                onClicked: screenBluetooth.unloadScreen()
            }

            ButtonSolid {
                text: qsTr("Retry")
                onClicked: {
                    deviceManager.requestBluetoothPermission()
                    deviceManager.enableBluetooth()
                }
            }
        }

        ////
    }

    ////////////////
}
