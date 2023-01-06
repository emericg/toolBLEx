import QtQuick
import QtQuick.Layouts

import ThemeEngine 1.0

import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Rectangle {
    id: adapterWidget
    height: box.height + 24
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

        visible: (adapterWidget.width > box.legendWidth*4)

        source: "qrc:/assets/icons_bootstrap/bluetooth.svg"
        color: Theme.colorSubText
    }

    ////////

    Column {
        id: box
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.rightMargin: 8
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
            anchors.left: parent.left
            anchors.leftMargin: 16
            height: 32

            text: qsTr("Bluetooth adapter #%1").arg(index+1)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.colorText
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                id: legendHostname
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("Hostname")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: 32

                text: modelData.hostname
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                id: legendAddress
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("MAC address")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: 32

                text: modelData.address
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            visible: modelData.manufacturer.length

            Text {
                id: legendMAC
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("MAC vendor")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: 32

                text: modelData.manufacturer
                wrapMode: Text.WrapAnywhere
            }
        }

        Row {
            height: 32
            spacing: 12

            visible: modelData.version.length

            Text {
                id: legendBluetooth
                anchors.verticalCenter: parent.verticalCenter
                width: box.legendWidth

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
                width: box.legendWidth

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
