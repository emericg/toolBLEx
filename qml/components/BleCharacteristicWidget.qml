import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: bleCharacteristicWidget
    height: 128
    width: parent.width
    color: Theme.colorBox

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 18

        width: 2
        height: 128
        color: Theme.colorSubText

        Rectangle {
            anchors.centerIn: parent
            anchors.topMargin: 16
            width: 8; height: 8; radius: 0;
            rotation: 45
            color: Theme.colorSubText
        }
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 32

        spacing: 4

        Text {
            id: characteristicName
            text: modelData.characteristicName
            font.pixelSize: 18
            font.bold: true
            color: Theme.colorSubText
        }
        Row {
            spacing: 4
            Text {
                text: qsTr("UUID:")
                font.pixelSize: 16
                color: Theme.colorSubText
            }
            TextSelectable {
                id: characteristicUuid
                text: modelData.characteristicUuid
                font.pixelSize: 16
                color: Theme.colorText
            }
        }
/*
        Row {
            spacing: 4
            Text {
                text: qsTr("HANDLE:")
                font.pixelSize: 16
                color: Theme.colorSubText
            }
            Text {
                id: characteristicHandle
                text: modelData.characteristicHandle
                font.pixelSize: 16
                color: Theme.colorText
            }
        }
*/
        Row {
            spacing: 4
            Text {
                text: qsTr("Properties:")
                font.pixelSize: 16
                color: Theme.colorSubText
            }
            Text {
                id: characteristicPermission
                text: modelData.characteristicPermission
                font.pixelSize: 16
                color: Theme.colorText
            }
        }
        Row {
            spacing: 4
            Text {
                text: qsTr("Value:")
                font.pixelSize: 16
                color: Theme.colorSubText
            }
            Text {
                id: characteristicValue
                text: modelData.characteristicValue
                font.pixelSize: 16
                color: Theme.colorText
            }
        }
    }

    ////////
/*
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        opacity: 0.1
        color: Theme.colorHeaderContent
    }
*/
}
