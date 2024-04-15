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

    font.pixelSize: Theme.componentFontSize

    focusPolicy: Qt.NoFocus

    ////////////////

    background: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        radius: Theme.componentHeight
        opacity: control.enabled ? 1 : 0.66
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
        border.width: 2
        border.color: Theme.colorComponentBorder
    }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: control.enabled ? 1 : 0.66
        color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
    }

    ////////////////
}
