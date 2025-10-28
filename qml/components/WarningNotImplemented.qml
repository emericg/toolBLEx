import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

FrameBox {
    width: 720
    height: 128

    highlighted: true
    padding: 20

    ////////////////

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

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

        ////
    }

    ////////////////
}
