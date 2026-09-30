import QtQuick
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

    font.pixelSize: Theme.componentFontSize
    font.bold: false

    focusPolicy: Qt.NoFocus
    hoverEnabled: enabled && !readOnly

    // settings
    property int index
    property bool readOnly: false

    // icon
    property url source
    property int sourceSize: 32
    property int sourceRotation: 0

    // badge
    property string badgeText
    property bool badgeFade: false
    property int badgeSize: UtilsNumber.alignTo(height * 0.6, 2)
    property color badgeColor: Theme.colorPrimary
    property color badgeTextColor: "white"

    function blink() { badgeLoader.item?.blink() }

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
        Behavior on opacity { OpacityAnimator { duration: Theme.animationSpeedFast } }
    }

    ////////////////

    contentItem: Row {
        spacing: 4

        IconSvg { // contentImage
            anchors.verticalCenter: parent.verticalCenter
            visible: control.source.toString().length

            width: control.sourceSize
            height: control.sourceSize
            rotation: control.sourceRotation

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

        Loader { // contentBadge
            id: badgeLoader
            anchors.verticalCenter: parent.verticalCenter

            width: control.badgeSize
            height: control.badgeSize

            active: (control.badgeText.length > 0 || control.badgeFade)
            visible: active
            opacity: control.highlighted ? 1 : 0.6

            sourceComponent: ButtonBadge {
                text: control.badgeText
                fade: control.badgeFade
                color: control.badgeColor
                colorText: control.badgeTextColor
            }
        }
    }

    ////////////////
}
