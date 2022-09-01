import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    focusPolicy: Qt.NoFocus

    // colors
    property string primaryColor: Theme.colorPrimary

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mousearea
        anchors.fill: control

        hoverEnabled: false
        propagateComposedEvents: false

        onClicked: control.clicked()
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
        implicitWidth: 256
        implicitHeight: 56

        Rectangle { // mouseBackground
            width: mousearea.pressed ? control.width*2 : 0
            height: width
            radius: width

            x: mousearea.mouseX + 4 - (width / 2)
            y: mousearea.mouseY + 4 - (width / 2)

            color: control.primaryColor
            opacity: mousearea.pressed ? 0.1 : 0
            Behavior on opacity { NumberAnimation { duration: 333 } }
            Behavior on width { NumberAnimation { duration: 333 } }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: background.x
                y: background.y
                width: background.width
                height: background.height
                radius: 8
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font.bold: false
        font.pixelSize: Theme.fontSizeComponent
        font.capitalization: Font.AllUppercase

        elide: Text.ElideMiddle
        //wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: control.primaryColor
        opacity: enabled ? 1.0 : 0.33
    }
}
