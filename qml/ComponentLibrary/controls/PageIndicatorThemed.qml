import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.PageIndicator {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 6
    spacing: 6

    count: 1
    currentIndex: 1

    property color color: Theme.colorHeaderContent

    ////////////////

    delegate: Rectangle {
        implicitWidth: 12
        implicitHeight: 12
        radius: (width / 2)

        color: control.color
        opacity: (index === control.currentIndex) ? (0.95) : (control.pressed ? 0.7 : 0.45)

        required property int index

        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////

    contentItem: Row {
        spacing: control.spacing

        Repeater {
            model: control.count
            delegate: control.delegate
        }
    }

    ////////////////
}
