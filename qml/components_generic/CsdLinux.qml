import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeEngine 1.0

Loader {
    anchors.top: parent.top
    anchors.topMargin: 6
    anchors.right: parent.right
    anchors.rightMargin: 6

    width: active ? 94 : 0
    height: active ? 26 : 0

    active: (settingsManager.appThemeCSD && Qt.platform.os !== "windows" && Qt.platform.os !== "osx")
    asynchronous: true

    sourceComponent: Row {
        id: csdLinux
        spacing: 8

        ////////

        Rectangle { // button minimize
            width: 26; height: 26; radius: 26;
            color: mouseAreaMin.containsMouse ? "#66aaaaaa" : "#33aaaaaa"
            Behavior on color { ColorAnimation { duration: 233; easing.type: Easing.InOutCirc; } }

            Rectangle {
                width: 10; height: 2;
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 4
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
            width: 26; height: 26; radius: 26;
            color: mouseAreaMax.containsMouse ? "#66aaaaaa" : "#33aaaaaa"
            Behavior on color { ColorAnimation { duration: 233; easing.type: Easing.InOutCirc; } }

            Rectangle {
                width: 10; height: 10;
                anchors.centerIn: parent
                color: "transparent"
                border.width: 2
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
            width: 26; height: 26; radius: 26;
            color: mouseAreaClose.containsMouse ? "red" : "#33aaaaaa"
            Behavior on color { ColorAnimation { duration: 233; easing.type: Easing.InOutCirc; } }

            Rectangle {
                width: 13; height: 2; radius: 2;
                anchors.centerIn: parent
                rotation: 45
                color: mouseAreaClose.containsMouse ? "white" : Theme.colorIcon
            }
            Rectangle {
                width: 13; height: 2; radius: 2;
                anchors.centerIn: parent
                rotation: -45
                color: mouseAreaClose.containsMouse ? "white" : Theme.colorIcon
            }

            MouseArea {
                id: mouseAreaClose
                anchors.fill: parent

                hoverEnabled: true
                onClicked: appWindow.close()
            }
        }
    }
}
