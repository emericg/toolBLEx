import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Control {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 8
    rightPadding: 8

    // settings
    font.pixelSize: Theme.componentFontSize
    font.bold: false

    // text
    property string text: "TAG"

    // colors
    property color colorBackground: Theme.colorPrimary
    property color colorBorder: Theme.colorComponentBorder
    property color colorText: "white"

    ////////////////

    background: Rectangle {
        implicitWidth: 48
        implicitHeight: 26

        radius: Theme.componentRadius
        color: control.colorBackground
        border.width: Theme.componentBorderWidth
        border.color: control.colorBorder
    }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        color: control.colorText
        font: control.font

        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////
}
