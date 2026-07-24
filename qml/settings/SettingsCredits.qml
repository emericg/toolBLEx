import QtQuick

import ComponentLibrary

Column { // APP CREDITS

    width: 512
    spacing: 2

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorActionbar

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Third parties")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVeryBig
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorForeground

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXS
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("This application is made possible thanks to a couple of third party open source projects:")
            textFormat: Text.PlainText
            color: Theme.colorText
            font.pixelSize: Theme.fontSizeContent
            wrapMode: Text.WordWrap
        }
    }

    ////////

    Repeater {
        model: ListModel {
            ListElement { txt: "Qt6"; license: "LGPL v3"; link: "https://qt.io" }
            ListElement { txt: "SingleApplication"; license: "MIT"; link: "https://github.com/itay-grudev/SingleApplication" }
            ListElement { txt: "Bootstrap Icons"; license: "MIT"; link: "https://icons.getbootstrap.com/" }
            ListElement { txt: "Google Material Icons"; license: "Apache 2.0"; link: "https://fonts.google.com/icons" }
        }
        delegate: Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2

            Rectangle {
                width: parent.width * 0.66 - 1
                height: 32
                color: Theme.colorForeground

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMarginL
                    anchors.verticalCenter: parent.verticalCenter

                    text: "- " + txt
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                width: parent.width * 0.24 - 1
                height: 32
                color: Theme.colorForeground

                Text {
                    anchors.centerIn: parent

                    text: license
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                width: parent.width * 0.1 - 1
                height: 32
                color: Theme.colorForeground

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally(link)
                    hoverEnabled: true

                    IconSvg {
                        anchors.centerIn: parent
                        width: 20
                        height: 20

                        source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                        color: parent.containsMouse ? Theme.colorPrimary : Theme.colorText
                        Behavior on color { ColorAnimation { duration: 133 } }
                    }
                }
            }
        }
    }

    ////////
}
