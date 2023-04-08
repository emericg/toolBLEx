import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeEngine 1.0

Loader {
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0

    width: active ? 138 : 0
    height: active ? 28 : 0

    active: (settingsManager.appThemeCSD && Qt.platform.os === "windows")
    asynchronous: true

    sourceComponent: Row {
        id: csdWindows
        spacing: 0

        ////////

        Rectangle { // button minimize
            width: 46; height: 28;
            color: mouseAreaMin.containsMouse ? "#33aaaaaa" : "transparent"

            Rectangle {
                width: 10; height: 1;
                anchors.centerIn: parent
                color: mouseAreaMin.containsMouse ? Theme.colorHighContrast : Theme.colorIcon
            }

            MouseArea {
                id: mouseAreaMin
                anchors.fill: parent

                hoverEnabled: true
                onClicked: appWindow.showMinimized()
            }
        }

        ////////

        Rectangle { // button maximize
            width: 46; height: 28;
            color: mouseAreaMax.containsMouse ? "#33aaaaaa" : "transparent"

            Rectangle {
                width: 10; height: 10;
                anchors.centerIn: parent
                color: "transparent"
                border.width: 1
                border.color: mouseAreaMax.containsMouse ? Theme.colorHighContrast : Theme.colorIcon
            }

            MouseArea {
                id: mouseAreaMax
                anchors.fill: parent

                hoverEnabled: true
                onClicked: {
                    if (appWindow.visibility === ApplicationWindow.Maximized)
                        appWindow.showNormal()
                    else
                        appWindow.showMaximized()
                }
            }
        }

        ////////

        Rectangle { // button close
            width: 46; height: 28;
            color: mouseAreaClose.containsMouse ? "red" : "transparent"

            IconSvg {
                width: 16; height: 16;
                anchors.centerIn: parent

                source: "qrc:/assets/icons_material/baseline-close-24px.svg"
                color: mouseAreaClose.containsMouse ? "white" : Theme.colorIcon
            }
/*
            Rectangle {
                width: 12; height: 1;
                anchors.centerIn: parent
                rotation: 45
                color: mouseAreaClose.containsMouse ? "white" : Theme.colorIcon
            }
            Rectangle {
                width: 12; height: 1;
                anchors.centerIn: parent
                rotation: -45
                color: mouseAreaClose.containsMouse ? "white" : Theme.colorIcon
            }
*/
            MouseArea {
                id: mouseAreaClose
                anchors.fill: parent

                hoverEnabled: true
                onClicked: appWindow.close()
            }
        }
    }
}
