import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import ComponentLibrary
import AppUtils

Item {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: {
        if (Theme.singleColumn) return 0
        return Theme.componentMarginXL -(Theme.singleColumn ? 0 : parent.width * 0.125)
    }
    anchors.right: parent.right
    anchors.rightMargin: {
        if (Theme.singleColumn) return 0
        return Theme.componentMarginXL -(Theme.singleColumn ? 0 : parent.width * 0.125)
    }

    height: Math.max(256, headerGrid.height)

    ////////////////////////////////////////////////////////////////////////////

    property color colorLight: "#f6f6f6"
    property color colorDark: "#3a3a3a"

    property color colorBackground: Theme.colorBackground
    property color colorForeground: Theme.colorForeground
    property color colorShadow: Theme.colorComponentShadow

    property url logo: ""
    property int logoSize: 80 // width/height in %

    property string description: ""

    property int btn_size: 160

    property string src_web: "qrc:/IconLibrary/material-symbols/link.svg"
    property string src_donate: "qrc:/IconLibrary/material-symbols/favorite.svg"
    property string src_support: "qrc:/IconLibrary/material-symbols/support.svg"
    property string src_repository: "qrc:/IconLibrary/fontawesome7/brands/github.svg"

    property string link_web: ""
    property string link_donate: ""
    property string link_support: ""
    property string link_repository: ""

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // background & shadow
        anchors.fill: parent

        radius: Theme.singleColumn ? 0 : 12
        color: control.colorBackground
        border.width: Theme.singleColumn ? 0 : Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder

        layer.enabled: !Theme.singleColumn
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: control.colorShadow
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    GridLayout { // content
        id: headerGrid
        anchors.left: parent.left
        anchors.right: parent.right

        rows: 2
        rowSpacing: -Theme.componentMarginL
        columns: Theme.singleColumn ? 1 : 2
        columnSpacing: 0

        ////////

        Rectangle {
            Layout.preferredWidth: Theme.singleColumn ? headerGrid.width : (headerGrid.width*0.48)
            Layout.minimumHeight: 256 - Theme.componentBorderWidth*2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.componentBorderWidth

            radius: 12
            color: control.colorForeground

            Image {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: parent.height - Theme.componentMarginXL*2

                fillMode: Image.PreserveAspectFit
                source: control.logo
                sourceSize: Qt.size(width*2, height*2)
            }
        }

        ////////

        Item {
            Layout.preferredWidth: Theme.singleColumn ? headerGrid.width
                                                      : headerGrid.width*0.56
            Layout.minimumHeight: 256

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.componentBorderWidth

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMarginXS

                ////

                Text { // title
                    text: UtilsApp.appName()
                    textFormat: Text.PlainText
                    font.bold: true
                    font.pixelSize: 32
                    color: Theme.colorText

                    Text {
                        anchors.left: parent.right
                        anchors.leftMargin: 8
                        anchors.baseline: parent.baseline

                        text: qsTr("version %1").arg(UtilsApp.appVersion())
                        textFormat: Text.PlainText
                        font.bold: true
                        font.pixelSize: 22
                        color: Theme.colorSubText
                    }
                }

                Text { // description
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: control.description
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                }

                Item { width: 16; height: 16; } // spacer

                ////

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    spacing: Theme.componentMargin

                    ButtonSolid {
                        width: control.btn_size
                        visible: control.link_web

                        text: qsTr("WEBSITE")
                        source: control.src_web
                        sourceSize: 26
                        onClicked: Qt.openUrlExternally(control.link_web)
                    }

                    ButtonSolid {
                        width: control.btn_size
                        visible: control.link_support

                        text: qsTr("SUPPORT")
                        source: control.src_support
                        sourceSize: 22
                        onClicked: Qt.openUrlExternally(control.link_support)
                    }

                    ButtonSolid {
                        width: control.btn_size
                        visible: control.link_repository && (parent.width > 520)

                        text: qsTr("GitHub")
                        source: control.src_repository
                        sourceSize: 24
                        onClicked: Qt.openUrlExternally(control.link_repository)
                    }

                    ButtonSolid {
                        width: control.btn_size
                        visible: control.link_donate && (parent.width > 720)

                        text: qsTr("Donate")
                        source: control.src_donate
                        sourceSize: 24
                        onClicked: Qt.openUrlExternally(control.link_donate)
                    }
                }

                ////
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
