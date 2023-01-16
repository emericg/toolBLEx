import QtQuick
import QtQuick.Layouts

import ThemeEngine 1.0

Rectangle {
    id: bleCharacteristicWidget
    width: 512
    height: col.height + 16
    color: Theme.colorBox

    property string uuiidd: modelData.uuid_full

    ////////////////

    Loader {
        id: popupLoader

        active: false
        asynchronous: false
        sourceComponent: PopupWriteCharacteristic {
            id: popupWriteCharacteristic
            parent: appContent

            onConfirmed: {
                //selectedDevice.askForWrite(bleCharacteristicWidget.uuiidd, "wat")
            }
        }
    }

    ////////////////

    Rectangle {
        anchors.top: col.top
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.bottom: col.bottom
        width: 2
        height: 128
        color: Theme.colorSubText
        opacity: 0.8
    }

    ////////////////

    Column {
        id: col
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -8
        spacing: 4

        ////////

        Text { // characteristic name
            text: modelData.name
            font.pixelSize: Theme.fontSizeContentBig
            font.bold: true
            color: Theme.colorText
        }

        ////////

        Row {
            spacing: 4

            Text {
                text: qsTr("UUID:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TextSelectable { // characteristic uuid
                text: modelData.uuid_full
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        ////////

        Row {
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Properties:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Repeater { // characteristic properties
                anchors.verticalCenter: parent.verticalCenter
                model: modelData.propertiesList
                ItemActionTag {
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: (selectedDevice && selectedDevice.servicesScanMode > 1)
                    text: modelData
                    onClicked: {
                        if (selectedDevice && selectedDevice.servicesScanMode > 1) {
                            if (text === "Notify") {
                                selectedDevice.askForNotify(bleCharacteristicWidget.uuiidd)
                            }
                            if (text === "Read") {
                                selectedDevice.askForRead(bleCharacteristicWidget.uuiidd)
                            }
                            if (text === "Write" || text === "WriteNoResp") {
                                popupLoader.active = true
                                popupLoader.item.openU(bleCharacteristicWidget.uuiidd)
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            Text {
                id: t1
                Layout.alignment: Qt.AlignTop

                text: qsTr("Value:")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                Layout.alignment: Qt.AlignTop

                text: "0x"
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TextSelectable {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignBaseline

                text: modelData.valueHex
                font.pixelSize: Theme.fontSizeContent
                font.family: fontMonospace
                wrapMode: Text.WrapAnywhere
                color: Theme.colorText
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            visible: modelData.valueStr.length

            Text {
                id: t2
                Layout.alignment: Qt.AlignTop

                text: qsTr("Value:")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TextSelectable {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignBaseline

                text: modelData.valueStr
                color: Theme.colorText
                wrapMode: Text.WrapAnywhere
            }
        }
    }

    ////////////////
}
