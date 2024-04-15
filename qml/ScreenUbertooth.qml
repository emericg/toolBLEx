import QtQuick
import QtQuick.Controls

import ThemeEngine
import "qrc:/js/UtilsNumber.js" as UtilsNumber


Loader {
    id: screenUbertooth

    ////////////////

    function loadScreen() {
        screenUbertooth.active = true
        appContent.state = "Ubertooth"

        if (screenUbertooth.status === Loader.Ready)
            screenUbertooth.item.loadAction()
    }

    function backAction() {
        if (screenUbertooth.status === Loader.Ready)
            screenUbertooth.item.backAction()
    }

    ////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        Component.onCompleted: loadAction()

        function loadAction() {
            ubertooth.checkUbertooth()
        }

        function backAction() {
            if (frequencyGraph.hasIndicators()) {
                frequencyGraph.resetIndicators()
                return
            }

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

            property bool bluetooth: false
            property bool bluetooth_classic: false
            property bool bluetooth_lowenergy: true
            property bool wifi: false
            property bool wifi_b: true
            property bool wifi_gn: false
            property bool wifi_n: false
            property bool zigbee: false

            ////////

            Row { // left
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.wifi ? 1 : 0.5
                    font.bold: false

                    text: qsTr("wifi")
                    onClicked: {
                        actionBar.wifi = !actionBar.wifi
                        actionBar.bluetooth = false
                        actionBar.zigbee = false
                    }
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.bluetooth ? 1 : 0.5
                    font.bold: false

                    text: qsTr("bluetooth")
                    onClicked: {
                        actionBar.wifi = false
                        actionBar.bluetooth = !actionBar.bluetooth
                        actionBar.zigbee = false
                    }
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.zigbee ? 1 : 0.5
                    font.bold: false

                    text: qsTr("zigbee")
                    onClicked: {
                        actionBar.wifi = false
                        actionBar.bluetooth = false
                        actionBar.zigbee = !actionBar.zigbee
                    }
                }

                ////

                Item {
                    width: 16
                    height: 28

                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 20
                        color: Theme.colorActionbarHighlight
                        visible: (actionBar.wifi || actionBar.bluetooth)
                    }
                }

                ////

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.wifi_b ? 1 : 0.5
                    font.bold: false

                    visible: actionBar.wifi
                    text: qsTr("802.11 b")
                    onClicked: {
                        actionBar.wifi_b = true
                        actionBar.wifi_gn = false
                        actionBar.wifi_n = false
                    }
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.wifi_gn ? 1 : 0.5
                    font.bold: false

                    visible: actionBar.wifi
                    text: qsTr("802.11 g/n")
                    onClicked: {
                        actionBar.wifi_b = false
                        actionBar.wifi_gn = true
                        actionBar.wifi_n = false
                    }
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.wifi_n ? 1 : 0.5
                    font.bold: false

                    visible: false // actionBar.wifi
                    text: qsTr("802.11 n")
                    onClicked: {
                        actionBar.wifi_b = false
                        actionBar.wifi_gn = false
                        actionBar.wifi_n = true
                    }
                }

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.bluetooth_classic ? 1 : 0.5
                    font.bold: false

                    visible: actionBar.bluetooth
                    text: qsTr("classic")
                    onClicked: {
                        actionBar.bluetooth_classic = true
                        actionBar.bluetooth_lowenergy = false
                    }
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorActionbarHighlight
                    opacity: actionBar.bluetooth_lowenergy ? 1 : 0.5
                    font.bold: false

                    visible: actionBar.bluetooth
                    text: qsTr("low energy")
                    onClicked: {
                        actionBar.bluetooth_classic = false
                        actionBar.bluetooth_lowenergy = true
                    }
                }
            }

            ////////

            Row { // right
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    Item {
                        width: 256
                        height: 18
                        Text {
                            anchors.left: parent.left
                            text: qsTr("2.3 GHz")
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.right: parent.right
                            text: qsTr("2.6 GHz")
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }
                    }
                    Rectangle {
                        width: 256
                        height: 8
                        radius: 2
                        color: Theme.colorBackground

                        Repeater {
                            model: 5
                            Rectangle {
                                x: (256 / 6) * (index+1) - 1
                                width: 2
                                height: 8
                                color: Theme.colorSeparator
                                opacity: 0.66
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: UtilsNumber.mapNumber(ubertooth.freqMin, 2300, 2600, 0, parent.width)
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width - UtilsNumber.mapNumber(ubertooth.freqMax, 2300, 2600, 0, parent.width)

                            height: 8
                            radius: 2
                            color: Theme.colorSuccess
                        }
                    }
                }

                ButtonWireframeIcon {
                    height: 28
                    fullColor: true
                    primaryColor: ubertooth.hardwareAvailable ? Theme.colorSuccess: Theme.colorWarning
                    text: ubertooth.hardwareAvailable ? qsTr("hardware ready") : qsTr("hardware not ready")
                    source: ubertooth.hardwareAvailable ? "qrc:/assets/icons/material-symbols/check_circle.svg" : ""
                    onClicked: ubertooth.checkUbertooth()
                }
            }

            ////////

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
            id: frequencyGraph
            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
