import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    font.pixelSize: Theme.componentFontSize
    font.bold: true

    flat: true
    focusPolicy: Qt.NoFocus

    // colors
    property color colorHighlight: Theme.colorPrimary
    property color colorHover: Theme.colorHeader

    ////////////////

    background: Rectangle {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: 2
        opacity: {
            if (!control.enabled) return 0.4
            if (control.hovered && !control.highlighted) return 0.66
            return 1
        }
        color: {
            if (control.highlighted) return control.colorHighlight
            if (control.hovered) return control.colorHover
            return "transparent"
        }
    }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        elide: Text.ElideMiddle
        //wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: control.enabled ? 1 : 0.66
        color: control.highlighted ? "white" : Theme.colorText
    }

    ////////////////
}
