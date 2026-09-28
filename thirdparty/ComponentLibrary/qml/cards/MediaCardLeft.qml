import QtQuick

import ComponentLibrary

MediaCardBackground {
    id: control

    implicitWidth: 500
    implicitHeight: 190

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

    property real mediaWidth: 160

    property int gradientType: GradientPresets.Linear
    property var gradientStops: GradientPresets.forest
    property real gradientAngle: 160

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

    Column { // body text
        anchors.left: parent.left
        anchors.leftMargin: control.mediaWidth + Theme.componentMarginL
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginL
        anchors.top: parent.top
        anchors.topMargin: Theme.componentMarginL
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
            font.pixelSize: Theme.fontSizeContentSmall
            lineHeight: 1.1
            wrapMode: Text.WordWrap
        }
    }

    CardActionRow { // pinned to the bottom of the body area
        anchors.left: (control.actionAlignment === Qt.AlignRight) ? undefined : parent.left
        anchors.leftMargin: control.mediaWidth + Theme.componentMarginL
        anchors.right: (control.actionAlignment === Qt.AlignRight) ? parent.right : undefined
        anchors.rightMargin: Theme.componentMarginL
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.componentMarginL

        primaryText: control.primaryText
        primaryStyle: control.primaryStyle
        primarySource: control.primarySource
        primarySourceRotation: control.primarySourceRotation
        secondaryText: control.secondaryText
        onPrimaryClicked: control.primaryClicked()
        onSecondaryClicked: control.secondaryClicked()
    }

    ////////////////
}
