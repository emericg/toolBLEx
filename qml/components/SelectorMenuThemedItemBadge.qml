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

    focusPolicy: Qt.NoFocus

    // settings
    property int index
    property bool badgeFade: false
    property string badgeText
    property string badgeColor: Theme.colorPrimary
    property url source
    property int sourceSize: 32

    // colors
    property string colorContent: Theme.colorComponentText
    property string colorContentHighlight: Theme.colorComponentContent
    property string colorBackgroundHighlight: Theme.colorComponentDown

    function blink() { blinkAnim.start() }

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

            visible: (control.badgeText || control.badgeFade)
            color: control.badgeColor
            opacity: control.highlighted ? 1 : 0.6

            Rectangle {
                id: blinkRect
                anchors.centerIn: parent
                z: -1
                width: 0
                height: width
                radius: width
                color: control.badgeColor
            }
            ParallelAnimation {
                id: blinkAnim
                running: false
                loops: 1
                alwaysRunToEnd: false
                NumberAnimation { target: blinkRect; property: "width"; from: 12; to: 40; duration: 666; }
                NumberAnimation { target: blinkRect; property: "opacity"; from: 0.85; to: 0; duration: 666; }
            }
            SequentialAnimation on opacity {
                id: fadeAnim
                running: control.badgeFade
                loops: Animation.Infinite
                alwaysRunToEnd: true
                PropertyAnimation { to: 0.33; duration: 666; }
                PropertyAnimation { to: 0.66; duration: 666; }
            }

            Text {
                anchors.fill: parent

                text: control.badgeText
                textFormat: Text.PlainText
                fontSizeMode: Text.HorizontalFit
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
                minimumPixelSize: Theme.fontSizeContentVeryVerySmall
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: control.highlighted ? control.colorContentHighlight : control.colorContent
                opacity: control.highlighted ? 0.7 : 0.7
            }
        }
    }

    ////////////////
}
