import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: adapterWidget
    height: col.height + 24
    radius: 4
    color: Theme.colorBox
    clip: true

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 8
        radius: 2
        color: Theme.colorPrimary
        visible: modelData.isDefault
    }

    IconSvg {
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        width: 64
        height: 64

        visible: (adapterWidget.width > col.legendWidth*2.5)

        source: "qrc:/assets/icons_bootstrap/bluetooth.svg"
        color: Theme.colorIcon
    }

    Column {
        id: col
        anchors.verticalCenter: parent.verticalCenter

        property int legendWidth: 180

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 32

            text: qsTr("Bluetooth adapter #%1").arg(index+1)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.colorText
        }

        Row {
            height: 32
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: col.legendWidth

                text: qsTr("Hostname")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.hostname
            }
        }

        Row {
            height: 32
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: col.legendWidth

                text: qsTr("MAC address")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.address
            }
        }

        Row {
            height: 32
            spacing: 12

            visible: modelData.version.length

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: col.legendWidth

                text: qsTr("Bluetooth version")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            ItemTag {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.version
                color: Theme.colorComponent
            }
        }
    }
}
