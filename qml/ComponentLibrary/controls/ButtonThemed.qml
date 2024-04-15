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

    focusPolicy: Qt.NoFocus

    ////////////////

    background: Rectangle {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
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
        elide: Text.ElideMiddle
        //wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: control.enabled ? 1 : 0.66
        color: control.down ? Theme.colorComponentContent : Theme.colorComponentContent
    }

    ////////////////
}
