import QtQuick

import ThemeEngine 1.0

import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Rectangle {
    id: adapterWidget
    height: col.height + 24
    radius: 4

    clip: false
    color: Theme.colorBox
    border.width: 2
    border.color: Theme.colorBoxBorder

    ////////

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
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: 64
        height: 64

        visible: (adapterWidget.width > col.legendWidth*2.5)

        source: "qrc:/assets/icons_bootstrap/bluetooth.svg"
        color: Theme.colorSubText
    }

    ////////

    Column {
        id: col
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter

        property int legendWidth: 80

        Component.onCompleted: {
            legendWidth = 80
            legendWidth = Math.max(legendWidth, legendHostname.contentWidth)
            legendWidth = Math.max(legendWidth, legendAddress.contentWidth)
            legendWidth = Math.max(legendWidth, legendMAC.contentWidth)
            legendWidth = Math.max(legendWidth, legendBluetooth.contentWidth)
            legendWidth = Math.max(legendWidth, legendHostMode.contentWidth)
        }

        Text {
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter

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
                id: legendHostname
                width: col.legendWidth
                anchors.verticalCenter: parent.verticalCenter

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
                id: legendAddress
                width: col.legendWidth
                anchors.verticalCenter: parent.verticalCenter

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

            visible: modelData.manufacturer.length

            Text {
                id: legendMAC
                width: col.legendWidth
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("MAC vendor")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.manufacturer
            }
        }

        Row {
            height: 32
            spacing: 12

            visible: modelData.version.length

            Text {
                id: legendBluetooth
                width: col.legendWidth
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Bluetooth")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            ItemTag {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.version
                color: Theme.colorForeground
            }
        }

        Row {
            height: 32
            spacing: 12

            Text {
                id: legendHostMode
                anchors.verticalCenter: parent.verticalCenter
                width: col.legendWidth
                text: qsTr("Host mode")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            ItemTag {
                anchors.verticalCenter: parent.verticalCenter
                text: UtilsBluetooth.getBluetoothAdapterModeText(modelData.mode)
                color: Theme.colorForeground
            }
        }
    }

    ////////
}
