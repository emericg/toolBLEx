import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Button {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: Theme.componentBorderWidth
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentBorderWidth

    leftInset: Theme.componentMargin/2
    rightInset: Theme.componentMargin/2
    rightPadding: Theme.componentMargin
    leftPadding: Theme.componentMargin

    height: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    // settings
    property int index
    property url source
    property int sourceSize: 20
    property int layoutDirection: Qt.RightToLeft

    ////////////////

    background: Item {
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.componentRadius

            color: Theme.colorComponent
            //Behavior on color { ColorAnimation { duration: 133 } }

            opacity: control.hovered ? 1 : 0
            //Behavior on opacity { OpacityAnimator { duration: 233 } }
        }

        RippleThemed {
            anchors.fill: parent

            pressed: control.down
            active: enabled && control.down
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.66)
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
                    width: control.width
                    height: control.height
                    radius: Theme.componentRadius
                }
            }
        }
    }

    ////////////////

    contentItem: RowLayout {
        spacing: (Theme.componentMargin / 1)
        layoutDirection: control.layoutDirection

        IconSvg {
            Layout.preferredWidth: control.sourceSize
            Layout.preferredHeight: control.sourceSize

            source: control.source
            color: Theme.colorIcon
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: control.sourceSize

            text: control.text
            textFormat: Text.PlainText
            font.bold: false
            font.pixelSize: Theme.componentFontSize
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: Theme.colorText
        }
    }

    ////////////////
}
