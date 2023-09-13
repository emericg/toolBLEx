import QtQuick
import QtQuick.Templates as T

import ThemeEngine

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
    property string badgeText
    property string badgeColor: Theme.colorPrimary
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
        spacing: 8

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter

            width: control.sourceSize
            height: control.sourceSize

            source: control.source
            color: control.highlighted ? control.colorContentHighlight : control.colorContent
            opacity: control.highlighted ? 1 : 0.5
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: Theme.componentFontSize
            verticalAlignment: Text.AlignVCenter

            color: control.highlighted ? control.colorContentHighlight : control.colorContent
            opacity: control.highlighted ? 1 : 0.6
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter

            width: control.height*0.6
            height: width
            radius: width

            visible: control.badgeText
            color: control.badgeColor
            opacity: control.highlighted ? 1 : 0.6

            Text {
                anchors.fill: parent

                text: control.badgeText
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVerySmall
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: control.highlighted ? control.colorContentHighlight : control.colorContent
                opacity: control.highlighted ? 0.7 : 0.7
            }
        }
    }

    ////////////////
}
