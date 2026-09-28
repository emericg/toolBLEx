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
    height: _contentShown ? contentArea.height : headerHeight
    Behavior on height { NumberAnimation { duration: Theme.animationSpeedMedium } }

    property bool _contentShown: false

    // settings
    property int headerHeight: Theme.componentHeightXXL
    property int headerPosition: 64

    property int radius: Theme.singleColumn ? 0 : 6
    property int borderWidth: Theme.singleColumn ? 0 : Theme.componentBorderWidth
    property bool shadow: !Theme.singleColumn

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
    property string text: "Title"
    property string textShow: "Show more"
    property color textColor: Theme.colorText
    property int textSize: source.length ? Theme.fontSizeContentBig : Theme.fontSizeContentVeryBig
    property bool textBold: false

    // dynamic content
    default property alias dynamicContent: contentArea.data

    ////////////////

    Rectangle {
        id: background
        anchors.fill: parent

        radius: control.radius
        color: control.backgroundColor
        border.width: control.borderWidth
        border.color: control.borderColor

        ////////

        Item { // header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: control.borderWidth
            height: control.headerHeight - control.borderWidth*2

            ////

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: control._contentShown = !control._contentShown
            }

            ////

            Rectangle { // right button
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                width: Math.max(256, rowExpand.width + Theme.componentMargin*2)
                color: mouseArea.containsPress ?
                           Qt.darker(Theme.isLight ? "#f6f6f6" : "#3a3a3a", 1.05) :
                           Theme.isLight ? "#f6f6f6" : "#3a3a3a"

                Row {
                    id: rowExpand
                    anchors.centerIn: parent
                    spacing: Theme.componentMargin

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: control.textShow
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }

                    IconSvg {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28

                        fillMode: Image.PreserveAspectFit
                        color: Theme.colorSubText
                        source: "qrc:/IconLibrary/material-symbols/arrow_drop_down.svg"
                        rotation: control._contentShown ? 180 : 0
                    }
                }
            }

            ////

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

            ////
        }

        ////////////////

        Item { // header content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: headerHeight

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

        ////////

        Item { // dynamic content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: control.borderWidth

            height: parent.height
            clip: true

            Column {
                id: contentArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: control.headerHeight
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
}
