import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import QtQuick.Templates as T
import QtQuick.Controls.impl

import ComponentLibrary

Item {
    id: control

    implicitWidth: 640
    implicitHeight: 480

    ////////////////

    property string text: "text"
    property string subtext: "subtext"

    property url source

    property string btnText: "text"
    property url btnSource: "qrc:/IconLibrary/material-icons/duotone/touch_app.svg"

    signal clicked()
    signal actionClicked()

    ////////////////

    T.AbstractButton {
        id: backgroundButton

        anchors.fill: parent
        anchors.margins: (singleColumn ? 0 : Theme.componentMarginXL)
        anchors.bottomMargin: (singleColumn ? Theme.componentMarginXL : Theme.componentMarginXL)

        ////////

        onClicked: {
            control.clicked()
        }
        onPressAndHold: {
            if (isMobile) {
                actionMenu_bottom_loader.active = true
                actionMenu_bottom_loader.item.open()
            }
        }

        ////////

        background: Rectangle {
            id: background
            radius: {
                if (singleColumn) return 8
                if (isDesktop) return 8
                if (isTablet) return 12
                return 8
            }
            color: Theme.isLight ? "#fff" : "#444"

            Rectangle { // image background
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                //width: cardImage.width + rowrowrow.leftMargin*2
                width: cardImage.width + (isMobile ? 20 : 32)
                color: Theme.isLight ? "#f6f6f6" : "#3a3a3a"
            }

            RippleThemed {
                anchors.fill: parent
                anchor: backgroundButton

                pressed: backgroundButton.pressed
                active: control.enabled && (backgroundButton.down /*|| backgroundButton.hovered*/ || backgroundButton.visualFocus)
                color: Theme.colorPrimary
                opacity: 0.033
            }

            layer.enabled: true
            layer.effect: MultiEffect { // clip
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }

        ////////

        SquareButtonFlat {
            id: menuButton
            anchors.top: background.top
            anchors.right: background.right
            anchors.margins: 8

            color: Theme.isLight ? "#f8f8f8" : "#3a3a3a"
            colorHighlight: Qt.darker(color, 1.2)
            colorIcon: Theme.colorSubText

            source: "qrc:/IconLibrary/material-symbols/more_vert.svg"

            visible: isDesktop

            onClicked: {
                if (isMobile) {
                    actionMenu_bottom_loader.active = true
                    actionMenu_bottom_loader.item.open()
                } else {
                    actionMenu_floating_loader.active = true
                    actionMenu_floating_loader.item.open()
                }
            }
        }

        ////////

        RowLayout {
            id: rowrowrow
            anchors.fill: background
            anchors.leftMargin: (isMobile ? 20 : 32) / 2
            anchors.rightMargin: (isMobile ? 20 : 32) / 2
            spacing: 32
            clip: true

            ////

            Image {
                id: cardImage
                Layout.maximumWidth: Layout.maximumHeight * 0.66
                Layout.maximumHeight: background.height - (isMobile ? 20 : 32)
                Layout.alignment: Qt.AlignVCenter

                rotation: 0
                fillMode: Image.PreserveAspectFit

                source: control.source
                //sourceSize: Qt.size(width*mmm, height*mmm)
                //property int mmm: isMobile ? 2 : 1
            }

            ////

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Text { // text
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: control.text
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeTitle
                    fontSizeMode: Text.Fit
                    minimumPixelSize: Theme.fontSizeContent
                }

                Text { // subtext
                    text: control.subtext
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentVeryBig
                }

                ButtonChip {
                    height: 32

                    text: control.btnText
                    leftIcon: control.btnSource
                    color: Theme.colorOrange

                    onClicked: {
                        //
                    }
                }
            }

            ////
        }

        ////////

        layer.enabled: true
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#22000000" : "#50000000"
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    ListModel {
        id: lmCardActions
        ListElement { t: "itm"; idx: 0; txt: "Delete"; src: "qrc:/IconLibrary/material-symbols/delete.svg"; }
    }

    Loader {
        id: actionMenu_floating_loader
        active: false
        asynchronous: false
        sourceComponent: ActionMenu_floating {
            parent: menuButton.background
            x: -width + menuButton.width
            width: 220

            //titleTxt: qsTr("Close menu")
            //titleSrc: "qrc:/IconLibrary/material-symbols/close.svg"
            layoutDirection: Qt.RightToLeft

            model: lmCardActions
            onMenuSelected: (index) => {
                console.log("ActionMenu clicked #" + index)
            }
        }
    }
    Loader {
        id: actionMenu_bottom_loader
        active: false
        asynchronous: false
        sourceComponent: ActionMenu_bottom {
            //titleTxt: qsTr("Actions")
            model: lmCardActions
            onMenuSelected: (index) => {
                console.log("ActionMenu clicked #" + index)
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
