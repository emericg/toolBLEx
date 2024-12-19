import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 16
    rightPadding: 16

    focusPolicy: Qt.NoFocus

    // settings
    property int index
    property url source
    property int sourceSize: 32

    // colors
    property color colorContent: Theme.colorComponentText
    property color colorContentHighlight: Theme.colorComponentContent
    property color colorBackgroundHighlight: Theme.colorComponentDown

    ////////////////

    background: Rectangle {
        implicitWidth: 32
        implicitHeight: 32
        radius: Theme.componentRadius

        color: control.colorBackgroundHighlight
        opacity: {
            if (control.hovered && control.highlighted) return 0.9
            else if (control.highlighted) return 0.7
            else if (control.hovered) return 0.5
            return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////

    contentItem: Item {
        Row {
            anchors.centerIn: parent
            spacing: 4

            IconSvg { // contentImage
                anchors.verticalCenter: parent.verticalCenter
                visible: control.source.toString().length

                width: control.sourceSize
                height: control.sourceSize

                source: control.source
                color: control.highlighted ? control.colorContentHighlight : control.colorContent
                opacity: control.highlighted ? 1 : 0.5
            }

            Text { // contentText
                anchors.verticalCenter: parent.verticalCenter
                visible: control.text

                text: control.text
                textFormat: Text.PlainText
                font: control.font
                verticalAlignment: Text.AlignVCenter

                color: control.highlighted ? control.colorContentHighlight : control.colorContent
                opacity: control.highlighted ? 1 : 0.66
            }
        }
    }

    ////////////////
}
