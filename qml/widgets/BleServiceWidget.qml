import QtQuick
import QtQuick.Controls

import ComponentLibrary

Rectangle {
    id: bleServiceWidget

    property bool extended: false

    height: extended ? (servicewiew.height + characteristicview.contentHeight) : servicewiew.height
    Behavior on height { NumberAnimation { duration: 233 } }

    clip: true
    color: Theme.colorBox

    //////////

    Item {
        id: servicewiew
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 88

        MouseArea {
            anchors.fill: parent
            onClicked: bleServiceWidget.extended = !bleServiceWidget.extended
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            spacing: 4

            Item {
                width: parent.width
                height: serviceName.height

                Text {
                    id: serviceName
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: modelData.serviceName
                    font.pixelSize: Theme.fontSizeContentVeryBig
                    font.bold: true
                    color: Theme.colorText
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    TagClear { // serviceType
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.serviceType
                    }
                    TagClear { // serviceStatus
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.serviceStatusStr
                    }

                    IconSvg { // expandIcon
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: bleServiceWidget.extended ?
                                    "qrc:/IconLibrary/material-symbols/unfold_less.svg" :
                                    "qrc:/IconLibrary/material-symbols/unfold_more.svg"
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
                    text: modelData.serviceUuid
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
        anchors.topMargin: servicewiew.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        interactive: false

        model: modelData.characteristicList
        delegate: BleCharacteristicWidget {
            width: characteristicview.width
            //editable: (modelData.serviceStatus === 3)
        }
    }

    ////////

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        opacity: 0.1
        color: Theme.colorHeaderContent
    }
}
