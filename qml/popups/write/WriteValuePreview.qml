import QtQuick

import ComponentLibrary

/*!
 * The bytes about to be written, their size, and whether they can be written.
 */
Column {
    id: writeValuePreview

    spacing: Theme.componentMarginXS

    ////////////////

    enum Status { Empty, Ok, Warning, Error }

    //! The encoded value, one hexadecimal string per byte
    property var bytes: []

    //! Half typed last byte, ex: "c" (empty for none)
    property string partialNibble: ""

    //! Size of the value expected by the descriptors, -1 if unknown
    property int expectedSize: -1

    //! Largest value that fits in a single packet, -1 if unknown
    property int maxPacketSize: -1

    //! Can the value be written, as { level, message } (see Status)
    property var status: ({ level: WriteValuePreview.Status.Empty, message: "" })

    readonly property color statusColor: {
        if (status.level === WriteValuePreview.Status.Error) return Theme.colorError
        if (status.level === WriteValuePreview.Status.Warning) return Theme.colorWarning
        return Theme.colorSubText
    }

    ////////////////////////////////////////////////////////////////////////////

    SectionTitle {
        width: parent.width
        text: qsTr("Data to be written (hexadecimal)")
    }

    ////////

    Row { // size indicator
        width: parent.width
        spacing: Theme.componentMarginXS

        Text {
            text: qsTr("%n byte(s)", "", writeValuePreview.bytes.length)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: writeValuePreview.statusColor
        }
        Text {
            visible: (writeValuePreview.expectedSize > 0)
            text: "/ " + qsTr("expected: %n byte(s)", "", writeValuePreview.expectedSize)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorSubText
        }
        Text {
            text: {
                if (writeValuePreview.maxPacketSize > 0)
                    return "/ " + qsTr("max single packet: %1 bytes").arg(writeValuePreview.maxPacketSize)
                return "/ " + qsTr("max single packet: unknown")
            }
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorSubText
        }
    }

    ////////

    HexBytesView {
        width: parent.width

        bytes: writeValuePreview.bytes
        partialNibble: writeValuePreview.partialNibble
        showEmpty: true
        copyable: true
    }

    ////////

    Rectangle { // write status
        width: parent.width
        height: Math.max(40, textWriteStatus.contentHeight + Theme.componentMargin * 2)
        radius: Theme.componentRadius
        color: Theme.colorForeground

        visible: (writeValuePreview.status.message.length > 0)

        IconSvg {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"
            color: writeValuePreview.statusColor
        }

        Text {
            id: textWriteStatus
            anchors.left: parent.left
            anchors.leftMargin: 52
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            text: writeValuePreview.status.message
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            wrapMode: Text.WordWrap
            color: Theme.colorText
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
