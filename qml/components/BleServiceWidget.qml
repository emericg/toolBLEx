import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Rectangle {
    id: bleServiceWidget

    //height: extended ? (80 + characteristicview.count * 150) : 80
    height: extended ? (80 + characteristicview.contentHeight) : 80
    Behavior on height { NumberAnimation { duration: 233 } }

    color: Theme.colorBox
    clip: true

    //////////

    property bool extended: false

    MouseArea {
        anchors.fill: parent
        onClicked: extended = !extended
    }

    //////////

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

                Text { // serviceName
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: modelData.serviceName
                    font.pixelSize: 20
                    font.bold: true
                    color: Theme.colorSubText
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text { // serviceType
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.serviceType
                        font.pixelSize: 14
                        color: Theme.colorSubText
                    }
                    IconSvg { // expandIcon
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorSubText
                        source: bleServiceWidget.extended ?
                                    "qrc:/assets/icons_material/baseline-unfold_less-24px.svg" :
                                    "qrc:/assets/icons_material/baseline-unfold_more-24px.svg"
                    }
                }
            }

            Row {
                spacing: 4
                Text {
                    text: qsTr("UUID:")
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
                TextSelectable {
                    id: serviceUuid
                    text: modelData.serviceUuidFull
                    font.pixelSize: Theme.fontSizeContent
                    //font.capitalization: Font.AllUppercase
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
        anchors.bottom: parent.bottom

        interactive: false

        model: modelData.characteristicList
        delegate: BleCharacteristicWidget {
            width: parent.width
        }
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
