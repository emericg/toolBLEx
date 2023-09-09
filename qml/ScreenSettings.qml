import QtQuick
import QtQuick.Controls

import ThemeEngine
import "qrc:/js/UtilsPath.js" as UtilsPath

Loader {
    id: screenSettings

    ////////

    function loadScreen() {
        screenSettings.active = true
        appContent.state = "Settings"
    }

    ////////

    function backAction() {
        if (screenSettings.status === Loader.Ready)
            screenSettings.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        ////////////////

        function backAction() {
            if (ubertoothPath.focus) {
                ubertoothPath.focus = false
                return
            }

            screenScanner.loadScreen()
        }

        ////////////////

        Loader {
            id: popupLoader

            active: false
            asynchronous: false
            sourceComponent: PopupClearDeviceCache {
                id: popupClearCache
                parent: appContent

                onConfirmed: {
                    deviceManager.clearDeviceCache()
                }
            }
        }

        ////////////////

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: settingsColumn.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: settingsColumn
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: 0
                bottomPadding: 20
                spacing: 20

                property int flowElementWidth: (width >= 1080) ? (width / 3) - (spacing*1) - (spacing / 3)
                                                               : (width / 2) - (spacing*1) - (spacing / 2)

                ////////////////////////

                Rectangle {
                    id: settingsHeader
                    anchors.left: parent.left
                    anchors.right: parent.right

                    z: 5
                    clip: true
                    height: isHdpi ? 200 : 230
                    color: Theme.colorActionbar

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        spacing: 64

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 160
                            height: 160
                            radius: 160
                            color: Theme.colorBackground
                            border.width: 2
                            border.color: Theme.colorSeparator

                            IconSvg {
                                anchors.centerIn: parent
                                width: 140
                                height: 140
                                source: "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                                color: "#5483EF" // Theme.colorBlue
                            }

                            Rectangle {
                                id: circlePulseAnimation
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: 160
                                height: 160
                                radius: 160

                                z: -1
                                opacity: 1
                                color: Theme.colorBackground

                                ParallelAnimation {
                                    running: (deviceManager.scanning && !deviceManager.scanningPaused && appContent.state === "Settings")
                                    alwaysRunToEnd: true
                                    loops: Animation.Infinite

                                    NumberAnimation { target: circlePulseAnimation; property: "width"; from: 160; to: 400; duration: 2000; }
                                    NumberAnimation { target: circlePulseAnimation; property: "height"; from: 160; to: 400; duration: 2000; }
                                    OpacityAnimator { target: circlePulseAnimation; from: 0.8; to: 0; duration: 2000; }
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Row {
                                spacing: 32

                                Text {
                                    id: title
                                    anchors.bottom: parent.bottom

                                    text: "toolBLEx"
                                    textFormat: Text.PlainText
                                    font.pixelSize: 40
                                    color: Theme.colorText
                                }

                                Text {
                                    anchors.baseline: title.baseline

                                    text: qsTr("version %1 %2").arg(utilsApp.appVersion()).arg(utilsApp.appBuildMode())
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentBig
                                    color: Theme.colorSubText
                                }

                                Text {
                                    anchors.baseline: title.baseline

                                    visible: utilsApp.isDebugBuild()
                                    text: qsTr("built on %1").arg(utilsApp.appBuildDateTime())
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentBig
                                    color: Theme.colorSubText
                                }
                            }

                            Text {
                                text: qsTr("A Bluetooth Low Energy device scanner and analyzer")
                                font.pixelSize: Theme.fontSizeContentVeryVeryBig
                                color: Theme.colorSubText
                            }

                            Item { width: 8; height: 8; }

                            Row {
                                spacing: 20

                                ButtonWireframeIconCentered {
                                    width: 160
                                    height: 40
                                    fullColor: true
                                    primaryColor: "#5483EF"

                                    text: qsTr("WEBSITE")
                                    //sourceSize: 28
                                    //source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                                    //onClicked: Qt.openUrlExternally("https://emeric.io/toolBLEx")
                                    sourceSize: 20
                                    source: "qrc:/assets/logos/github.svg"
                                    onClicked: Qt.openUrlExternally("https://github.com/emericg/toolBLEx")
                                }

                                ButtonWireframeIconCentered {
                                    width: 160
                                    height: 40
                                    sourceSize: 22
                                    fullColor: true
                                    primaryColor: "#5483EF"

                                    text: qsTr("SUPPORT")
                                    source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                                    onClicked: Qt.openUrlExternally("https://github.com/emericg/toolBLEx/issues")
                                }

                                ButtonWireframeIcon {
                                    height: 40
                                    sourceSize: 22
                                    fullColor: true
                                    primaryColor: "#5483EF"

                                    text: qsTr("Release notes")
                                    source: "qrc:/assets/icons_material/outline-new_releases-24px.svg"
                                    onClicked: Qt.openUrlExternally("https://github.com/emericg/toolBLEx/releases")
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

                ////////////////////////

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20

                    flow: Flow.LeftToRight // Flow.TopToBottom
                    spacing: 20

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Application settings")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
                                color: Theme.colorIcon
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Theme")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter

                                z: 1
                                spacing: 10

                                Rectangle {
                                    id: rectangleLight
                                    width: 80
                                    height: Theme.componentHeight
                                    anchors.verticalCenter: parent.verticalCenter

                                    radius: 4
                                    color: "white"
                                    border.color: (settingsManager.appTheme === "THEME_DESKTOP_LIGHT") ? Theme.colorSecondary : "#757575"
                                    border.width: 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("light")
                                        textFormat: Text.PlainText
                                        color: (settingsManager.appTheme === "THEME_DESKTOP_LIGHT") ? Theme.colorPrimary : "#757575"
                                        font.bold: true
                                        font.pixelSize: Theme.fontSizeContentSmall
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: settingsManager.appTheme = "THEME_DESKTOP_LIGHT"
                                    }
                                }
                                Rectangle {
                                    id: rectangleDark
                                    width: 80
                                    height: Theme.componentHeight
                                    anchors.verticalCenter: parent.verticalCenter

                                    radius: 4
                                    color: "#555151"
                                    border.color: Theme.colorSecondary
                                    border.width: (settingsManager.appTheme === "THEME_DESKTOP_DARK") ? 2 : 0

                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("dark")
                                        textFormat: Text.PlainText
                                        color: (settingsManager.appTheme === "THEME_DESKTOP_DARK") ? Theme.colorPrimary : "#ececec"
                                        font.bold: true
                                        font.pixelSize: Theme.fontSizeContentSmall
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: settingsManager.appTheme = "THEME_DESKTOP_DARK"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Language")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            ComboBoxThemed {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter

                                enabled: false
                                model: ["auto"]
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Unit system")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SelectorMenu {
                                height: 32
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter

                                model: ListModel {
                                    ListElement { idx: 1; txt: qsTr("°C"); src: ""; sz: 16; }
                                    ListElement { idx: 2; txt: qsTr("°F"); src: ""; sz: 16; }
                                }

                                currentSelection: (settingsManager.appUnits === 0) ? 1 : 2
                                onMenuSelected: (index) => {
                                    currentSelection = index
                                    settingsManager.appUnits = index
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Show splashscreen on startup")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemedDesktop {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.appSplashScreen
                                onClicked: settingsManager.appSplashScreen = checked
                            }
                        }
                    }

                    ////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Scanner")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/assets/icons_material/duotone-devices-24px.svg"
                                color: Theme.colorIcon
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Start scanning automatically")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemedDesktop {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.scanAuto
                                onClicked: settingsManager.scanAuto = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Pause scanning while in the background")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemedDesktop {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.scanPause
                                onClicked: settingsManager.scanPause = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Scanning timeout")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SpinBoxThemedDesktop {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                width: 140

                                editable: false
                                legend: "m"
                                from: 0
                                to: 10

                                value: settingsManager.scanTimeout
                                onValueModified: settingsManager.scanTimeout = value
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("RSSI graph interval")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SpinBoxThemedDesktop {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                width: 140

                                editable: false
                                legend: "ms"
                                from: 250
                                to: 2500
                                stepSize: 250

                                value: settingsManager.scanRssiInterval
                                onValueModified: settingsManager.scanRssiInterval = value
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Cache devices automatically")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemedDesktop {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.scanCacheAuto
                                onClicked: settingsManager.scanCacheAuto = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: (deviceManager.deviceCached > 0)

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.componentMargin

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("Clear device cache")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("%1 device(s)").arg(deviceManager.deviceCached)
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorSubText
                                }
                            }

                            ButtonWireframe {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter

                                fullColor: true
                                text: qsTr("Clear")
                                onClicked: {
                                    popupLoader.active = true
                                    popupLoader.item.open()
                                }
                            }
                        }
                    }

                    ////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        visible: (Qt.platform.os === "linux" || Qt.platform.os === "osx")

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Spectrum analyzer")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/assets/icons_material/duotone-microwave-48px.svg"
                                color: Theme.colorIcon
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: colUber.height + 16
                            color: Theme.colorForeground

                            Column {
                                id: colUber
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 52
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    text: qsTr("This feature relies on specific hardware.")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    text: qsTr("Ubertooth One is an open source 2.4 GHz wireless development platform suitable for Bluetooth experimentation.")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                }/*
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    text: "https://greatscottgadgets.com/ubertoothone/"
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                }*/
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/assets/icons_material/baseline-help-24px.svg"
                                color: Theme.colorSubText
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            TextFieldPathThemed {
                                id: ubertoothPath
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter

                                height: 36
                                selectByMouse: true

                                text: settingsManager.ubertooth_path
                                placeholderText: "ubertooth-specan"

                                dialogTitle: qsTr("Please select the path to the ubertooth-specan binary")
                                dialogFilter: ["specan binary (ubertooth-specan)"]

                                //statusSource: ubertooth.toolsAvailable ? "qrc:/assets/icons_material/baseline-check_circle-24px.svg" : ""
                                //statuscolor: Theme.colorSuccess

                                IconSvg {
                                    anchors.right: parent.right
                                    anchors.rightMargin: parent.buttonWidth+4
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 24
                                    height: 24

                                    visible: ubertooth.toolsAvailable
                                    source: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                                    color: Theme.colorSuccess
                                }

                                onTextEdited: {
                                    settingsManager.ubertooth_path = text
                                    ubertooth.checkPath()
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: ubertooth.toolsAvailable

                            RangeSliderThemed {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 2

                                from: 2300
                                to: 2600
                                first.value: settingsManager.ubertooth_freqMin
                                first.onMoved: settingsManager.ubertooth_freqMin = first.value
                                second.value: settingsManager.ubertooth_freqMax
                                second.onMoved: settingsManager.ubertooth_freqMax = second.value
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: ubertooth.toolsAvailable

                            SpinBoxThemedDesktop {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                width: 150

                                hoverEnabled: false
                                editable: false
                                from: 2300
                                to: 2600
                                legend: "MHz"

                                value: settingsManager.ubertooth_freqMin
                                onValueModified: settingsManager.ubertooth_freqMin = value
                            }

                            ButtonThemed {
                                anchors.centerIn: parent
                                visible: (settingsManager.ubertooth_freqMin !== 2402 || settingsManager.ubertooth_freqMax !== 2480)

                                text: qsTr("set default")
                                onClicked: {
                                    settingsManager.ubertooth_freqMin = 2402
                                    settingsManager.ubertooth_freqMax = 2480
                                }
                            }

                            SpinBoxThemedDesktop {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                width: 150

                                hoverEnabled: false
                                editable: false
                                from: 2300
                                to: 2600
                                legend: "MHz"

                                value: settingsManager.ubertooth_freqMax
                                onValueModified: settingsManager.ubertooth_freqMax = value
                            }
                        }
                    }

                    ////
                }

                ////////////////////////

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20
                    flow: Flow.LeftToRight // Flow.TopToBottom
                    spacing: 20

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Third parties")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("This application is made possible thanks to a couple of third party open source projects:")
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeContent
                                wrapMode: Text.WordWrap
                            }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 2

                            Rectangle {
                                width: parent.width * 0.7 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: "- Qt6"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }

                            Rectangle {
                                width: parent.width * 0.3 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.centerIn: parent

                                    text: "LGPL v3"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 2

                            Rectangle {
                                width: parent.width * 0.7 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: "- SingleApplication"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }

                            Rectangle {
                                width: parent.width * 0.3 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.centerIn: parent

                                    text: "MIT"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 2

                            Rectangle {
                                width: parent.width * 0.7 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: "- Google Material Icons"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }

                            Rectangle {
                                width: parent.width * 0.3 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.centerIn: parent

                                    text: "MIT"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 2

                            Rectangle {
                                width: parent.width * 0.7 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: "- Bootstrap Icons"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }

                            Rectangle {
                                width: parent.width * 0.3 - 1
                                height: 32
                                color: Theme.colorForeground

                                Text {
                                    anchors.centerIn: parent

                                    text: "MIT"
                                    textFormat: Text.PlainText
                                    color: Theme.colorText
                                    font.pixelSize: Theme.fontSizeContent
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    ////
                }

                ////////
            }
        }
    }
}
