import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12
    spacing: 12

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: 26
    property int layoutDirection: Qt.LeftToRight

    // colors
    property color colorPrimary: Theme.colorPrimary

    ////////////////

    background: Item {
        implicitWidth: 80
        implicitHeight: 48

        opacity: control.enabled ? 1 : 0.66

        Rectangle {
            id: shadowarea
            anchors.fill: parent
            border.color: "#eee"
            radius: 8
            border.width: 1
            color: "white"

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: Theme.colorComponentShadow
            }
        }

        RippleThemed {
            width: parent.width
            height: parent.height

            anchor: control
            pressed: control.pressed
            active: enabled && (control.down || control.visualFocus)
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.5)

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
                        radius: 8
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: RowLayout {
        spacing: control.spacing
        layoutDirection: control.layoutDirection

        IconSvg { // contentImage
            Layout.preferredWidth: control.sourceSize
            Layout.preferredHeight: control.sourceSize

            width: control.sourceSize
            height: control.sourceSize

            source: control.source
            color: control.colorPrimary
            opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.33
        }
        Text { // contentText
            Layout.fillWidth: true

            text: control.text
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: Theme.componentFontSize

            elide: Text.ElideMiddle
            //wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            color: control.colorPrimary
            opacity: enabled ? (control.down ? 0.8 : 1.0) : 0.66
        }
    }

    ////////////////
}
