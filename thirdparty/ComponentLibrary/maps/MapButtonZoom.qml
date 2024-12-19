import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    signal mapZoomIn()
    signal mapZoomOut()

    property int zoomLevel
    property int zoomLevel_minimum
    property int zoomLevel_maximum

    // image
    property int sourceSize: UtilsNumber.alignTo(width * 0.5, 2)

    // settings
    property int radius: width * 0.28
    property string hoverMode: "off" // available: off
    property string highlightMode: "off" // available: off

    // colors
    property color iconColor: Theme.colorIcon
    property color highlightColor: Theme.colorComponent
    property color borderColor: Theme.colorSeparator
    property color backgroundColor: Theme.colorLowContrast

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle { // background_alpha_border
            anchors.fill: parent
            anchors.margins: isPhone ? -2 : -3
            radius: control.radius
            color: control.borderColor
            opacity: 0.66

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: "#66000000"
            }
        }
        Rectangle { // background
            anchors.fill: parent
            radius: control.radius
            color: control.backgroundColor
        }

        Item {
            id: bglayer
            anchors.fill: parent

            Rectangle { // button1_bg
                anchors.top: parent.top
                width: parent.width
                height: parent.width

                color: control.highlightColor
                opacity: button1_ma.containsMouse ? 0.66 : 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
            }
            Rectangle { // button2_bg
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.width

                color: control.highlightColor
                opacity: button2_ma.containsMouse ? 0.66 : 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: bglayer.x
                        y: bglayer.y
                        width: bglayer.width
                        height: bglayer.height
                        radius: control.radius
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: Item {
        MouseArea {
            id: button1_ma
            anchors.top: parent.top

            width: parent.width
            height: parent.width

            hoverEnabled: control.zoomLevel < control.zoomLevel_maximum
            enabled: control.zoomLevel < control.zoomLevel_maximum

            onClicked: control.mapZoomIn()

            IconSvg {
                anchors.centerIn: parent

                width: control.sourceSize
                height: control.sourceSize

                opacity: control.zoomLevel < control.zoomLevel_maximum ? 1 : 0.4
                Behavior on opacity { NumberAnimation { duration: 333 } }

                color: control.iconColor
                source: "qrc:/IconLibrary/material-symbols/add.svg"
            }
        }
        MouseArea {
            id: button2_ma
            anchors.bottom: parent.bottom

            width: parent.width
            height: parent.width

            hoverEnabled: control.zoomLevel > control.zoomLevel_minimum
            enabled: control.zoomLevel > control.zoomLevel_minimum

            onClicked: control.mapZoomOut()

            IconSvg {
                anchors.centerIn: parent

                width: control.sourceSize
                height: control.sourceSize

                opacity: control.zoomLevel > control.zoomLevel_minimum ? 1 : 0.4
                Behavior on opacity { NumberAnimation { duration: 333 } }

                color: control.iconColor
                source: "qrc:/IconLibrary/material-symbols/remove.svg"
            }
        }
    }

    ////////////////
}
