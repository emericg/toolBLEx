import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentRow.width + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12
    spacing: 6

    font.pixelSize: Theme.componentFontSize
    font.bold: false

    // settings
    flat: true
    checkable: false
    hoverEnabled: Theme.isDesktop
    focusPolicy: Qt.NoFocus

    property int radius: Theme.componentRadius

    // layout
    property int layoutAlignment: Qt.AlignCenter // Qt.AlignLeft // Qt.AlignRight
    property int layoutDirection: Qt.LeftToRight // Qt.RightToLeft
    property bool layoutFillWidth: false

    // icon
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // colors
    property color colorBackground: Theme.colorPrimary
    property color colorHighlight: Theme.colorComponentBorder
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.16)
    property color colorBorder: Theme.colorComponentBorder
    property color colorText: "white"

    // animation
    property string animation // available: rotate, fade, both
    property bool animationRunning: false

    ////////////////

    background: Item {
        implicitWidth: control.text ? 80 : Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            radius: control.radius
            color: control.colorBackground
            border.width: Theme.componentBorderWidth
            border.color: control.colorBorder

            layer.enabled: !control.flat
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: Theme.colorComponentShadow
            }
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control
            clip: true
            clipRadius: control.radius

            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple
        }
    }

    ////////////////

    contentItem: Item {
        RowLayout {
            id: contentRow
            anchors.left: (control.layoutFillWidth && control.layoutAlignment !== Qt.AlignCenter) ? parent.left : undefined
            anchors.right: (control.layoutFillWidth || control.layoutAlignment === Qt.AlignRight) ? parent.right : undefined
            anchors.horizontalCenter: (control.layoutAlignment === Qt.AlignCenter) ? parent.horizontalCenter : undefined
            anchors.verticalCenter: parent.verticalCenter

            spacing: control.spacing
            layoutDirection: {
                if (control.layoutAlignment === Qt.AlignRight) return Qt.RightToLeft
                return control.layoutDirection
            }

            Item {
                Layout.preferredWidth: control.sourceSize
                Layout.preferredHeight: control.sourceSize
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: (control.layoutFillWidth &&
                                   control.layoutDirection === Qt.LeftToRight)

                visible: control.source.toString().length

                IconSvg {
                    width: control.sourceSize
                    height: control.sourceSize

                    source: control.source
                    color: control.colorText
                    opacity: control.enabled ? 1 : 0.66
                    rotation: control.sourceRotation

                    SequentialAnimation on opacity {
                        running: (control.animationRunning &&
                                  (control.animation === "fade" || control.animation === "both"))
                        alwaysRunToEnd: true
                        loops: Animation.Infinite

                        PropertyAnimation { to: 0.5; duration: 666; }
                        PropertyAnimation { to: 1; duration: 666; }
                    }
                    NumberAnimation on rotation {
                        running: (control.animationRunning &&
                                  (control.animation === "rotate" || control.animation === "both"))
                        alwaysRunToEnd: true
                        loops: Animation.Infinite

                        duration: 1500
                        from: 0
                        to: 360
                        easing.type: Easing.Linear
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: (control.layoutFillWidth &&
                                   control.layoutDirection === Qt.RightToLeft)

                color: control.colorText
                opacity: control.enabled ? 1 : 0.66

                visible: control.text
                text: control.text
                textFormat: Text.PlainText

                font: control.font
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ////////////////
}
