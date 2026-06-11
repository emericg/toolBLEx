import QtQuick
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenRtlSdr
    anchors.fill: parent

    ////////////////

    function loadScreen() {
        screenRtlSdr.active = true
        appContent.state = "RtlSdr"

        if (screenRtlSdr.status === Loader.Ready)
            screenRtlSdr.item.loadAction()
    }

    function backAction() {
        if (screenRtlSdr.status === Loader.Ready)
            screenRtlSdr.item.backAction()
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
            //rtlsdr.checkRtlSdr() // too slow...
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

            // view mode: 0 = spectrum (2D line graph), 2 = spectrum (3D surface graph), 3 = waterfall (2D heatmap)
            property int viewMode: 0

            // axis control: floorDb/ceilDb
            property int minRSSI: -100
            property int maxRSSI: -30

            // visualize known spectrum bands
            property bool autobands: false
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

                ////

                SelectorMenuColorful {
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter

                    model: ListModel {
                        ListElement { idx: 0; txt: qsTr("spectrum 2D"); src: ""; sz: 16; }
                        ListElement { idx: 1; txt: qsTr("spectrum 3D"); src: ""; sz: 16; }
                        ListElement { idx: 2; txt: qsTr("waterfall"); src: ""; sz: 16; }
                    }

                    currentSelection: actionBar.viewMode
                    onMenuSelected: (index) => {
                        actionBar.viewMode = index
                    }
                }

                ////

                Item { // separator
                    width: 16
                    height: 28
                    visible: (actionBar.viewMode === 0)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 20
                        color: Theme.colorActionbarHighlight
                    }
                }

                ButtonToggle {
                    height: 28
                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight
                    checked: spectrumGraph2D_container.showPeak
                    visible: (actionBar.viewMode === 0)

                    text: qsTr("peak")
                    onClicked: {
                        spectrumGraph2D_container.showPeak = !spectrumGraph2D_container.showPeak
                    }
                }

                ////

                Item { // separator
                    width: 16
                    height: 28
                    visible: (actionBar.viewMode === 2)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 20
                        color: Theme.colorActionbarHighlight
                    }
                }

                ComboBoxThemed {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 128
                    height: 28

                    visible: (actionBar.viewMode === 2)
                    wheelEnabled: false

                    colorBackground: Theme.colorLowContrast

                    model: ListModel {
                        id: cbGraphColors
                        ListElement { text: "Viridis"; }
                        ListElement { text: "Turbo"; }
                        ListElement { text: "Inferno"; }
                        ListElement { text: "gqrx"; }
                    }

                    Component.onCompleted: {
                        currentIndex = SettingsManager.spectrogram_graphColors
                        if (currentIndex < 0 || currentIndex > cbGraphColors.count) currentIndex = 0
                    }

                    onActivated: {
                        SettingsManager.spectrogram_graphColors = currentIndex
                        waterfallGraph.colorScheme = currentIndex
                        //spectrumGraph3D_container.colorScheme = currentIndex
                    }
                }

                Item { // separator
                    width: 16
                    height: 28
                    visible: (actionBar.viewMode === 0 || actionBar.viewMode === 2)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 20
                        color: Theme.colorActionbarHighlight
                    }
                }

                ////
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
                            text: qsTr("52 MHz")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.right: parent.right
                            text: qsTr("2.2 GHz")
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
                            x: UtilsNumber.mapNumber(rtlsdr.freqMin/1000,
                                                     52, 2200,
                                                     0, parent.width)

                            height: 8
                            width: 8
                            radius: 8

                            visible: rtlsdr.running
                            color: Theme.colorSuccess
                        }
                    }
                }

                ButtonFlat {
                    height: 30
                    visible: rtlsdr.running
                    text: rtlsdr.captureRate.toFixed(0) + qsTr(" Hz")
                    source: "qrc:/IconLibrary/material-symbols/stacks.svg"
                    color: {
                        var hz = rtlsdr.captureRate.toFixed(0)
                        if (hz > 30) return Theme.colorGreen
                        if (hz > 15) return Theme.colorOrange
                        return Theme.colorRed
                    }
                }

                ButtonFlat {
                    height: 30
                    color: rtlsdr.hardwareAvailable ? Theme.colorSuccess: Theme.colorWarning
                    text: rtlsdr.hardwareAvailable ? qsTr("hardware ready") : qsTr("hardware busy?")
                    source: rtlsdr.hardwareAvailable ? "qrc:/IconLibrary/material-symbols/check_circle.svg"
                                                        : "qrc:/IconLibrary/material-icons/outlined/hourglass_empty.svg"
                    onClicked: rtlsdr.checkRtlSdr()
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

            ////////
        }

        ////////////////////////////////////////////////////////////////////////

        SpectrumGraph2D {
            id: spectrumGraph2D_container

            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (actionBar.viewMode === 0)

            dataSource: rtlsdr
        }

        ////////////////////////////////////////////////////////////////////////

        SpectrumGraph3D {
            id: spectrumGraph3D_container

            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (actionBar.viewMode === 1)

            dataSource: rtlsdr
        }

        ////////////////////////////////////////////////////////////////////////

        WaterfallGraph {
            id: waterfallGraph

            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (actionBar.viewMode === 2)

            dataSource: rtlsdr
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
