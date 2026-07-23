import QtQuick

import ComponentLibrary
import AppUtils

Column { // APP INFO

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

            text: qsTr("System info")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVeryBig
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 2

        Rectangle {
            width: parent.width * 0.666 - 1
            height: 32
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: {
                    var txt = UtilsSysInfo.getOsName()
                    if (UtilsSysInfo.getOsVersion() !== "unknown")
                    {
                        if (txt.length) txt += " "
                        txt += UtilsSysInfo.getOsVersion()
                    }
                    return txt
                }

                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            width: parent.width * 0.334 - 1
            height: 32
            color: Theme.colorForeground

            Text {
                anchors.centerIn: parent

                text: {
                    var txt = UtilsSysInfo.getOsDisplayServer()
                    if (txt.length) txt += " / "
                    txt += UtilsApp.qtRhiBackend()
                    return txt
                }
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
            }
        }
    }

    ////

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 2

        Rectangle {
            width: parent.width * 0.666 - 1
            height: 32
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: "Qt version"
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            width: parent.width * 0.334 - 1
            height: 32
            color: Theme.colorForeground

            Text {
                anchors.centerIn: parent

                text: UtilsApp.qtVersion()
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
            }
        }
    }

    ////

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 2

        Rectangle {
            width: parent.width * 0.666 - 1
            height: 32
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: "Qt architecture"
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            width: parent.width * 0.334 - 1
            height: 32
            color: Theme.colorForeground

            Text {
                anchors.centerIn: parent

                text: UtilsApp.qtArchitecture()
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
            }
        }
    }

    ////////
}
