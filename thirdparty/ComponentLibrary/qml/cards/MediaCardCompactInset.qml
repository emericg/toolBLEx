pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

import ComponentLibrary

MediaCardBackground {
    id: control

    actionButton: actionRow.primaryButton

    implicitWidth: 470
    implicitHeight: Math.max(control.mediaSize, body.textHeight, actionRow.implicitHeight)
                    + control.inset * 2

    signal primaryClicked()

    ////////////////

    property string title: "Title"
    property string description: "Description"

    // Optional pill tag
    property string tagText: ""
    property color tagColor: Theme.colorPrimary

    // Action row
    property string primaryText: "Action"
    property int primaryStyle: CardActionRow.ButtonStyle.Solid
    property url primarySource
    property int primarySourceRotation: 0
    property string secondaryText: "" // hidden when empty

    ////////

    // Drawing order // Gradient > Pattern > Image > Icon

    property real mediaSize: 72
    property int inset: 12                // padding between the card edge and its content
    property int mediaRadius: 6

    property int gradientType: GradientPresets.Linear
    property var gradientStops: GradientPresets.ember
    property real gradientAngle: 135

    property string pattern
    property int patternTileSize: 128
    property real patternOpacity: 0.12
    property color patternColor: "white"

    property url imageSource
    property int imageSize: Image.PreserveAspectCrop

    property url iconSource
    property int iconSize: 32
    property color iconColor: "white"

    readonly property bool hasImage: (control.imageSource.toString().length > 0)
    readonly property bool hasIcon: (control.iconSource.toString().length > 0)

    ////////////////

    media: Item {
        anchors.left: parent.left
        anchors.leftMargin: control.inset
        anchors.verticalCenter: parent.verticalCenter
        width: control.mediaSize
        height: control.mediaSize

        GradientComponent {
            anchors.fill: parent
            visible: !control.hasImage

            radius: control.mediaRadius
            type: control.gradientType
            stops: control.gradientStops
            angle: control.gradientAngle

            texturePattern: control.pattern
            textureTileSize: control.patternTileSize
            textureColor: control.patternColor
            textureOpacity: control.patternOpacity
        }
        Image {
            id: mediaImage
            anchors.fill: parent
            visible: control.hasImage

            source: control.imageSource
            fillMode: control.imageSize
            asynchronous: true

            layer.enabled: control.hasImage
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: mediaImage.width
                        height: mediaImage.height
                        radius: control.mediaRadius
                    }
                }
            }
        }
        IconSvg {
            anchors.centerIn: parent
            width: control.iconSize
            height: control.iconSize
            visible: control.hasIcon

            color: control.iconColor
            source: control.iconSource
            asynchronous: true
        }
    }

    ////////////////

    // Body: the texts wrap, and the card grows with them,
    // unless its height is set: they are then elided to fit it
    Column {
        id: body
        anchors.left: parent.left
        anchors.leftMargin: control.inset + control.mediaSize + Theme.componentMarginS
        anchors.right: actionRow.left
        anchors.rightMargin: Theme.componentMarginS
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        readonly property real tagHeight: tag.visible ? (tag.implicitHeight + body.spacing) : 0
        readonly property real textHeight: body.tagHeight + titleText.implicitHeight + body.spacing + descriptionText.implicitHeight
        readonly property real availableHeight: control.height - control.inset * 2

        CardTagLabel {
            id: tag
            visible: (control.tagText.length > 0)
            text: control.tagText
            dotColor: control.tagColor
        }

        Text {
            id: titleText
            width: parent.width
            height: Math.min(implicitHeight, Math.max(0, body.availableHeight - body.tagHeight))
            text: control.title
            textFormat: Text.PlainText
            color: Theme.colorText
            font.pixelSize: Theme.fontSizeContentBig
            font.weight: Font.DemiBold
            font.letterSpacing: -0.5
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }

        Text {
            id: descriptionText
            width: parent.width
            height: Math.min(implicitHeight, Math.max(0, body.availableHeight - body.tagHeight - titleText.height - body.spacing))
            visible: (height > 0)
            text: control.description
            textFormat: Text.PlainText
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
    }

    CardActionRow {
        id: actionRow
        anchors.right: parent.right
        anchors.rightMargin: control.inset
        anchors.verticalCenter: parent.verticalCenter

        buttonHeight: Theme.componentHeightS
        primaryText: control.primaryText
        primaryStyle: control.primaryStyle
        primarySource: control.primarySource
        primarySourceRotation: control.primarySourceRotation
        onPrimaryClicked: control.primaryClicked()
    }

    ////////////////
}
