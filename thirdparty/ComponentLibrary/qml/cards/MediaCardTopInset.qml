pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

import ComponentLibrary

MediaCardBackground {
    id: control

    implicitWidth: 340
    implicitHeight: control.inset * 2 + control.mediaHeight + Theme.componentMarginS + fgColumn.implicitHeight

    signal primaryClicked()
    signal secondaryClicked()

    ////////////////

    // Textual content
    property string title: "Title"
    property string description: "Description"

    // Optional pill tag (a colored dot plus a label); hidden when tagText is empty.
    property string tagText: ""
    property color tagColor: Theme.colorPrimary

    // Two-button action row; the secondary button is hidden when its text is empty.
    property string primaryText: "Action"
    property string secondaryText: ""

    // Primary button style (CardActionRow.ButtonStyle), optional trailing icon,
    // and horizontal placement of the action row (Qt.AlignLeft or Qt.AlignRight).
    property int primaryStyle: CardActionRow.ButtonStyle.Solid
    property url primarySource
    property int primarySourceRotation: 0
    property int actionAlignment: Qt.AlignRight

    ////////

    // Drawing order // Gradient > Pattern > Image > Icon

    property real mediaHeight: 170
    property int inset: 8
    property int mediaRadius: 6

    property int gradientType: GradientPresets.Linear
    property var gradientStops: GradientPresets.lavender
    property real gradientAngle: 125

    property string pattern
    property int patternTileSize: 128
    property real patternOpacity: 0.12
    property color patternColor: "white"

    property url imageSource
    property int imageSize: Image.PreserveAspectCrop

    property url iconSource
    property int iconSize: 64
    property color iconColor: "white"

    readonly property bool hasImage: (control.imageSource.toString().length > 0)
    readonly property bool hasIcon: (control.iconSource.toString().length > 0)

    ////////////////

    media: Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: control.inset
        height: control.mediaHeight

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

    Column {
        id: fgColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: control.inset
        anchors.rightMargin: control.inset
        anchors.topMargin: control.inset + control.mediaHeight + Theme.componentMarginS
        spacing: Theme.componentMarginS

        Column { // body text
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.componentMarginXS
            anchors.rightMargin: Theme.componentMarginXS
            spacing: Theme.componentMarginXXS

            CardTagLabel {
                visible: (control.tagText.length > 0)
                text: control.tagText
                dotColor: control.tagColor
            }

            Text {
                width: parent.width
                text: control.title
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContentVeryBig
                font.weight: Font.DemiBold
                font.letterSpacing: -0.5
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: control.description
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContent
                lineHeight: 1.1
                wrapMode: Text.WordWrap
            }
        }

        CardActionRow {
            x: Theme.componentMarginXS
            anchors.right: (control.actionAlignment === Qt.AlignRight) ? parent.right : undefined
            anchors.rightMargin: Theme.componentMarginXS

            topPadding: Theme.componentMarginXXS
            primaryText: control.primaryText
            primaryStyle: control.primaryStyle
            primarySource: control.primarySource
            primarySourceRotation: control.primarySourceRotation
            secondaryText: control.secondaryText
            onPrimaryClicked: control.primaryClicked()
            onSecondaryClicked: control.secondaryClicked()
        }
    }

    ////////////////
}
