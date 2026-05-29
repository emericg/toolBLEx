import QtQuick
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenUbertooth
    anchors.fill: parent

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

    opacity: active ? 1 : 0
    Behavior on opacity { OpacityAnimator { duration: 233 } }

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        Component.onCompleted: loadAction()

        function loadAction() {
            ubertooth.checkUbertooth()
        }

        function backAction() {
            if (overlayClickable.hasIndicators()) {
                overlayClickable.resetIndicators()
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

                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.wifi

                    text: qsTr("wifi")
                    onClicked: {
                        actionBar.wifi = !actionBar.wifi
                        actionBar.bluetooth = false
                        actionBar.zigbee = false
                    }
                }
                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.bluetooth

                    text: qsTr("bluetooth")
                    onClicked: {
                        actionBar.wifi = false
                        actionBar.bluetooth = !actionBar.bluetooth
                        actionBar.zigbee = false
                    }
                }
                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.zigbee

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

                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.wifi_b

                    visible: actionBar.wifi
                    text: qsTr("802.11 b")
                    onClicked: {
                        actionBar.wifi_b = true
                        actionBar.wifi_gn = false
                        actionBar.wifi_n = false
                    }
                }
                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.wifi_gn

                    visible: actionBar.wifi
                    text: qsTr("802.11 g/n")
                    onClicked: {
                        actionBar.wifi_b = false
                        actionBar.wifi_gn = true
                        actionBar.wifi_n = false
                    }
                }
                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.wifi_n

                    visible: false // actionBar.wifi
                    text: qsTr("802.11 n")
                    onClicked: {
                        actionBar.wifi_b = false
                        actionBar.wifi_gn = false
                        actionBar.wifi_n = true
                    }
                }

                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.bluetooth_classic

                    visible: actionBar.bluetooth
                    text: qsTr("classic")
                    onClicked: {
                        actionBar.bluetooth_classic = true
                        actionBar.bluetooth_lowenergy = false
                    }
                }
                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: actionBar.bluetooth_lowenergy

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
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.right: parent.right
                            text: qsTr("2.6 GHz")
                            textFormat: Text.PlainText
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

                ButtonFlat {
                    height: 30
                    color: ubertooth.hardwareAvailable ? Theme.colorSuccess: Theme.colorWarning
                    text: ubertooth.hardwareAvailable ? qsTr("hardware ready") : qsTr("hardware not ready")
                    source: ubertooth.hardwareAvailable ? "qrc:/IconLibrary/material-symbols/check_circle.svg" : ""
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

        Item {
            id: legend_area_under
            clip: true

            //RectangleDebug {}

            FrequencyGraphOverlayBands {
                id: frequencyBands
                anchors.fill: parent
            }
        }

        ////////

        FrequencyGraph {
            id: frequencyGraph

            anchors.top: actionBar.bottom
            anchors.topMargin: -20
            anchors.left: parent.left
            anchors.leftMargin: -28
            anchors.right: parent.right
            anchors.rightMargin: -20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -28

            onPlotAreaUpdated: (x, y, width, height) => {
                //console.log("onPlotAreaUpdated")
                //console.log("- plotArea x      " + frequencyGraph.plotArea.x)
                //console.log("- plotArea y      " + frequencyGraph.plotArea.y)
                //console.log("- plotArea width  " + frequencyGraph.plotArea.width)
                //console.log("- plotArea height " + frequencyGraph.plotArea.height)

                legend_area_under.x = x
                legend_area_under.y = y
                legend_area_under.width = width
                legend_area_under.height = height

                legend_area_over.x = x
                legend_area_over.y = y
                legend_area_over.width = width
                legend_area_over.height = height
            }
        }

        ////////

        Item {
            id: legend_area_over
            clip: true

            FrequencyGraphLegend {
                id: overlayLegend
                anchors.fill: parent
            }

            FrequencyGraphOverlayClickable {
                id: overlayClickable
                anchors.fill: parent
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
