import QtQuick
import QtQuick.Window
import QtQuick.Controls

import ComponentLibrary

pragma ComponentBehavior: Bound

Loader {
    id: csdWindowsLoader

    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0

    width: active ? 138 : 0
    height: active ? 28 : 0

    property bool appThemeCSD: false
    property ApplicationWindow windowInstance: null

    active: (windowInstance && appThemeCSD && Qt.platform.os === "windows")
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
                onClicked: csdWindowsLoader.windowInstance.showMinimized()
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
                    if (csdWindowsLoader.windowInstance.visibility === ApplicationWindow.Maximized)
                        csdWindowsLoader.windowInstance.showNormal()
                    else
                        csdWindowsLoader.windowInstance.showMaximized()
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

                source: "qrc:/IconLibrary/material-symbols/close.svg"
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
                onClicked: csdWindowsLoader.windowInstance.close()
            }
        }

        ////////
    }
}
