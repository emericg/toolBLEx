import QtQuick

import ComponentLibrary

MediaCardBackground {
    id: control

    implicitWidth: 470
    implicitHeight: Math.max(control.minMediaHeight, body.implicitHeight, actionRow.implicitHeight)
                    + control.padding * 2

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

    property real mediaWidth: 96
    property int minMediaHeight: 48
    property int padding: Theme.componentMargin

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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: control.mediaWidth

        GradientComponent {
            anchors.fill: parent
            visible: !control.hasImage

            type: control.gradientType
            stops: control.gradientStops
            angle: control.gradientAngle

            texturePattern: control.pattern
            textureTileSize: control.patternTileSize
            textureColor: control.patternColor
            textureOpacity: control.patternOpacity
        }
        Image {
            anchors.fill: parent
            visible: control.hasImage

            source: control.imageSource
            fillMode: control.imageSize
            asynchronous: true
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

    Column { // body
        id: body
        anchors.left: parent.left
        anchors.leftMargin: control.mediaWidth + Theme.componentMarginL
        anchors.right: actionRow.left
        anchors.rightMargin: Theme.componentMarginS
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

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
            font.pixelSize: Theme.fontSizeContentBig
            font.weight: Font.DemiBold
            font.letterSpacing: -0.5
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: control.description
            textFormat: Text.PlainText
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
            elide: Text.ElideRight
        }
    }

    CardActionRow {
        id: actionRow
        anchors.right: parent.right
        anchors.rightMargin: control.padding
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
