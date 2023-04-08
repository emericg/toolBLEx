import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeEngine 1.0

Loader {
    width: active ? 48 : 0
    height: active ? 24 : 0

    active: (settingsManager.appThemeCSD && Qt.platform.os === "osx")
    asynchronous: true

    sourceComponent: Item {
        id: csdMac
        implicitWidth: 48
        implicitHeight: 24

        ////////

        MouseArea {
            id: mouseArea
            anchors.fill: buttonsRow

            hoverEnabled: visible
        }

        ////////

        Row {
            id: buttonsRow
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 12; height: 12; radius: 12;
                color: "#FE5F57"
                border.color: "#E24037"

                IconSvg {
                    width: 10; height: 10;
                    anchors.centerIn: parent
                    source: "qrc:/assets/icons_material/baseline-close-24px.svg"
                    opacity: mouseArea.containsMouse ? 0.6 : 0
                    //Behavior on opacity { OpacityAnimator { duration: 133 } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: appWindow.close()
                }
            }
            Rectangle {
                width: 12; height: 12; radius: 12;
                color: "#FEBC2F"
                border.color: "#E19D17"
                Rectangle {
                    width: 8; height: 1;
                    anchors.centerIn: parent
                    color: "grey"
                    opacity: mouseArea.containsMouse ? 0.8 : 0
                    //Behavior on opacity { OpacityAnimator { duration: 133 } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: appWindow.showMinimized()
                }
            }
            Rectangle {
                width: 12; height: 12; radius: 12;
                color: "#28C940"
                border.color: "#10A923"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (appWindow.visibility === ApplicationWindow.Maximized)
                            appWindow.showNormal()
                        else
                            appWindow.showMaximized()
                    }
                }
            }
        }
    }
}
