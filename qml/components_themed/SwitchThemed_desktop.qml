import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Switch {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 4
    spacing: 12

    font.pixelSize: Theme.componentFontSize

    ////////////////

    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: Theme.componentHeight

        x: control.leftPadding
        y: (parent.height / 2) - (height / 2)
        width: 48
        height: (width / 2)
        radius: (width / 2)

        color: Theme.colorComponentBackground

        border.color: Theme.colorComponentBorder
        border.width: Theme.componentBorderWidth

        Rectangle {
            x: control.checked ? (parent.width - width) : 0
            Behavior on x { NumberAnimation { duration: 133 } }
            width: 24
            height: width
            radius: (width / 2)
            anchors.verticalCenter: parent.verticalCenter

            color: control.checked ? Theme.colorPrimary : Theme.colorComponentBorder

            Rectangle {
                anchors.fill: parent
                anchors.margins: -10
                z: -1
                radius: (width / 2)
                color: parent.color
                opacity: enabled && (control.pressed || control.hovered) ? 0.2 : 0
                Behavior on opacity { NumberAnimation { duration: 233 } }
            }
        }
    }

    contentItem: Text {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

        opacity: enabled ? 1.0 : 0.33

        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.checked ? Theme.colorText : Theme.colorSubText
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////
}
