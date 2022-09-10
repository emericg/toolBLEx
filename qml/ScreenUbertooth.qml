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

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -(appHeader.height / 2)
            spacing: 32

            ////////////////

            Rectangle { // not implemented
                width: screenUbertooth.width * 0.66
                height: 128
                radius: 4
                color: Theme.colorBox

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom

                    width: 8
                    radius: 2
                    color: Theme.colorPrimary
                }

                Item {
                    anchors.left: parent.left
                    width: 128
                    height: 128

                    IconSvg {
                        width: 96
                        height: 96
                        anchors.centerIn: parent

                        source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
                        color: Theme.colorIcon
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 128
                    anchors.right: parent.right
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("This screen is not implemented (yet)")
                        font.pixelSize: Theme.fontSizeContentVeryVeryBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: qsTr("This is a spectrum analyser, using the Ubertooth One.")
                        font.pixelSize: Theme.fontSizeContentBig
                        wrapMode: Text.WordWrap
                        color: Theme.colorText
                    }
                }
            }

            ////////////////
        }

        ////////////////////////////////////////////////////////////////////////
    }
}
