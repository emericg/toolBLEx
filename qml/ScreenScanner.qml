import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary

Loader {
    id: screenScanner
    anchors.fill: parent

    ////////////////

    function loadScreen() {
        screenScanner.active = true
        appContent.state = "Scanner"
    }

    function backAction() {
        if (screenScanner.status === Loader.Ready)
            screenScanner.item.backAction()
    }

    property bool _pendingExport: false
    function openExport() {
        loadScreen()
        if (screenScanner.status === Loader.Ready)
            screenScanner.item.openExport()
        else
            _pendingExport = true
    }
    onLoaded: {
        if (_pendingExport) {
            _pendingExport = false
            screenScanner.item.openExport()
        }
    }

    ////////////////

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

        function openExport() {
            popupLoader_export.active = true
            popupLoader_export.item.open()
        }

        onSelectedDeviceChanged: {
            if (selectedDevice) {
                panelDevice.resetState()
            }
        }

        ////////////////////////////////////////////////////////////////////////

        SplitView {
            id: splitview

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: errorBar.top

            orientation: SettingsManager.scanviewOrientation

            handle: Rectangle {
                id: splithandle
                implicitWidth: (splitview.orientation === Qt.Horizontal) ? 3 : splitview.width
                implicitHeight: (splitview.orientation === Qt.Horizontal) ? splitview.height : 3
                color: SplitHandle.pressed ? Theme.colorPrimary
                     : (SplitHandle.hovered ? Theme.colorSecondary : Theme.colorHeaderHighlight)

                containmentMask: Item {
                    parent: splithandle
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: (splitview.orientation === Qt.Horizontal &&
                                                     devicesViewVertScrollbar.visible) ? 3 : 0
                    width: {
                        if (splitview.orientation === Qt.Horizontal && devicesViewVertScrollbar.visible) return 12
                        if (splitview.orientation === Qt.Horizontal) return 20
                        return splitview.width
                    }
                    height: (splitview.orientation === Qt.Horizontal) ? splitview.height : 20
                }
            }

            Component.onCompleted: splitview.restoreState(SettingsManager.scanviewSize)
            Component.onDestruction: SettingsManager.scanviewSize = splitview.saveState()

            ////////////////

            Rectangle {
                SplitView.fillHeight: true
                SplitView.fillWidth: true

                clip: false
                color: Theme.colorLVpair

                ////////

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
                        id: rowLeft
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.componentMarginS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.componentMarginXS

                        ButtonToggle {
                            height: 28
                            colorBackground: Theme.colorActionbar
                            colorHighlight: Theme.colorActionbarHighlight
                            checked: SettingsManager.scanShowLowEnergy

                            text: qsTr("BLE")
                            onClicked: {
                                SettingsManager.scanShowLowEnergy = !SettingsManager.scanShowLowEnergy
                                DeviceManager.updateBoolFilters()
                            }
                        }
                        ButtonToggle {
                            height: 28
                            colorBackground: Theme.colorActionbar
                            colorHighlight: Theme.colorActionbarHighlight
                            checked: SettingsManager.scanShowClassic

                            text: qsTr("Classic")
                            onClicked: {
                                SettingsManager.scanShowClassic = !SettingsManager.scanShowClassic
                                DeviceManager.updateBoolFilters()
                            }
                        }
                        ButtonToggle {
                            height: 28
                            colorBackground: Theme.colorActionbar
                            colorHighlight: Theme.colorActionbarHighlight
                            checked: SettingsManager.scanShowCached

                            text: qsTr("cached")
                            onClicked: {
                                SettingsManager.scanShowCached = !SettingsManager.scanShowCached
                                DeviceManager.updateBoolFilters()
                            }
                        }
                        ButtonToggle {
                            height: 28
                            colorBackground: Theme.colorActionbar
                            colorHighlight: Theme.colorActionbarHighlight
                            checked: SettingsManager.scanShowBlacklisted

                            text: qsTr("hidden")
                            onClicked: {
                                SettingsManager.scanShowBlacklisted = !SettingsManager.scanShowBlacklisted
                                DeviceManager.updateBoolFilters()
                            }
                        }
                        ButtonToggle {
                            height: 28
                            colorBackground: Theme.colorActionbar
                            colorHighlight: Theme.colorActionbarHighlight
                            checked: SettingsManager.scanShowBeacon

                            text: qsTr("beacons")
                            onClicked: {
                                SettingsManager.scanShowBeacon = !SettingsManager.scanShowBeacon
                                DeviceManager.updateBoolFilters()
                            }
                        }
                    }

                    Row { // right
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMarginS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.componentMarginXS

                        TextFieldThemed { // filter
                            id: filterField
                            anchors.verticalCenter: parent.verticalCenter
                            width: toggled ? 300 : 32
                            height: 30
                            clip: true

                            rightPadding: 52

                            property bool toggled: (actionBar.width - rowLeft.width > 300)
                            property bool toggledEnabled: (actionBar.width - rowLeft.width > 320)
                            Behavior on width { NumberAnimation { duration: 233; easing.type: Easing.InOutQuad; } }

                            onTextChanged: {
                                DeviceManager.setFilterString(text)
                            }

                            MouseArea {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMarginXL
                                width: 30
                                height: 30

                                visible: filterField.text.length
                                hoverEnabled: true
                                onClicked: filterField.text = ""

                                IconSvg {
                                    anchors.centerIn: parent
                                    width: 18
                                    height: 18

                                    source: "qrc:/IconLibrary/material-symbols/backspace-fill.svg"
                                    color: parent.containsMouse ? Theme.colorPrimary : Theme.colorIcon
                                    opacity: 0.8
                                }
                            }

                            MouseArea {
                                anchors.right: parent.right
                                width: 30
                                height: 30

                                hoverEnabled: filterField.toggledEnabled
                                onClicked: {
                                    filterField.toggled = !filterField.toggled
                                    if (!filterField.toggled) filterField.focus = false
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 26
                                    height: 26
                                    radius: 4
                                    color: Theme.colorComponentBackground
                                }

                                IconSvg {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 22
                                    height: 22

                                    source: "qrc:/IconLibrary/material-symbols/search.svg"
                                    color: Theme.colorIcon
                                }
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

                ////////
/*
                DeviceScannerTableHeader {
                    id: horizontalHeader
                    anchors.top: actionBar.bottom
                    anchors.left: devicesView.left
                    anchors.right: devicesView.right

                    syncView: devicesView
                    boundsBehavior: Flickable.StopAtBounds
                }
                TableView {
                    id: devicesView
                    anchors.top: horizontalHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    ScrollBar.vertical: ScrollBarThemed {
                        id: devicesViewScrollbar
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        topPadding: 36
                        policy: ScrollBar.AsNeeded
                    }
                    ScrollBar.horizontal: ScrollBarThemed {
                        anchors.bottom: parent.bottom
                        policy: ScrollBar.AsNeeded
                    }

                    clip: true
                    interactive: true
                    columnSpacing: 0
                    rowSpacing: 0

                    property int count: devicesView.rows

                    selectionBehavior: TableView.SelectRows
                    selectionModel: ItemSelectionModel {
                        onCurrentChanged: (current, previous) => {
                            //console.log("onCurrentChanged: " + current.row + " / " + previous.row)
                            selectedDevice = DeviceManager.getDeviceByProxyIndex(current.row)
                            DeviceManager.getDeviceByProxyIndex(current.row).selected = true
                            if (typeof previous === "undefined" || !previous) return
                            DeviceManager.getDeviceByProxyIndex(previous.row).selected = false
                        }
                    }

                    boundsBehavior: Flickable.OvershootBounds
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    resizableColumns: true

                    columnWidthProvider: function(column) {
                        if (column === 0) return 32
                        //if (column === 1 && Qt.platform.os === "osx") return 0

                        let w = explicitColumnWidth(column)
                        if (w >= 0 && w <= 112) return 112; // minimum size
                        if (w >= 0) return w;
                        return Math.max(implicitColumnWidth(column), 112)
                    }
                    rowHeightProvider: function(column) {
                        return 32;
                    }

                    model: DeviceManager.devicesList
                    delegate: DeviceScannerTableWidget { }
                }
*/
                ////////

                ListView {
                    id: devicesView

                    anchors.top: actionBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.AutoFlickDirection

                    contentHeight: -1
                    contentWidth: DeviceManager.deviceHeader.width

                    ScrollBar.vertical: ScrollBarThemed {
                        id: devicesViewVertScrollbar
                        topPadding: 36
                        policy: ScrollBar.AsNeeded
                    }
                    ScrollBar.horizontal: ScrollBarThemed {
                        policy: ScrollBar.AsNeeded
                    }

                    headerPositioning: ListView.OverlayHeader
                    header: DeviceScannerListHeader {
                        width: Math.max(DeviceManager.deviceHeader.width, appContent.width)
                    }

                    model: DeviceManager.devicesList
                    delegate: DeviceScannerListWidget {
                        width: Math.max(DeviceManager.deviceHeader.width, appContent.width)
                        onClicked: {
                            for (var i = 0; i < devicesView.count; i++) {
                                if (DeviceManager.getDeviceByProxyIndex(i).selected) {
                                    devicesView.currentIndex = i // move the listview
                                    return
                                }
                            }
                        }
                    }

                    //interactive: false
                    //snapMode: ListView.SnapToItem
                    //keyNavigationEnabled: false
                    //keyNavigationWraps: false
                    //highlightFollowsCurrentItem: true

                    Component.onCompleted: {
                        //console.log("> (default) flick maximum velocity: " + maximumFlickVelocity)
                        //console.log("> (default) flick deceleration: " + flickDeceleration)

                        if (isDesktop) {
                            // mouse wheel or trackpad
                            maximumFlickVelocity = 6500
                            flickDeceleration = 5000
                            boundsBehavior = Flickable.OvershootBounds
                        } else {
                            // touch
                            maximumFlickVelocity = 7500
                            flickDeceleration = 3000
                            boundsBehavior = Flickable.DragAndOvershootBounds
                        }
                    }

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
                                if (DeviceManager.getDeviceByProxyIndex(i).selected) {
                                    if (i-1 >= 0) {
                                        DeviceManager.getDeviceByProxyIndex(i).selected = false
                                        DeviceManager.getDeviceByProxyIndex(i-1).selected = true
                                        selectedDevice = DeviceManager.getDeviceByProxyIndex(i-1)
                                        currentIndex = i-1 // move the listview
                                        return
                                    }
                                }
                            }
                        } else if (event.key === Qt.Key_Down) {
                            //console.log("Key_Down")
                            event.accepted = true

                            for (var ii = 0; ii < devicesView.count; ii++) {
                                if (DeviceManager.getDeviceByProxyIndex(ii).selected) {
                                    if (ii+1 < devicesView.count) {
                                        DeviceManager.getDeviceByProxyIndex(ii).selected = false
                                        DeviceManager.getDeviceByProxyIndex(ii+1).selected = true
                                        selectedDevice = DeviceManager.getDeviceByProxyIndex(ii+1)
                                        currentIndex = ii+1 // move the listview
                                        return
                                    }
                                }
                            }
                        }
                    }
                }

                ////////
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

                // prevent clicks below this area
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

                ////

                property int flowElementWidth: (width >= 1080) ? (width / 3) - 24
                                                               : (width / 2) - 28

                property int ww: (SettingsManager.scanviewOrientation === Qt.Horizontal) ? width - 32
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
            id: errorBar

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: statusBar.top

            height: 0
            Behavior on height { NumberAnimation { duration: Theme.animationSpeedMedium } }

            clip: true
            color: Theme.colorWarning

            ////

            property bool bluetooth: AdapterManager.bluetooth
            property bool bluetoothAdapter: AdapterManager.bluetoothAdapter
            property bool bluetoothEnabled: AdapterManager.bluetoothEnabled
            property bool bluetoothPermission: AdapterManager.bluetoothPermission

            onBluetoothChanged: checkBleStatus()
            onBluetoothAdapterChanged: checkBleStatus()
            onBluetoothEnabledChanged: checkBleStatus()
            onBluetoothPermissionChanged: checkBleStatus()

            function checkBleStatus() {
                if (!bluetooth || !bluetoothAdapter || !bluetoothEnabled || !bluetoothPermission) {
                    errorBar.height = 64
                } else {
                    errorBar.height = 0
                }
            }

            ////

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMargin

                ////

                Item {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64

                    IconSvg { // primary
                        anchors.centerIn: parent
                        width: 48
                        height: 48

                        color: "white"
                        source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"

                        IconSvg { // secondary
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: -4
                            width: 24
                            height: 24

                            color: "white"
                            source: {
                                if (!AdapterManager.bluetoothAdapter) return "qrc:/IconLibrary/material-symbols/memory-fill.svg"
                                if (!AdapterManager.bluetoothEnabled) return "qrc:/IconLibrary/material-symbols/flaky.svg"
                                if (!AdapterManager.bluetoothPermission) return "qrc:/IconLibrary/material-symbols/lock-fill.svg"
                                return "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -2
                                z: -1

                                radius: width
                                color: "grey"
                                opacity: 0.48
                            }
                        }
                    }
                }

                ////

                Column {
                    Layout.fillWidth: true

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: {
                            if (!AdapterManager.hasAdapters) return qsTr("No Bluetooth adapter detected")
                            if (!AdapterManager.bluetoothPermission) return qsTr("Bluetooth pepermission missing")
                            if (!AdapterManager.bluetooth) return qsTr("Bluetooth is disabled")
                            return "Error..."
                        }
                        font.pixelSize: Theme.fontSizeContentBig
                        font.bold: true
                        wrapMode: Text.WordWrap
                        color: "white"
                        opacity: 1.0
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        text: {
                            if (!AdapterManager.hasAdapters) {
                                return qsTr("Please check if a Bluetooth adapter is connected and configured on your machine.")
                            } else if (!AdapterManager.bluetoothPermission) {
                                return qsTr("Please check if the Bluetooth permission has been granted to the application.")
                            }
                            return qsTr("Please enable Bluetooth on your machine and retry.")
                        }
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.WordWrap
                        color: "white"
                        opacity: 0.85
                    }
                }

                ////

                Row {
                    spacing: Theme.componentMargin

                    ButtonClear {
                        text: qsTr("Retry")
                        color: "white"

                        onClicked: {
                            AdapterManager.requestBluetoothPermission()
                            AdapterManager.enableBluetooth()
                        }
                    }
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

            Loader {
                id: popupLoader_export

                active: false
                asynchronous: false
                sourceComponent: PopupExportScannerData {
                    id: popupExportScannerData
                    parent: appContent
                }
            }

            Row { // left
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                spacing: Theme.componentMarginXS

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var txt = qsTr("%n device(s) found", "", DeviceManager.deviceCountFound)
                        if (DeviceManager.deviceCountShown !== DeviceManager.deviceCountFound) {
                            txt += "  |  " + qsTr("%n device(s) shown", "", DeviceManager.deviceCountShown)
                        }
                        if (DeviceManager.deviceCountTotal !== DeviceManager.deviceCountCached) {
                            txt += "  |  " + qsTr("%n device(s) cached", "", DeviceManager.deviceCountCached)
                        }
                        //if (DeviceManager.deviceCountBlacklisted > 0) {
                        //    txt += "  |  " + qsTr("%n device(s) blacklisted", "", DeviceManager.deviceCountBlacklisted)
                        //}
                        //if (DeviceManager.deviceCountTotal !== DeviceManager.deviceCountShown) {
                        //    txt += "  |  " + qsTr("%n device(s) total", "", DeviceManager.deviceCountTotal)
                        //}
                        return txt
                    }
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }

                ButtonSunken {
                    anchors.verticalCenter: parent.verticalCenter
                    height: statusBar.height

                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight

                    visible: DeviceManager.deviceCountShown

                    text: qsTr("clear results")
                    onClicked: {
                        DeviceManager.clearResults()
                    }
                }

                ButtonSunken {
                    anchors.verticalCenter: parent.verticalCenter
                    height: statusBar.height

                    colorBackground: Theme.colorActionbar
                    colorHighlight: Theme.colorActionbarHighlight

                    visible: DeviceManager.deviceCountShown

                    text: qsTr("export results")
                    onClicked: {
                        popupLoader_export.active = true
                        popupLoader_export.item.open()
                    }
                }
            }

            Row { // right
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginXS
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMarginXS

                RoundButtonSunken {
                    width: 28; height: 28;
                    anchors.verticalCenter: parent.verticalCenter

                    highlighted: (SettingsManager.scanviewOrientation === Qt.Vertical)
                    source: "qrc:/IconLibrary/material-symbols/bottom_panel_open-fill.svg"

                    colorBackground: Theme.colorActionbar
                    colorHighlight: "transparent"
                    colorRipple: "transparent"
                    colorIcon: highlighted ? Theme.colorPrimary: Theme.colorSubText
                    colorIconHighlight: Theme.colorPrimary

                    onClicked: {
                        SettingsManager.scanviewOrientation = Qt.Vertical

                        splitview.width = splitview.width+1
                        splitview.width = splitview.width-1
                    }
                }
                RoundButtonSunken {
                    width: 28; height: 28;
                    anchors.verticalCenter: parent.verticalCenter

                    highlighted: (SettingsManager.scanviewOrientation === Qt.Horizontal)
                    source: "qrc:/IconLibrary/material-symbols/right_panel_open-fill.svg"

                    colorBackground: Theme.colorActionbar
                    colorHighlight: "transparent"
                    colorRipple: "transparent"
                    colorIcon: highlighted ? Theme.colorPrimary: Theme.colorSubText
                    colorIconHighlight: Theme.colorPrimary

                    onClicked: {
                        SettingsManager.scanviewOrientation = Qt.Horizontal

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

    ////////////////
}
