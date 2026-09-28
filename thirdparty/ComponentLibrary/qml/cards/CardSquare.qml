pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    implicitWidth: 256
    implicitHeight: 280

    ////////////////

    // Top Left icon
    property url source
    property color iconColor: (control.gradientStops.length > 0)
                              ? control.gradientStops[control.gradientStops.length - 1].color
                              : Theme.colorPrimary

    // Texts
    property string text: "0%"
    property string legend: "Legend"

    // Tag
    property string tagText: ""
    property url tagIcon: "qrc:/ComponentLibraryAssets/icons/label.svg"
    property color tagColor: "#86efac"

    // Footer action bar
    property int footerHeight: 40
    property color footerColor: "#0a0a0a"
    property string footerText: "Action"
    property color footerTextColor: "white"

    ////////

    // Colored panel, painted by a gradient with a tileable texture fading from the top left corner.
    property int gradientType: GradientPresets.Linear
    property var gradientStops: GradientPresets.emerald
    property real gradientAngle: 135

    property url texture: "qrc:/ComponentLibraryAssets/patterns/grid.svg"
    property int textureTileSize: 32
    property real textureOpacity: 0.12
    property color textureColor: "white"

    ////////

    property int radius: 14
    property int padding: 22

    signal primaryClicked()

    ////////////////

    Rectangle { // footer, also showing through the rounded bottom corners of the panel
        anchors.fill: parent
        radius: control.radius
        color: control.footerColor
    }

    Item { // colored panel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: control.height - control.footerHeight

        GradientComponent {
            anchors.fill: parent
            radius: control.radius

            type: control.gradientType
            stops: control.gradientStops
            angle: control.gradientAngle

            texture: control.texture
            textureTileSize: control.textureTileSize
            textureOpacity: control.textureOpacity
            textureColor: control.textureColor
        }
    }

    ////////////////

    Item { // foreground
        anchors.fill: parent

        ////////

        Rectangle { // icon badge
            x: control.padding
            y: control.padding
            width: 46
            height: 46
            radius: 8
            color: "white"

            visible: (control.source.toString().length > 0)

            IconSvg {
                anchors.centerIn: parent
                width: 24
                height: 24

                source: control.source
                color: control.iconColor
            }
        }

        ////////

        Column { // text + legend
            anchors.left: parent.left
            anchors.leftMargin: control.padding
            anchors.right: parent.right
            anchors.rightMargin: control.padding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: control.footerHeight + control.padding
            spacing: 6

            Text {
                width: parent.width
                text: control.text
                textFormat: Text.PlainText
                color: "white"
                font.pixelSize: Math.round(Theme.fontSizeTitle * 1.4)
                font.weight: Font.Medium
                font.letterSpacing: -0.5
                elide: Text.ElideRight
            }

            Row {
                width: parent.width
                spacing: 8

                CardTagClearIcon { // tag
                    id: trendTag
                    anchors.verticalCenter: parent.verticalCenter
                    height: 22

                    visible: (control.tagText.length > 0)
                    text: control.tagText
                    source: control.tagIcon
                    color: "white"
                    colorIcon: control.tagColor
                    colorBackground: Qt.rgba(0, 0, 0, 0.16)
                    radius: 4
                    font.pixelSize: Theme.fontSizeContentSmall
                    font.weight: Font.Medium
                }

                Text { // legend
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (trendTag.visible ? trendTag.width + parent.spacing : 0)

                    visible: (control.legend.length > 0)
                    text: control.legend
                    textFormat: Text.PlainText
                    color: Qt.rgba(1, 1, 1, 0.8)
                    font.pixelSize: Theme.fontSizeContentSmall
                    elide: Text.ElideRight
                }
            }
        }

        ////////

        MouseArea { // footer action
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: control.footerHeight

            hoverEnabled: Theme.isDesktop
            cursorShape: Qt.PointingHandCursor
            onClicked: control.primaryClicked()

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: footerArrow.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                text: control.footerText
                textFormat: Text.PlainText
                color: control.footerTextColor
                font.pixelSize: Theme.fontSizeContentSmall
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            IconSvg {
                id: footerArrow
                anchors.right: parent.right
                anchors.rightMargin: footer.containsMouse ? 8 : 12
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20

                source: "qrc:/ComponentLibraryAssets/icons/chevron_right.svg"
                color: control.footerTextColor

                Behavior on anchors.rightMargin { NumberAnimation { duration: Theme.animationSpeedFast } }
            }
        }

        ////////
    }

    ////////////////
}
