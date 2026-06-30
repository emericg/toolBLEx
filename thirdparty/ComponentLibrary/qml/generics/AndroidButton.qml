import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    focusPolicy: Qt.NoFocus

    // colors
    property color colorPrimary: Theme.colorPrimary

    ////////////////

    background: Item {
        implicitWidth: 80
        implicitHeight: 48

        RippleThemed {
            anchors.fill: parent
            anchor: control
            clip: true
            clipRadius: 8

            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: Qt.rgba(control.colorPrimary.r, control.colorPrimary.g, control.colorPrimary.b, 0.1)
        }
    }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font.bold: false
        font.pixelSize: Theme.componentFontSize
        font.capitalization: Font.AllUppercase

        elide: Text.ElideMiddle
        //wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: control.colorPrimary
        opacity: control.enabled ? 1 : 0.66
    }

    ////////////////
}
