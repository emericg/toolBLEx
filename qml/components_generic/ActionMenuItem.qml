import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

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

    height: 36

    focusPolicy: Qt.NoFocus

    // settings
    property int index
    //property string text
    property url source
    property int sourceSize: 20
    property int layoutDirection: Qt.RightToLeft

    ////////////////

    background: Item {
        implicitHeight: 36

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
            clip: visible
            pressed: control.down
            active: enabled && control.down
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.66)
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: background.x
                y: background.y
                width: background.width
                height: background.height
                radius: Theme.componentRadius
            }
        }
    }

    ////////////////

    contentItem: RowLayout {
        spacing: Theme.componentMargin/2
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
