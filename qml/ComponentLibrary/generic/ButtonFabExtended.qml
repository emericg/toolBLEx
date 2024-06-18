import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    //anchors.right: parent.right
    //anchors.bottom: parent.bottom
    //anchors.margins: Theme.componentMarginXL
    //z: 10

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            rowrowrow.width + leftPadding + rightPadding)
    implicitHeight: implicitBackgroundHeight

    leftPadding: 16
    rightPadding: 12
    spacing: 6

    flat: false
    hoverEnabled: isDesktop
    focusPolicy: Qt.NoFocus
    font.pixelSize: Theme.componentFontSize + 2
    font.bold: true

    // settings
    property string shape: "squared" // available: rounded, squared
    property int shapeRadius: (shape === "rounded") ? 2 : 4

    // icon
    property url source: "qrc:/assets/icons/material-symbols/add.svg"
    property int sourceSize: 32
    property int sourceRotation: 0

    // colors
    property color colorBackground: Theme.colorPrimary
    property color colorHighlight: "white"
    property color colorIcon: "white"

    // animation
    property string animation: "" // available: rotate, fade
    property bool animationRunning: false

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
        implicitWidth: Theme.componentHeightXL
        implicitHeight: Theme.componentHeightXL

        Rectangle {
            anchors.fill: parent
            radius: (height / control.shapeRadius)
            color: control.colorBackground

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: Theme.colorComponentShadow
                shadowVerticalOffset: 4
                shadowScale: 1.04
            }
        }

        RippleThemed {
            width: parent.width
            height: parent.height

            anchor: control
            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: Qt.rgba(control.colorHighlight.r, control.colorHighlight.g, control.colorHighlight.b, 0.1)

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: (background.height / control.shapeRadius)
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Row {
            id: rowrowrow

            anchors.centerIn: parent
            spacing: control.spacing

            Text {
                height: 56

                color: control.colorIcon
                opacity: control.enabled ? 1 : 0.66

                visible: control.text
                text: control.text
                textFormat: Text.PlainText

                font: control.font
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                width: control.sourceSize
                height: 56

                IconSvg {
                    anchors.centerIn: parent
                    width: control.sourceSize
                    height: control.sourceSize
                    rotation: control.sourceRotation
                    color: control.colorIcon
                    opacity: control.enabled ? 1 : 0.66

                    visible: control.source.toString().length
                    source: control.source

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
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
