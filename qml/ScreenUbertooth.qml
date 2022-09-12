import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Loader {
    id: screenUbertooth

    ////////

    function loadScreen() {
        screenUbertooth.active = true
        appContent.state = "Ubertooth"
    }

    ////////

    function backAction() {
        if (screenUbertooth.status === Loader.Ready)
            screenUbertooth.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        function backAction() {
            screenScanner.loadScreen()
        }

        ////////////////////////////////////////////////////////////////////////

        Rectangle {
            id: actionBar
            anchors.left: parent.left
            anchors.right: parent.right

            z: 5
            height: 44
            color: Theme.colorActionbar

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            Row { // left
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8


                ButtonWireframe {
                    fullColor: true
                    text: "START"
                    onClicked: ubertooth.startWork()
                }
                ButtonWireframe {
                    fullColor: true
                    text: "STOP"
                    onClicked: ubertooth.stopWork()
                }

                ButtonWireframe {
                    text: "check tools"
                    onClicked: {
                        fullColor = true
                        var status = ubertooth.checkPath()
                        if (status) primaryColor = Theme.colorSuccess
                        else primaryColor = Theme.colorWarning
                    }
                }
                ButtonWireframe {
                    text: "check hw"
                    onClicked: {
                        fullColor = true
                        var status = ubertooth.checkUbertooth()
                        if (status) primaryColor = Theme.colorSuccess
                        else primaryColor = Theme.colorWarning
                    }
                }
            }

            Row { // right
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                height: 2
                opacity: 1
                color: Theme.colorSeparator
            }
        }

        ////////////////////////////////////////////////////////////////////////

        FrequencyGraph {
            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        ////////////////////////////////////////////////////////////////////////
    }
}
