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

            // view mode: 0 = spectrum (2D line graph), 2 = spectrum (3D surface graph), 3 = waterfall (2D heatmap)
            property int viewMode: SettingsManager.spectrogram_graphSelected

            // axis control: floorDb/ceilDb
            property int minRSSI: -100
            property int maxRSSI: -20

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
                anchors.leftMargin: Theme.componentMarginS
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMarginXS

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
                        SettingsManager.spectrogram_graphSelected = index
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

                SelectorMenuColorful { // spectrum history graph style
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    visible: (actionBar.viewMode === 0)

                    model: ListModel {
                        ListElement { idx: 0; txt: qsTr("persistence"); src: ""; sz: 16; }
                        ListElement { idx: 1; txt: qsTr("history curves"); src: ""; sz: 16; }
                    }

                    currentSelection: spectrumGraph2D_container.graphHistoryMethod
                    onMenuSelected: (index) => {
                        spectrumGraph2D_container.graphHistoryMethod = index
                    }
                }

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

                ////

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.componentMarginXS

                    visible: (actionBar.viewMode === 0 || actionBar.viewMode === 2)

                    Item { // separator
                        width: 16
                        height: 28

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

                    Item { // separator
                        width: 16
                        height: 28
                        visible: (actionBar.wifi || actionBar.bluetooth)

                        Rectangle {
                            anchors.centerIn: parent
                            width: 2
                            height: 20
                            color: Theme.colorActionbarHighlight
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

                    Item { // separator
                        width: 16
                        height: 28

                        Rectangle {
                            anchors.centerIn: parent
                            width: 2
                            height: 20
                            color: Theme.colorActionbarHighlight
                        }
                    }
                }

                ////
            }

            ////////

            Row { // right
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginS
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMarginS

                Column {
                    anchors.verticalCenter: parent.verticalCenter

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
                            anchors.leftMargin: UtilsNumber.mapNumber(ubertooth.freqMin,
                                                                      2300, 2600,
                                                                      0, parent.width)
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width - UtilsNumber.mapNumber(ubertooth.freqMax,
                                                                                      2300, 2600,
                                                                                      0, parent.width)

                            height: 8
                            radius: 2

                            visible: ubertooth.running
                            color: Theme.colorSuccess
                        }
                    }
                }

                ButtonFlat {
                    height: 30
                    visible: ubertooth.running
                    text: ubertooth.captureRate.toFixed(0) + qsTr(" Hz")
                    source: "qrc:/IconLibrary/material-symbols/stacks.svg"
                    color: {
                        var hz = ubertooth.captureRate.toFixed(0)
                        if (hz > 59) return Theme.colorGreen
                        if (hz > 29) return Theme.colorOrange
                        return Theme.colorRed
                    }
                }

                ButtonFlat {
                    height: 30
                    color: ubertooth.hardwareAvailable ? Theme.colorSuccess: Theme.colorWarning
                    text: ubertooth.hardwareAvailable ? qsTr("hardware ready") : qsTr("hardware busy?")
                    source: ubertooth.hardwareAvailable ? "qrc:/IconLibrary/material-symbols/check_circle.svg"
                                                        : "qrc:/IconLibrary/material-icons/outlined/hourglass_empty.svg"
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

            dataSource: ubertooth
        }

        ////////////////////////////////////////////////////////////////////////

        SpectrumGraph3D {
            id: spectrumGraph3D_container

            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (actionBar.viewMode === 1)

            dataSource: ubertooth
        }

        ////////////////////////////////////////////////////////////////////////

        WaterfallGraph {
            id: waterfallGraph

            anchors.top: actionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: (actionBar.viewMode === 2)

            dataSource: ubertooth
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
