pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    implicitWidth: 360
    implicitHeight: 240

    ////////

    // Media slot: clipped to the rounded corners and casting the drop shadow
    property alias media: mediaContainer.data

    // Content slot: texts and buttons
    default property alias content: contentContainer.data

    ////////

    // Rounded surface styling:
    property int radius: 10
    property color surfaceColor: Theme.colorComponentBackground
    property color borderColor: Theme.colorComponentBorder
    property color borderColorHovered: Theme.colorPrimary
    property color shadowColor: Theme.colorComponentShadow

    // Hover feedback options:
    // - None: the card stays static on hover.
    // - Shadow: the drop shadow blooms a little stronger.
    // - Border: the border thickens and turns to borderColorHovered.
    enum HoverEffect { None, Shadow, Border }
    property int hoverEffect: MediaCardBackground.HoverEffect.Shadow

    // Card hover state (desktop only)
    readonly property bool hovered: hoverHandler.hovered

    // Card background clicked
    signal clicked()

    ////////

    HoverHandler {
        id: hoverHandler
        enabled: Theme.isDesktop
    }

    TapHandler {
        onTapped: control.clicked()
    }

    ////////////////

    Item { // background
        anchors.fill: parent

        Rectangle {
            id: surface
            anchors.fill: parent

            radius: control.radius
            color: control.surfaceColor

            Item { // media
                id: mediaContainer
                anchors.fill: parent
            }

            layer.enabled: true
            layer.effect: MultiEffect { // clip
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: surface.width
                        height: surface.height
                        radius: surface.radius
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: control.shadowColor
            shadowVerticalOffset: 0
            shadowBlur: (control.hoverEffect === MediaCardBackground.HoverEffect.Shadow && control.hovered) ? 1.0 : 0.5
            Behavior on shadowBlur { NumberAnimation { duration: Theme.animationSpeedFast } }
        }
    }

    Item { // content
        id: contentContainer
        anchors.fill: parent
    }

    ////////////////

    Rectangle { // border overlay
        anchors.fill: parent

        radius: control.radius
        color: "transparent"
        border.width: (control.hoverEffect === MediaCardBackground.HoverEffect.Border && control.hovered) ? 2 : 1
        border.color: (control.hoverEffect === MediaCardBackground.HoverEffect.Border && control.hovered)
                      ? control.borderColorHovered : control.borderColor
        Behavior on border.color { ColorAnimation { duration: Theme.animationSpeedFast } }
    }

    ////////////////
}
