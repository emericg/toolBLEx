pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

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
    property int borderWidth: 1
    property int borderWidthHovered: 2
    property color shadowColor: Theme.colorComponentShadow

    // Hover feedback options, combinable as flags (ex: Border | Zoom):
    // - None: the card stays static on hover.
    // - Shadow: the drop shadow blooms a little stronger.
    // - Border: the border turns to borderWidthHovered and fades to borderColorHovered.
    // - Tint: the surface and the media fade to a rippleColor tint, under the content.
    // - Zoom: the whole card grows slightly, and shrinks slightly while pressed.
    enum HoverEffect { None = 0, Shadow = 1, Border = 2, Tint = 4, Zoom = 8 }
    property int hoverEffect: MediaCardBackground.HoverEffect.Shadow

    // Press feedback: an ink ripple over the surface and the media, under the content,
    // from the press position on the card, or on its action button (ex: the primary button of its CardActionRow)
    property color rippleColor: Qt.alpha(Theme.colorPrimary, 0.12)
    property T.AbstractButton actionButton: null

    // Card hover state (desktop only)
    readonly property bool hovered: hoverHandler.hovered

    // Show the hover effects without the pointer over the card, ex: while something it opens is hovered
    property bool highlighted: false

    // Card hovered or highlighted: the hover effects are shown
    readonly property bool lit: control.hovered || control.highlighted

    // Card pressed state, on its background or on its action button
    readonly property bool pressed: cardMouseArea.pressed || (control.actionButton?.pressed === true)

    readonly property bool hoverShadow: control.lit && (control.hoverEffect & MediaCardBackground.HoverEffect.Shadow)
    readonly property bool hoverBorder: control.lit && (control.hoverEffect & MediaCardBackground.HoverEffect.Border)
    readonly property bool hoverTint: control.lit && (control.hoverEffect & MediaCardBackground.HoverEffect.Tint)
    readonly property bool hoverZoom: (control.hoverEffect & MediaCardBackground.HoverEffect.Zoom) !== 0

    // Card background clicked
    signal clicked()

    scale: !control.hoverZoom ? 1 : (control.pressed ? 0.98 : (control.lit ? 1.02 : 1))
    Behavior on scale { NumberAnimation { duration: Theme.animationSpeedFast } }

    ////////

    HoverHandler {
        id: hoverHandler
        enabled: Theme.isDesktop
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

            RippleThemed {
                anchors.fill: parent
                anchor: (control.actionButton?.pressed === true) ? control.actionButton : cardMouseArea
                active: control.hoverTint
                color: control.rippleColor
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
            shadowBlur: control.hoverShadow ? 1.0 : 0.5
            Behavior on shadowBlur { NumberAnimation { duration: Theme.animationSpeedFast } }
        }
    }

    MouseArea { // card clicks, under the content so that its controls get their own
        id: cardMouseArea
        anchors.fill: parent
        onClicked: control.clicked()
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
        border.width: control.hoverBorder ? control.borderWidthHovered : control.borderWidth
        border.color: control.hoverBorder ? control.borderColorHovered : control.borderColor
        Behavior on border.color { ColorAnimation { duration: Theme.animationSpeedFast } }
    }

    ////////////////
}
