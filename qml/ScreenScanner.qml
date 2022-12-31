import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Loader {
    id: screenScanner

    ////////

    function loadScreen() {
        screenScanner.active = true
        appContent.state = "Scanner"
    }

    ////////

    function backAction() {
        if (screenScanner.status === Loader.Ready)
            screenScanner.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        property var selectedDevice: null
        property string selectedDeviceAddress: ""

        function backAction() {
            if (filterField.focus) {
                filterField.focus = false
                return
            }

            if (selectedDevice) {
                selectedDevice.selected = false
                selectedDevice = null
                return
            }
        }

        onSelectedDeviceChanged: {
            if (selectedDevice) {
                panelDevice.checkMenuSelection()
            }
        }

        ////////////////////////////////////////////////////////////////////////

        SplitView {
            id: splitview
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: statusBar.top

            orientation: settingsManager.scanviewOrientation

            handle: Rectangle {
                implicitWidth: (splitview.orientation === Qt.Horizontal) ? 3: splitview.width
                implicitHeight: (splitview.orientation === Qt.Horizontal) ? splitview.height : 3
                color: SplitHandle.pressed ? Theme.colorPrimary
                     : (SplitHandle.hovered ? Theme.colorPrimary : Theme.colorSeparator)
            }

            Component.onCompleted: splitview.restoreState(settingsManager.scanviewSize)
            Component.onDestruction: settingsManager.scanviewSize = splitview.saveState()

            ////////////////

            Rectangle {
                SplitView.fillHeight: true
                SplitView.fillWidth: true

                clip: true
                color: Theme.colorLVpair

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
                            height: 28
                            fullColor: true
                            primaryColor: Theme.colorActionbarHighlight
                            opacity: settingsManager.scanShowLowEnergy ? 1 : 0.5
                            font.bold: false

                            text: qsTr("BLE")
                            onClicked: {
                                settingsManager.scanShowLowEnergy = !settingsManager.scanShowLowEnergy
                                deviceManager.updateBoolFilters()
                            }
                        }
                        ButtonWireframe {
                            height: 28
                            fullColor: true
                            primaryColor: Theme.colorActionbarHighlight
                            opacity: settingsManager.scanShowClassic ? 1 : 0.5
                            font.bold: false

                            text: qsTr("Classic")
                            onClicked: {
                                settingsManager.scanShowClassic = !settingsManager.scanShowClassic
                                deviceManager.updateBoolFilters()
                            }
                        }
                        ButtonWireframe {
                            height: 28
                            fullColor: true
                            primaryColor: Theme.colorActionbarHighlight
                            opacity: settingsManager.scanShowCached ? 1 : 0.5
                            font.bold: false

                            text: qsTr("cached")
                            onClicked: {
                                settingsManager.scanShowCached = !settingsManager.scanShowCached
                                deviceManager.updateBoolFilters()
                            }
                        }
                        ButtonWireframe {
                            height: 28
                            fullColor: true
                            primaryColor: Theme.colorActionbarHighlight
                            opacity: settingsManager.scanShowBlacklisted ? 1 : 0.5
                            font.bold: false

                            text: qsTr("blacklisted")
                            onClicked: {
                                settingsManager.scanShowBlacklisted = !settingsManager.scanShowBlacklisted
                                deviceManager.updateBoolFilters()
                            }
                        }
                        ButtonWireframe {
                            height: 28
                            fullColor: true
                            primaryColor: Theme.colorActionbarHighlight
                            opacity: settingsManager.scanShowBeacon ? 1 : 0.5
                            font.bold: false

                            text: qsTr("beacons")
                            onClicked: {
                                settingsManager.scanShowBeacon = !settingsManager.scanShowBeacon
                                deviceManager.updateBoolFilters()
                            }
                        }
                    }

                    Row { // right
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        TextFieldThemed { // filter
                            id: filterField
                            anchors.verticalCenter: parent.verticalCenter
                            width: 300
                            height: 30

                            onTextChanged: {
                                deviceManager.setFilterString(text)
                            }

                            MouseArea {
                                anchors.right: parent.right
                                anchors.rightMargin: 32
                                anchors.verticalCenter: parent.verticalCenter
                                width: 30
                                height: 30

                                visible: filterField.text.length
                                hoverEnabled: true
                                onClicked: filterField.text = ""

                                IconSvg {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16

                                    source: "qrc:/assets/icons_material/baseline-backspace-24px.svg"
                                    color: parent.containsMouse ? Theme.colorPrimary : Theme.colorIcon
                                    opacity: 0.8
                                }
                            }

                            IconSvg {
                                anchors.right: parent.right
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                width: 24
                                height: 24

                                source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                                color: Theme.colorIcon
                            }

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Escape) {
                                    event.accepted = true
                                    filterField.focus = false
                                }
                            }
                        }
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
/*
                TableView {
                    id: devicesView2

                    anchors.top: actionBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    columnSpacing: 0
                    rowSpacing: 0

                    model: deviceManager.devicesList
                    delegate: DeviceWidget {
                        width: devicesView2.width
                    }
                }
*/
                ListView {
                    id: devicesView

                    anchors.top: actionBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    visible: true

                    ScrollBar.vertical: ScrollBar {
                        visible: false
                        anchors.right: parent.right
                        anchors.rightMargin: -6
                        policy: ScrollBar.AsNeeded
                    }

                    headerPositioning: ListView.OverlayHeader
                    header: DeviceScannerHeader { }

                    model: deviceManager.devicesList
                    delegate: DeviceScannerWidget {
                        width: devicesView.width
                    }

                    //footer: Item { }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            //console.log("Key_Escape")
                            event.accepted = true

                            selectedDevice.selected = false
                            selectedDevice = null
                        } else if (event.key === Qt.Key_Up) {
                            //console.log("Key_Up")
                            event.accepted = true

                            for (var i = 0; i < devicesView.count; i++) {
                                if (deviceManager.getDeviceByProxyIndex(i).selected) {
                                    if (i-1 >= 0) {
                                        deviceManager.getDeviceByProxyIndex(i).selected = false
                                        deviceManager.getDeviceByProxyIndex(i-1).selected = true
                                        selectedDevice = deviceManager.getDeviceByProxyIndex(i-1)
                                        return
                                    }
                                }
                            }
                        } else if (event.key === Qt.Key_Down) {
                            //console.log("Key_Down")
                            event.accepted = true

                            for (var ii = 0; ii < devicesView.count; ii++) {
                                if (deviceManager.getDeviceByProxyIndex(ii).selected) {
                                    if (ii+1 < devicesView.count) {
                                        deviceManager.getDeviceByProxyIndex(ii).selected = false
                                        deviceManager.getDeviceByProxyIndex(ii+1).selected = true
                                        selectedDevice = deviceManager.getDeviceByProxyIndex(ii+1)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }

            }

            ////////////////

            Rectangle {
                id: detailView

                SplitView.preferredWidth: 400
                SplitView.preferredHeight: 400

                SplitView.minimumHeight: parent.height * 0.333
                SplitView.maximumHeight: parent.height * 0.666
                SplitView.minimumWidth: parent.width * 0.333
                SplitView.maximumWidth: parent.width * 0.666

                clip: true
                color: Theme.colorBackground

                ////

                property int flowElementWidth: (width >= 1450) ? (width / 3) - 10 - 10
                                                               : (width / 2) - 20 - 10

                property int ww: (settingsManager.scanviewOrientation === Qt.Horizontal) ? width - 40
                                                                                         : flowElementWidth

                ////

                PanelScanner {
                    id: panelScanner
                    visible: (!selectedDevice)
                }

                ////

                PanelDevice {
                    id: panelDevice
                    visible: (selectedDevice)
                }

                ////
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Rectangle {
            id: statusBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            z: 5
            height: 24 + 2
            color: Theme.colorActionbar

            // prevent clicks below this area
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

            Row { // left
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var txt = qsTr("%0 device(s) found").arg(deviceManager.deviceCount)
                        if (deviceManager.deviceCount !== devicesView.count) {
                            txt += "  |  " + qsTr("%0 device(s) shown").arg(devicesView.count)
                        }
                        return txt
                    }
                    color: Theme.colorSubText
                }
            }

            Row { // right
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                spacing: 8

                RoundButtonIcon {
                    width: 24; height: 24;
                    highlightMode: "color"
                    selected: (settingsManager.scanviewOrientation === Qt.Vertical)
                    source: "qrc:/assets/icons_bootstrap/layout-bottombar.svg"
                    iconColor: Theme.colorSubText

                    onClicked: {
                        settingsManager.scanviewOrientation = Qt.Vertical

                        splitview.width = splitview.width+1
                        splitview.width = splitview.width-1
                    }
                }
                RoundButtonIcon {
                    width: 24; height: 24;
                    highlightMode: "color"
                    selected: (settingsManager.scanviewOrientation === Qt.Horizontal)
                    source: "qrc:/assets/icons_bootstrap/layout-sidebar.svg"
                    iconColor: Theme.colorSubText

                    onClicked: {
                        settingsManager.scanviewOrientation = Qt.Horizontal

                        splitview.width = splitview.width+1
                        splitview.width = splitview.width-1
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                height: 2
                opacity: 1
                color: Theme.colorSeparator
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }
}
