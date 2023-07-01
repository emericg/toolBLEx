import QtQuick 2.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: control
    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    width: compact ? height : (contentRow.width + 12 + ((source.toString().length && !text) ? 0 : 16))
    Behavior on width { NumberAnimation { duration: 133 } }

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // settings
    property bool compact: false
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property int layoutDirection: Qt.LeftToRight

    // colors
    property string textColor: Theme.colorText
    property string iconColor: Theme.colorIcon
    property string backgroundColor: Theme.colorComponent

    // animation
    property string animation // available: rotate, fade, both
    property bool animationRunning: false
    property bool hoverAnimation: (isDesktop && !compact)

    // text
    property string text

    // tooltip
    property string tooltipText
    property string tooltipPosition: "bottom"

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: (isDesktop && control.enabled)

        onClicked: control.clicked()
        onPressed: {
            control.pressed()
            mouseBackground.width = (control.width * 2)
        }
        onPressAndHold: control.pressAndHold()

        //onReleased: mouseBackground.width = 0 // let the click expand the ripple
        onEntered: mouseBackground.width = 72
        onExited: mouseBackground.width = 0
        onCanceled: mouseBackground.width = 0
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: control

        radius: control.compact ? (control.height / 2) : Theme.componentRadius
        color: control.backgroundColor
        opacity: (!control.compact || mouseArea.containsMouse) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 333 } }

        Rectangle {
            id: mouseBackground
            width: 0; height: width; radius: width;
            x: mouseArea.mouseX - (width / 2)
            y: mouseArea.mouseY - (width / 2)

            visible: !control.compact
            color: "white"
            opacity: mouseArea.containsMouse ? 0.16 : 0
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

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: contentRow
        anchors.centerIn: control
        spacing: 8
        layoutDirection: control.layoutDirection

        IconSvg {
            id: contentImage
            width: control.sourceSize
            height: control.sourceSize
            anchors.verticalCenter: parent.verticalCenter

            opacity: enabled ? 1.0 : 0.4
            Behavior on opacity { NumberAnimation { duration: 333 } }

            source: control.source
            color: control.iconColor

            SequentialAnimation on opacity {
                running: (control.animationRunning &&
                          (control.animation === "fade" || control.animation === "both"))
                alwaysRunToEnd: true
                loops: Animation.Infinite

                PropertyAnimation { to: 0.5; duration: 666; }
                PropertyAnimation { to: 1; duration: 666; }
            }
            NumberAnimation on rotation {
                running: (control.animationRunning &&
                          (control.animation === "rotate" || control.animation === "both"))
                alwaysRunToEnd: true
                loops: Animation.Infinite

                duration: 1500
                from: 0
                to: 360
                easing.type: Easing.Linear
            }
        }

        Text {
            id: contentText
            anchors.verticalCenter: parent.verticalCenter
            visible: !control.compact

            opacity: enabled ? 1.0 : 0.4
            Behavior on opacity { NumberAnimation { duration: 333 } }

            text: control.text
            textFormat: Text.PlainText
            color: control.iconColor
            font.pixelSize: Theme.componentFontSize
            font.bold: true
            elide: Text.ElideRight
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        anchors.fill: control
        active: control.tooltipText && (control.compact || !control.text)

        sourceComponent: ToolTipFlat {
            visible: mouseArea.containsMouse
            text: control.tooltipText
            textColor: control.textColor
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.backgroundColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
