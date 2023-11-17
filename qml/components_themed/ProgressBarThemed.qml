import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

T.ProgressBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    property var colorBackground: Theme.colorComponentBackground
    property var colorForeground: Theme.colorPrimary

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 12
        y: (control.height - height) / 2

        radius: (Theme.componentRadius / 2)
        color: control.colorBackground
    }

    ////////////////

    contentItem: Item {
        Rectangle {
            width: control.visualPosition * control.width
            height: control.height
            color: control.colorForeground
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: contentItem.x
                y: contentItem.y
                width: contentItem.width
                height: contentItem.height
                radius: contentItem.height
            }
        }
    }

    ////////////////
}
