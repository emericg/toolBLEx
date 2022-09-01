import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: bleServiceWidget
    height: extended ? (80 + characteristicview.count * 150) : 80

    clip: true
    color: Theme.colorBox

    property bool extended: false

    Behavior on height { NumberAnimation { duration: 233 } }

    MouseArea {
        anchors.fill: parent
        onClicked: extended = !extended
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        height: 80
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            spacing: 4

            Item {
                width: parent.width
                height: 32

                Text {
                    id: serviceName
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: modelData.serviceName
                    font.pixelSize: 20
                    font.bold: true
                    color: Theme.colorSubText
                }
                Text {
                    id: serviceType
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: modelData.serviceType
                    font.pixelSize: 14
                    color: Theme.colorSubText
                }
            }
            Row {
                spacing: 4
                Text {
                    text: qsTr("UUID:")
                    font.pixelSize: 16
                    color: Theme.colorSubText
                }
                Text {
                    id: serviceUuid
                    text: modelData.serviceUuid
                    font.pixelSize: 16
                    color: Theme.colorText
                }
            }
        }
    }

    //////////

    ListView {
        id: characteristicview
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.left: parent.left
        anchors.right: parent.right

        //clip: true
        interactive: false
        height: count * 150

        model: modelData.characteristicList
        delegate: BleCharacteristicWidget { }
    }

    ////////

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        opacity: 0.1
        color: Theme.colorHeaderContent
    }
}
