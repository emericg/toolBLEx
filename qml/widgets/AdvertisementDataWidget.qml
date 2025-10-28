import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary
import DeviceUtils

Column {
    id: advDataWidget
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.right: parent.right
    anchors.rightMargin: 8

    clip: false
    spacing: 4

    property var packet: null
    property int legendWidth: 48

    Component.onCompleted: {
        legendWidth = 48
        legendWidth = Math.max(legendWidth, legendUUID.contentWidth)
        legendWidth = Math.max(legendWidth, legendSize.contentWidth)
        legendWidth = Math.max(legendWidth, legendData_hex.contentWidth)
        legendWidth = Math.max(legendWidth, legendData_str.contentWidth)
    }

    ////////

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12

        Text {
            id: legendUUID

            Layout.preferredWidth: legendWidth
            Layout.alignment: Qt.AlignTop | Qt.AlignRight

            text: qsTr("UUID")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            horizontalAlignment: Text.AlignRight
            color: Theme.colorSubText
        }

        Flow {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

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
                    color: Theme.colorText
                }
            }

            Item { width: 12; height: 12; } // spacer

            Row {
                visible: (packet.advUUIDmanuf.length > 1)

                Text {
                    text: "("
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
                TextSelectable {
                    text: packet.advUUIDmanuf
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }
                Text {
                    text: ")"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
            }
        }
    }

    ////////

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
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
}
