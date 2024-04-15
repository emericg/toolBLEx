import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + 32 + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    text: "TAG"
    font.bold: true
    font.pixelSize: Theme.componentFontSize

    // icon
    property url source: "qrc:/assets/icons/material-symbols/add.svg"
    property int sourceSize: 16

    // colors
    property color colorBackground: Theme.colorPrimary
    property color colorBorder: Theme.colorComponentBorder
    property color colorText: "white"

    ////////////////

    background: Rectangle {
        implicitWidth: 72
        implicitHeight: 28

        radius: Theme.componentRadius
        color: control.colorBackground
        border.width: Theme.componentBorderWidth
        border.color: control.colorBorder

        Item {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 32

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 32

                color: {
                    if (mousearea.containsPress) return Qt.darker(control.colorBackground, 1.06)
                    if (mousearea.containsMouse) return Qt.darker(control.colorBackground, 1.03)
                    return control.colorBackground
                }
                opacity: (mousearea.containsMouse) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 133 } }
            }

            Rectangle { // vertical separator
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.rightMargin: 0
                width: 2
                color: control.colorText
                opacity: 0.5
            }

            IconSvg {
                anchors.centerIn: parent
                source: control.source
                width: control.sourceSize
                color: control.colorText
            }

            MouseArea {
                id: mousearea
                anchors.fill: parent
                hoverEnabled: control.enabled
                onClicked: control.clicked()
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
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: Theme.componentRadius
                }
            }
        }
    }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        color: control.colorText
        font: control.font

        elide: Text.ElideMiddle
        //horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////
}
