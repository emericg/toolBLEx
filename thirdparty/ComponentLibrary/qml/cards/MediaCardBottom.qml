import QtQuick

import ComponentLibrary

MediaCardBackground {
    id: control

    implicitWidth: 380
    implicitHeight: bodyColumn.implicitHeight + control.mediaHeight

    signal primaryClicked()
    signal secondaryClicked()

    ////////////////

    property string title: "Title"
    property string description: "Description"

    // Optional pill tag
    property string tagText: ""
    property color tagColor: Theme.colorPrimary

    // Action row
    property int actionAlignment: Qt.AlignRight
    property string primaryText: "Action"
    property int primaryStyle: CardActionRow.ButtonStyle.Solid
    property url primarySource
    property int primarySourceRotation: 0
    property string secondaryText: "" // hidden when empty

    ////////

    // Drawing order // Gradient > Pattern > Image > Icon

    property real mediaHeight: 110 //control.height * 0.25

    property int gradientType: GradientPresets.Linear
    property var gradientStops: GradientPresets.mango
    property real gradientAngle: 100

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
        anchors.bottom: parent.bottom
        height: control.mediaHeight

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

    Column {
        id: bodyColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        padding: Theme.componentMarginL
        spacing: Theme.componentMarginXS

        CardTagLabel {
            visible: (control.tagText.length > 0)
            text: control.tagText
            dotColor: control.tagColor
        }

        Text {
            width: parent.width - parent.padding * 2
            text: control.title
            textFormat: Text.PlainText
            color: Theme.colorText
            font.pixelSize: Theme.fontSizeContentVeryBig
            font.weight: Font.DemiBold
            font.letterSpacing: -0.5
            wrapMode: Text.WordWrap
        }

        Text {
            width: parent.width - parent.padding * 2
            text: control.description
            textFormat: Text.PlainText
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContent
            lineHeight: 1.1
            wrapMode: Text.WordWrap
        }

        CardActionRow {
            anchors.right: (control.actionAlignment === Qt.AlignRight) ? parent.right : undefined
            anchors.rightMargin: parent.padding

            topPadding: Theme.componentMarginXS
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
