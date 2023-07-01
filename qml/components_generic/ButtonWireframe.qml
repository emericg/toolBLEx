import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    font.pixelSize: Theme.componentFontSize
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    // colors
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground

    // animation
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mousearea
        anchors.fill: parent

        enabled: control.hoverAnimation
        hoverEnabled: control.hoverAnimation

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: {
            control.down = true
            mouseBackground.width = (control.width * 2)
        }
        onReleased: {
            control.down = false
            //mouseBackground.width = 0 // disabled, we let the click expand the ripple
        }
        onEntered: {
            mouseBackground.width = 72
        }
        onExited: {
            control.down = false
            mouseBackground.width = 0
        }
        onCanceled: {
            control.down = false
            mouseBackground.width = 0
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? (control.down && !control.hoverAnimation ? 0.8 : 1.0) : 0.4
        color: control.fullColor ? control.primaryColor : control.secondaryColor
        border.width: Theme.componentBorderWidth
        border.color: control.fullColor ? Qt.darker(color, 1.03) : Theme.colorComponentBorder

        Item {
            anchors.fill: parent

            Rectangle { // mouseBackground
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: mousearea.mouseX - (width / 2)
                y: mousearea.mouseY - (width / 2)

                visible: control.hoverAnimation
                color: "white"
                opacity: mousearea.containsMouse ? 0.16 : 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
                Behavior on width { NumberAnimation { duration: 200 } }
            }

            layer.enabled: control.hoverAnimation
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        elide: Text.ElideMiddle
        //wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: enabled ? (control.down && !control.hoverAnimation ? 0.8 : 1.0) : 0.66
        color: control.fullColor ? control.fulltextColor : control.primaryColor
    }
}
