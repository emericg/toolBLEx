import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import ThemeEngine

T.ItemDelegate {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: Theme.componentMargin
    spacing: Theme.componentMargin
    verticalPadding: 0

    icon.width: 32
    icon.height: 32
    icon.color: enabled ? Material.foreground : Material.hintTextColor

    ////////////////

    background: Rectangle {
        implicitHeight: Theme.componentHeightXL

        color: control.highlighted ? control.Material.listHighlightColor : "transparent"

        RippleThemed {
            anchors.fill: parent
            anchor: control

            clip: visible
            pressed: control.pressed
            active: enabled && (control.down || control.visualFocus || control.hovered)
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.5)
        }
    }

    ////////////////

    contentItem: Row {
        anchors.verticalCenter: parent.verticalCenter
        width: control.width
        spacing: Theme.componentMargin

        RoundButtonSunken {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.componentHeight
            height: Theme.componentHeight

            source: model.icon
            colorBackground: Theme.colorForeground
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: model.title
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                color: Theme.colorText
            }
            Text {
                text: model.text
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                color: Theme.colorSubText
            }
        }
    }

    ////////////////
}
