import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.ProgressBar {
    id: control
    implicitWidth: 200
    implicitHeight: 12

    value: 0.5

    property var colorBackground: Theme.colorComponentBackground
    property var colorForeground: Theme.colorPrimary

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 12

        radius: (Theme.componentRadius / 2)
        color: control.colorBackground
    }

    contentItem: Item {
        Rectangle {
            width: control.visualPosition * control.width
            height: control.height
            radius: (Theme.componentRadius / 2)
            color: control.colorForeground
        }
    }
}
