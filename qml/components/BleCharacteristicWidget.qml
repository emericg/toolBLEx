import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: bleCharacteristicWidget
    width: 512
    height: col.height + 16
    color: Theme.colorBox

    ////////////////

    Rectangle {
        anchors.top: col.top
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.bottom: col.bottom
        width: 2
        height: 128
        color: Theme.colorSubText
    }

    ////////////////

    Column {
        id: col
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -8

        spacing: 4

        Text {
            id: characteristicName
            text: modelData.characteristicName
            font.pixelSize: Theme.fontSizeContentBig
            font.bold: true
            color: Theme.colorSubText
        }

        Row {
            spacing: 4

            Text {
                text: qsTr("UUID:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TextSelectable {
                id: characteristicUuid
                text: modelData.characteristicUuid
                font.pixelSize: Theme.fontSizeContent
                //font.capitalization: Font.AllUppercase
                color: Theme.colorText
            }
        }
/*
        Row {
            spacing: 4

            Text {
                text: qsTr("HANDLE:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                id: characteristicHandle
                text: modelData.characteristicHandle
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }
*/
        Row {
            spacing: 4

            Text {
                text: qsTr("Properties:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                id: characteristicPermission
                text: modelData.characteristicPermission
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        Row {
            spacing: 4

            Text {
                text: qsTr("Value:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                id: characteristicValue
                text: modelData.characteristicValue
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }
    }

    ////////////////
}
