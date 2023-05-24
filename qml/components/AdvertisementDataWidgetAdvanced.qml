import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0

Rectangle {
    id: advDataWidget
    height: columnContent.height + 32
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
        legendWidth = Math.max(legendWidth, legendData_hex.contentWidth)
        legendWidth = Math.max(legendWidth, legendData_str.contentWidth)
    }

    ////////////////

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 8
        radius: 2
        color: (packet.advMode == 0) ? Theme.colorGreen : Theme.colorBlue
    }

    ////////////////

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

    ////////////////

    Column {
        id: columnContent
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        ////////

        Row {
            spacing: 12

            Text {
                id: legendUUID
                width: legendWidth

                text: qsTr("UUID")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Row {
                spacing: 2

                Text {
                    text: "0x"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
                TextSelectable {
                    text: packet.advUUIDstr
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }
            }
        }

        ////////

        TextSelectable {
            anchors.left: parent.left
            anchors.leftMargin: legendWidth + 12
            anchors.right: parent.right

            visible: (packet.advUUIDmanuf.length > 1)
            text: packet.advUUIDmanuf
            color: Theme.colorText
        }

        ////////

        Row {
            spacing: 12

            Text {
                id: legendSize
                width: legendWidth

                text: qsTr("DATA")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Row {
                spacing: 4

                Text {
                    text: packet.advDataSize
                    textFormat: Text.PlainText
                    //font.family: fontMonospace
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }
                Text {
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
            spacing: 12

            Text {
                id: legendData_hex

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.preferredWidth: legendWidth

                text: qsTr("(hex)")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVerySmall
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Flow {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                Repeater {
                    model: packet.advDataHex_list

                    Rectangle {
                        width: 26
                        height: 26
                        color: (index % 2 === 0) ? Theme.colorForeground : Theme.colorBox
                        border.width: 0
                        border.color: Theme.colorForeground

                        Text {
                            height: 26
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: modelData
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent-1
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.colorText
                            font.family: fontMonospace
                        }
                    }
                }
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                id: legendData_str

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.preferredWidth: legendWidth

                text: qsTr("(str)")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVerySmall
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Flow {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                Repeater {
                    model: packet.advDataAscii_list

                    Rectangle {
                        width: 26
                        height: 26
                        color: (index % 2 === 0) ? Theme.colorForeground : Theme.colorBox
                        border.width: 0
                        border.color: Theme.colorForeground

                        Text {
                            height: 26
                            anchors.horizontalCenter: parent.horizontalCenter

                            //text: (modelData === "\0") ? "⧄": modelData // empty byte: ∅ ? ⧄ ?
                            text: modelData
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent-1
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.colorText
                            font.family: fontMonospace
                        }
                    }
                }
            }
        }

        ////////
/*
        RowLayout { // DEPRECATED // old way to present advertisement data
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 8
            spacing: 2

            Text {
                id: legendData_hex
                height: 24

                Layout.alignment: Qt.AlignBaseline
                Layout.preferredWidth: legendWidth

                text: qsTr("(hex)")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent-1
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

                text: packet.advDataHex
                wrapMode: Text.WrapAnywhere
                font.family: fontMonospace
                //font.capitalization: Font.AllUppercase
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 8
            spacing: 0

            Text {
                id: legendData_str
                height: 24

                Layout.alignment: Qt.AlignBaseline
                Layout.preferredWidth: legendWidth

                text: qsTr("(str)")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent-1
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            Item { width: 12; height: 12; }

            TextSelectable {
                height: 24
                leftPadding: 4

                Layout.alignment: Qt.AlignBaseline
                Layout.fillWidth: true

                text: packet.advDataAscii
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WrapAnywhere
                font.family: fontMonospace
            }
        }
*/
        ////////
    }
}
