import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0

Rectangle {
    id: advDataWidget
    height: col.height + 24
    radius: 4

    clip: false
    color: Theme.colorBox
    border.width: 2
    border.color: Theme.colorBoxBorder

    property var packet: null
    property int legendWidth: 48

    Component.onCompleted: {
        legendWidth = 48
        legendWidth = Math.max(legendWidth, legendUUID.contentWidth)
        legendWidth = Math.max(legendWidth, legendSize.contentWidth)
        legendWidth = Math.max(legendWidth, legendData.contentWidth)
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 8
        radius: 2
        color: (packet.advMode == 0) ? Theme.colorGreen : Theme.colorBlue
    }

    Text {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 8

        z: 4
        text: packet.timestamp.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorText

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: -4
            anchors.leftMargin: -8
            anchors.rightMargin: -8
            anchors.bottomMargin: -4
            radius: 2
            z: -1
            color: Theme.colorBoxBorder
        }
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        ////////

        Row {
            height: 24
            spacing: 12

            Text {
                id: legendUUID
                width: legendWidth
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("UUID")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    id: t
                    anchors.verticalCenter: parent.verticalCenter

                    text: "0x"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
                TextSelectable {
                    anchors.baseline: t.baseline

                    text: packet.advUUIDstr
                    color: Theme.colorText
                    font.family: fontMonospace
                    //font.capitalization: Font.AllUppercase
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                visible: (packet.advUUIDmanuf.length > 1)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "("
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }

                TextSelectable {
                    anchors.verticalCenter: parent.verticalCenter
                    text: packet.advUUIDmanuf
                    color: Theme.colorText
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ")"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
            }
        }

        ////////

        Row {
            height: 28
            spacing: 12

            Text {
                id: legendSize
                width: legendWidth
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Size")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.baseline: tt.baseline

                    text: packet.advDataSize
                    textFormat: Text.PlainText
                    font.family: fontMonospace
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }
                Text {
                    id: tt
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("bytes")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 8
            id: rrr
            spacing: 0

            Text {
                id: legendData
                height: 24

                Layout.alignment: Qt.AlignBaseline
                Layout.preferredWidth: legendWidth

                text: qsTr("Data")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Item { width: 12; height: 12; }

            Text {
                height: 24

                Layout.alignment: Qt.AlignBaseline

                text: "0x"
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }

            TextSelectable {
                id: advdata
                height: 24
                leftPadding: 4

                Layout.alignment: Qt.AlignBaseline
                Layout.fillWidth: true

                text: packet.advDataHexString
                wrapMode: Text.WrapAnywhere
                font.family: fontMonospace
                //font.capitalization: Font.AllUppercase
            }
        }

        ////////
    }
}
