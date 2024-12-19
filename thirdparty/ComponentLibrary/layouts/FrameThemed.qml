import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Frame {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12

    // colors
    property color colorBackground: Theme.colorForeground
    property color colorBorder: Theme.colorSeparator

    ////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        color: control.colorBackground
        border.width: 2
        border.color: control.colorBorder
    }

    ////////////////
}
