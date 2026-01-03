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
    leftPadding: highlighted ? (padding + 8) : 12

    property bool highlighted: false

    background: Rectangle {
        implicitWidth: 512
        implicitHeight: 128
        radius: 4
        color: Theme.colorBox
        border.width: 2
        border.color: Theme.colorBoxBorder

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            width: 8
            radius: 2
            color: Theme.colorPrimary
            visible: control.highlighted
        }
    }
}
