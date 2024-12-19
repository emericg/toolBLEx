import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: compactInternal ? 0 : 12
    rightPadding: compactInternal ? 0 : 12 + (control.source.toString().length && control.text ? 2 : 0)
    spacing: 6

    width: compactInternal ? height : implicitWidth
    height: compactInternal ? height : implicitHeight
    Behavior on width { NumberAnimation { duration: 133 } }

    font.pixelSize: Theme.componentFontSize
    font.bold: false

    focusPolicy: Qt.NoFocus

    // settings
    property bool compact: false
    property bool compactInternal: compact || !control.text
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property int layoutDirection: Qt.LeftToRight

    // colors
    property color textColor: Theme.colorText
    property color iconColor: Theme.colorIcon
    property color backgroundColor: Theme.colorComponent

    // animation
    property string animation // available: rotate, fade, both
    property bool animationRunning: false
    property bool hoverAnimation: isDesktop

    // tooltip
    property string tooltipText
    property string tooltipPosition: "bottom"

    ////////////////

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        enabled: control.hoverAnimation
        hoverEnabled: control.hoverAnimation

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: {
            control.down = true
            mouseBackground.width = (control.width * 2)
        }
        onReleased: {
            control.down = false
            //mouseBackground.width = 0 // disabled, we let the click expand the ripple
        }
        onEntered: {
            mouseBackground.width = 72
        }
        onExited: {
            control.down = false
            mouseBackground.width = 0
        }
        onCanceled: {
            control.down = false
            mouseBackground.width = 0
        }
    }

    ////////////////

    background: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        radius: control.compactInternal ? Theme.componentHeight : Theme.componentRadius
        color: control.backgroundColor

        //opacity: ( mouseArea.containsMouse) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 233 } }

        Rectangle {
            id: mouseBackground
            width: 0; height: width; radius: width;
            x: mouseArea.mouseX - (width / 2)
            y: mouseArea.mouseY - (width / 2)

            //visible: !control.compact
            color: "white"
            opacity: mouseArea.containsMouse ? 0.16 : 0
            Behavior on opacity { NumberAnimation { duration: 333 } }
            Behavior on width { NumberAnimation { duration: 200 } }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: false
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
        }
    }

    ////////////////

    contentItem: RowLayout {
        spacing: control.spacing
        layoutDirection: control.layoutDirection

        opacity: control.enabled ? 1 : 0.66

        IconSvg {
            width: control.sourceSize
            height: control.sourceSize

            visible: control.source.toString().length
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            source: control.source
            color: control.iconColor

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

        Text {
            text: control.text
            textFormat: Text.PlainText

            visible: !control.compactInternal
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            font: control.font
            elide: Text.ElideRight

            color: control.iconColor
        }
    }

    ////////////////

    Loader {
        anchors.fill: control
        active: control.tooltipText && control.compactInternal

        sourceComponent: ToolTipFlat {
            visible: mouseArea.containsMouse
            text: control.tooltipText
            textColor: control.textColor
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.backgroundColor
        }
    }

    ////////////////
}
