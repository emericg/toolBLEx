import QtQuick

import ComponentLibrary
import AppUtils

/*!
 * A value shown as a row of fixed size cells (one per byte), wrapping like text.
 *
 * Items declared inside a HexBytesView are laid out after the cells (and after the copy button).
 */
Flow {
    id: hexBytesView

    spacing: 0

    //! One string per cell, ex: [ "0a", "ff" ] (hexadecimal) or [ "a", "b" ] (ascii)
    property var bytes: []

    //! Size of a cell, in pixels
    property int cellSize: 26

    //! Cells to highlight, ex: the bytes of a decoded field
    property int highlightOffset: -1
    property int highlightLength: 0

    //! Half typed last byte, shown after the complete ones, ex: "c" (empty for none)
    property string partialNibble: ""

    //! Show a placeholder cell when there is nothing to show
    property bool showEmpty: false

    //! Show a copy button after the cells
    property bool copyable: false

    //! Text put in the clipboard by the copy button, ex: the value as a single hexadecimal string
    property string copyText: (bytes ? bytes.join("") : "")

    //! The copy button was used, until the bytes change
    property bool copied: false
    onBytesChanged: copied = false

    property string fontFamily: fontMonospace
    property int fontSize: Theme.fontSizeContent - 1

    readonly property int count: (bytes ? bytes.length : 0)

    function isHighlighted(idx) {
        return (idx >= highlightOffset && idx < highlightOffset + highlightLength)
    }

    ////////////////

    Repeater { // bytes
        model: hexBytesView.bytes

        Rectangle {
            required property int index
            required property string modelData

            readonly property bool highlighted: hexBytesView.isHighlighted(index)

            width: hexBytesView.cellSize
            height: hexBytesView.cellSize
            color: highlighted ? Theme.colorPrimary :
                   (index % 2 === 0) ? Theme.colorForeground : Theme.colorBox

            Text {
                anchors.fill: parent

                text: parent.modelData
                textFormat: Text.PlainText
                font.pixelSize: hexBytesView.fontSize
                font.family: hexBytesView.fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: parent.highlighted ? "white" : Theme.colorText
            }
        }
    }

    Item { // incomplete last byte
        width: hexBytesView.cellSize
        height: hexBytesView.cellSize

        visible: (hexBytesView.partialNibble.length > 0)

        Rectangle {
            anchors.fill: parent
            color: Theme.colorWarning
            opacity: 0.5
        }

        Text {
            anchors.fill: parent

            text: hexBytesView.partialNibble + "_"
            textFormat: Text.PlainText
            font.pixelSize: hexBytesView.fontSize
            font.family: hexBytesView.fontFamily
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
        }
    }

    Rectangle { // nothing to show
        width: hexBytesView.cellSize
        height: hexBytesView.cellSize

        visible: (hexBytesView.showEmpty && hexBytesView.count === 0 && hexBytesView.partialNibble.length === 0)
        color: Theme.colorForeground

        Canvas {
            id: canvasEmpty
            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, height)
                ctx.lineTo(width, height)
                ctx.lineTo(width, 0)
                ctx.closePath()
                ctx.fillStyle = Theme.colorBox
                ctx.fill()
            }

            Connections {
                target: Theme
                function onCurrentThemeChanged() { canvasEmpty.requestPaint() }
            }
        }
    }

    Item { // spacer
        width: 4
        height: 4
        visible: buttonCopy.visible
    }

    SquareButtonSunken {
        id: buttonCopy
        width: hexBytesView.cellSize
        height: hexBytesView.cellSize

        visible: (hexBytesView.copyable && hexBytesView.copyText.length > 0)

        colorBackground: hexBytesView.copied ? Theme.colorPrimary : Theme.colorBackground
        source: "qrc:/IconLibrary/material-symbols/content_copy.svg"
        tooltipText: hexBytesView.copied ? qsTr("copied") : qsTr("copy")
        tooltipPosition: "right"

        onClicked: {
            hexBytesView.copied = true
            UtilsClipboard.setText(hexBytesView.copyText)
        }
    }

    ////////////////
}
