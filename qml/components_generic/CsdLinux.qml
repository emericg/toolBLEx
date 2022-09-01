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
            color: hovered ? "#66aaaaaa" : "#33aaaaaa"
            Behavior on color { ColorAnimation { duration: 233; easing.type: Easing.InOutCirc; } }

            property bool hovered: false

            Rectangle {
                width: 10; height: 2;
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 4
                color: parent.hovered ? Theme.colorHighContrast : Theme.colorIcon
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onCanceled: parent.hovered = false
                onClicked: appWindow.showMinimized()
            }
        }

        ////////

        Rectangle { // button maximize
            width: 26; height: 26; radius: 26;
            color: hovered ? "#66aaaaaa" : "#33aaaaaa"
            Behavior on color { ColorAnimation { duration: 233; easing.type: Easing.InOutCirc; } }

            property bool hovered: false

            Rectangle {
                width: 10; height: 10;
                anchors.centerIn: parent
                color: "transparent"
                border.width: 2
                border.color: parent.hovered ? Theme.colorHighContrast : Theme.colorIcon
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onCanceled: parent.hovered = false
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
            color: hovered ? "red" : "#33aaaaaa"
            Behavior on color { ColorAnimation { duration: 233; easing.type: Easing.InOutCirc; } }

            property bool hovered: false

            Rectangle {
                width: 13; height: 2; radius: 2;
                anchors.centerIn: parent
                rotation: 45
                color: parent.hovered ? "white" : Theme.colorIcon
            }
            Rectangle {
                width: 13; height: 2; radius: 2;
                anchors.centerIn: parent
                rotation: -45
                color: parent.hovered ? "white" : Theme.colorIcon
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onCanceled: parent.hovered = false
                onClicked: appWindow.close()
            }
        }
    }
}
