import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0

Column {
    id: advDataWidget
    anchors.left: parent.left
    anchors.right: parent.right

    property var packet: null
    property int legendWidth: 72

    ////////

    Row {
        height: 24
        spacing: 12

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: legendWidth

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
                font.family: "monospace"
                font.capitalization: Font.AllUppercase
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
            anchors.verticalCenter: parent.verticalCenter
            width: legendWidth

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
                font.family: "monospace"
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
            id: ttt
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

        TextArea {
            id: advdata
            height: 24
            padding: 0

            Layout.alignment: Qt.AlignBaseline
            Layout.fillWidth: true

            selectByMouse: true
            selectionColor: Theme.colorPrimary
            readOnly: true
            color: Theme.colorText

            text: packet.advDataString
            wrapMode: Text.WrapAnywhere
            font.family: "monospace"
            font.capitalization: Font.AllUppercase
            font.pixelSize: Theme.fontSizeContent
        }
    }

    ////////
}
