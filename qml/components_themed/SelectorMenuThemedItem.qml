import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

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
    property string colorContent: Theme.colorComponentText
    property string colorContentHighlight: Theme.colorComponentContent
    property string colorBackgroundHighlight: Theme.colorComponentDown

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

    contentItem: Row {
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

    ////////////////
}
