import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.ToolTip {
    id: control

    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - 8

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 6
    padding: 6

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    // colors
    property color colorText: Theme.colorText
    property color colorBackground: Theme.colorComponent

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        wrapMode: Text.Wrap
        color: control.colorText
    }

    ////////////////

    background: Rectangle {
        color: control.colorBackground
        radius: 4

        Rectangle { // arrow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top

            width: 12; height: 12; rotation: 45
            color: control.colorBackground
        }
    }

    ////////////////
}
