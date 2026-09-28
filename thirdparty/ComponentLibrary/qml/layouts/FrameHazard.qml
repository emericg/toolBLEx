import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.Frame {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12

    // settings
    property int stripeWidth: 56
    property int stripeSpacing: 56

    // colors
    property color colorBackground: Theme.colorBackground
    property color colorForeground: Theme.colorForeground
    property color colorBorder: Theme.colorForeground

    ////////////////

    background: RectangleHazard {
        colorBackground: control.colorBackground
        colorStripe: control.colorForeground
        //colorBorder: control.colorBorder
        stripeWidth: control.stripeWidth
        stripeSpacing: control.stripeSpacing

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            border.color: control.colorBorder
        }
    }

    ////////////////
}
