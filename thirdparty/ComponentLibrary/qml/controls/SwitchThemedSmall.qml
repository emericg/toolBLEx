import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.Switch {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 4
    spacing: 12

    font.pixelSize: Theme.componentFontSize

    property int www: 40
    property int hhh: 16

    property color colorText: Theme.colorText
    property color colorSubText: Theme.colorSubText

    ////////////////

    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: Theme.componentHeight

        x: control.leftPadding
        y: (parent.height / 2) - (height / 2)
        width: 40
        height: 16
        radius: 16

        opacity: control.enabled ? 1 : 0.8
        color: control.checked ? Theme.colorSecondary : Theme.colorComponentDown
        Behavior on color { ColorAnimation { duration: 133; easing.type: Easing.InOutCirc; } }

        Rectangle {
            x: control.checked ? (parent.width - width) : 0
            Behavior on x { NumberAnimation { duration: 133 } }
            width: 24
            height: width
            radius: (width / 2)
            anchors.verticalCenter: parent.verticalCenter

            color: control.checked ? Theme.colorPrimary : Theme.colorComponent
            border.width: control.checked ? 0 : 1
            border.color: Theme.colorComponentBorder

            Rectangle {
                anchors.fill: parent
                anchors.margins: -10
                z: -1
                radius: (width / 2)
                color: parent.color
                opacity: (control.pressed) ? 0.2 : 0
                Behavior on opacity { NumberAnimation { duration: 133 } }
            }
        }
    }

    contentItem: Text {
        leftPadding: !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.mirrored ? control.indicator.width + control.spacing : 0

        opacity: control.enabled ? 1 : 0.66
        color: control.checked ? control.colorText : control.colorSubText

        text: control.text
        textFormat: Text.PlainText
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////
}

