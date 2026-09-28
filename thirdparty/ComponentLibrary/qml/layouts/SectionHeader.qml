import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Templates as T
import QtQuick.Controls.impl

import ComponentLibrary

Item {
    id: control

    anchors.left: parent.left
    anchors.right: parent.right

    implicitWidth: 1024
    height: Theme.componentHeightXXL
    z: 2

    // settings
    property bool shadow: !Theme.singleColumn
    property int headerPosition: 64
    property int radius: Theme.singleColumn ? 0 : 6
    property int borderWidth: Theme.singleColumn ? 0 : Theme.componentBorderWidth

    // colors
    property color backgroundColor: Qt.darker(Theme.colorForeground, Theme.isLight ? 0.72 : 1.24)
    property color borderColor: Qt.darker(Theme.colorComponentBorder, Theme.isLight ? 1.0 : 1.32)
    property color shadowColor: Theme.colorComponentShadow

    // icon
    property url source
    property int sourceSize: 32
    property int sourceRotation: 0
    property color sourceColor: Theme.colorIcon

    // text
    property string text: "title"
    property color textColor: Theme.colorText
    property int textSize: source.length ? Theme.fontSizeContentBig : Theme.fontSizeContentVeryBig
    property bool textBold: false

    // dynamic content
    default property alias dynamicContent: rightContentRow.data

    ////////////////

    Rectangle { // background
        id: background
        anchors.fill: parent

        radius: control.radius
        color: control.backgroundColor
        border.width: Theme.singleColumn ? 0 : Theme.componentBorderWidth
        border.color: control.borderColor

        ////////

        Item { // header
            anchors.fill: parent
            anchors.margins: parent.border.width

            Row {
                id: rightContentRow

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 0

                // dynamic content added here
            }

            layer.enabled: true
            layer.effect: MultiEffect { // mask
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: 0
                        y: 0
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }

        ////////

        layer.enabled: control.shadow
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: control.shadowColor
        }

        ////////
    }

    ////////////////

    Item { // content
        anchors.fill: parent

        RowLayout { // left row
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMarginL

            IconSvg {
                Layout.preferredWidth: control.sourceSize
                Layout.preferredHeight: control.sourceSize
                Layout.alignment: Qt.AlignVCenter

                fillMode: Image.PreserveAspectFit
                color: Theme.colorIcon
                source: control.source
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                text: control.text
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContentVeryBig
                wrapMode: Text.Wrap
            }
        }
    }

    ////////////////
}
