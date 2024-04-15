import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.RadioButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 4
    spacing: 8
    font.pixelSize: Theme.componentFontSize

    ////////////////

    indicator: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        x: control.leftPadding
        y: (parent.height / 2) - (height / 2)
        width: 24
        height: 24
        radius: 12

        opacity: control.enabled ? 1 : 0.8
        color: Theme.colorComponentBackground
        border.width: Theme.componentBorderWidth
        border.color: (control.enabled && control.checkable &&
                       (control.down || control.hovered)) ?
                          Theme.colorSecondary : Theme.colorComponentBorder

        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 12
            radius: 6

            color: Theme.colorSecondary
            opacity: control.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 133 } }
        }
    }

    ////////////////

    contentItem: Text {
        leftPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter

        text: control.text
        textFormat: Text.PlainText
        font: control.font
        wrapMode: Text.WordWrap

        color: control.checked ? Theme.colorText : Theme.colorSubText
        opacity: control.enabled ? 1 : 0.66
    }

    ////////////////
}
