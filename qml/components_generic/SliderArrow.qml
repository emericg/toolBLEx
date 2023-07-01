import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Slider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight

    padding: 8
    topPadding: 10

    value: 0.5
    snapMode: T.RangeSlider.SnapAlways

    // colors
    property string colorBg: Theme.colorForeground
    property string colorFg: Theme.colorPrimary
    property string colorTxt: "white"

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: control.colorBg
        clip: true

        property int ticksCount: ((to - from) / stepSize)

        Repeater {
            width: control.availableWidth
            model: (background.ticksCount-1)
            Rectangle {
                x: ((control.availableWidth / background.ticksCount) * (index+1))
                width: 1; height: 4;
                color: Theme.colorComponentBorder
            }
        }

        Rectangle {
            width: (control.visualPosition * control.availableWidth) + 1
            height: parent.height
            radius: 2
            color: control.colorFg
/*
            clip: true

            Repeater {
                width: control.availableWidth
                model: (background.ticksCount-1)
                Rectangle {
                    x: (((control.availableWidth) / background.ticksCount) * (index+1))
                    width: 1; height: 4;
                    color: Theme.colorComponentBackground
                }
            }
*/
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    handle: Rectangle {
        x: control.leftPadding + Math.round((control.visualPosition * control.availableWidth) - (width / 2))
        y: 0
        width: 16
        height: 12

        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary
/*
        Text {
            anchors.fill: parent
            y: 2

            text: control.value.toFixed(1)
            font.pixelSize: 8
            font.bold: true
            color: control.colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
*/
        Rectangle {
            width: 10
            height: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom

            z: -1
            rotation: 45
            color: parent.color
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
