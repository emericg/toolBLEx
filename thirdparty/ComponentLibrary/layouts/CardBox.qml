import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Frame {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: Theme.componentMargin

    topPadding: header.height + Theme.componentMargin

    property color colorBackground: "white" // Theme.colorBackground
    property color colorForeground: Theme.colorMaterialPurple
    property color colorIcon: Theme.colorIcon

    property string sourceBackground
    property string sourceIcon

    background: Rectangle {
        implicitWidth: 256
        implicitHeight: 400

        radius: 16
        color: control.colorBackground
        border.width: 2
        border.color: Theme.colorComponentBorder

        Rectangle { // background shadow
            anchors.fill: parent
            radius: background.radius
            color: control.colorBackground
            border.width: 2
            border.color: Theme.colorComponentBorder

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: Theme.colorComponentShadow

                opacity: control.hovered ? 1 : 0
                Behavior on opacity { OpacityAnimator { duration: 233 } }
            }
        }

        Item { // header container
            anchors.fill: parent
            anchors.margins: 1

            Rectangle { // header
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                topLeftRadius: 12
                topRightRadius: 12

                height: parent.width * 0.66 // parent.height * 0.4
                color: control.colorForeground

                Image {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height

                    asynchronous: true
                    source: control.sourceBackground
                    //sourceSize.width: parent.width
                    //sourceSize.height: parent.height
                    fillMode: Image.Tile
                }

                Rectangle {
                    width: 96
                    height: 96
                    radius: 96
                    anchors.centerIn: parent

                    visible: control.sourceIcon
                    opacity: 0.92

                    IconSvg {
                        anchors.centerIn: parent
                        width: 64
                        height: 64

                        asynchronous: true
                        source: control.sourceIcon
                        color: control.colorIcon
                        fillMode: Image.PreserveAspectFit
                    }
                }
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
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }
    }
}
