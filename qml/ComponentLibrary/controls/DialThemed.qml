import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Dial {
    id: control
    implicitWidth: (Theme.componentHeight * 2)
    implicitHeight: (Theme.componentHeight * 2)

    ////////////////

    background: Rectangle {
        x: (control.width / 2) - (width / 2)
        y: (control.height / 2) - (height / 2)

        width: Math.max(64, Math.min(control.width, control.height))
        height: width
        radius: width

        opacity: control.enabled ? 1 : 0.66
        color: Theme.colorForeground
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorPrimary
    }

    ////////////////

    handle: Rectangle {
        x: control.background.x + (control.background.width / 2) - (width / 2)
        y: control.background.y + (control.background.height / 2) - (height / 2)

        width: 16
        height: 16
        radius: 8

        opacity: control.enabled ? 1 : 0.66
        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary

        transform: [
            Translate { y: -Math.min(control.background.width, control.background.height) * 0.4 + 8; },
            Rotation { angle: control.angle; origin.x: 8; origin.y: 8; }
        ]
    }

    ////////////////
}
