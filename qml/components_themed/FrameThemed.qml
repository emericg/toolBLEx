import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Frame {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12

    // colors
    property string backgroundColor: Theme.colorForeground
    property string borderColor: Theme.colorSeparator

    ////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        color: control.backgroundColor
        border.width: 2
        border.color: control.borderColor
    }

    ////////////////
}
