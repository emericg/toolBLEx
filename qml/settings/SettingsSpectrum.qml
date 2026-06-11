import QtQuick
import QtQuick.Dialogs

import ComponentLibrary

Column { // SPECTRUM ANALYZERS

    width: 512
    spacing: 2

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorActionbar

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
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
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/IconLibrary/material-icons/duotone/microwave.svg"
            color: Theme.colorIcon
        }
    }

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: txtAnalyzers1.height + 16
        color: Theme.colorForeground

        IconSvg {
            width: 28
            height: 28
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
            color: Theme.colorSubText
            opacity: 0.5
        }

        Text {
            id: txtAnalyzers1
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("This feature relies on specific hardware.")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
            wrapMode: Text.WordWrap
        }
    }

    ////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: txtAnalyzers2.height + 16
        color: Theme.colorForeground

        visible: (Qt.platform.os === "windows")

        IconSvg {
            width: 28
            height: 28
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"
            color: Theme.colorWarning
            opacity: 1
        }

        Text {
            id: txtAnalyzers2
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Spectrum analyzers are not available for Windows.")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
            wrapMode: Text.WordWrap
        }
    }

    ////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: txtUber.height + 16
        color: Theme.colorForeground

        IconSvg {
            width: 28
            height: 28
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/IconLibrary/material-symbols/help-fill.svg"
            color: Theme.colorSubText
            opacity: 0.5
        }

        Text {
            id: txtUber
            anchors.left: parent.left
            anchors.leftMargin: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("<a href=\"https://greatscottgadgets.com/ubertoothone/\">Ubertooth One</a> is an open source 2.4 GHz wireless development platform suitable for Bluetooth experimentation.")
            textFormat: Text.StyledText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
            linkColor:Theme.colorText
            wrapMode: Text.WordWrap

            onLinkActivated: (link) => {
                Qt.openUrlExternally(link)
            }
        }
    }

    ////

    Column {
        width: settingsColumn.flowElementWidth
        spacing: 2

        enabled: (Qt.platform.os === "linux" || Qt.platform.os === "osx")

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            FileInputArea {
                id: ubertoothPath
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                selectByMouse: true

                text: SettingsManager.ubertooth_path
                placeholderText: "ubertooth-specan"

                dialogTitle: qsTr("Please specify the path to the ubertooth-specan binary")
                dialogFilter: ["specan binary (ubertooth-specan)"]
                dialogFileMode: FileDialog.OpenFile

                IconSvg {
                    anchors.right: parent.right
                    anchors.rightMargin: parent.buttonWidth+4
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24

                    visible: ubertooth.toolsAvailable
                    source: "qrc:/IconLibrary/material-symbols/check_circle.svg"
                    color: Theme.colorSuccess
                }

                onTextChanged: {
                    SettingsManager.ubertooth_path = text
                    ubertooth.checkPaths()
                }
            }
        }

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            RangeSliderThemed {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 2

                from: 2300
                to: 2600
                first.value: SettingsManager.ubertooth_freqMin
                first.onMoved: {
                    SettingsManager.ubertooth_freqMin = first.value
                    if (ubertooth.running) {
                        restartUbertoothTimer.restart()
                    }
                }
                second.value: SettingsManager.ubertooth_freqMax
                second.onMoved: {
                    SettingsManager.ubertooth_freqMax = second.value
                    if (ubertooth.running) {
                        restartUbertoothTimer.restart()
                    }
                }
            }
        }

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            SpinBoxThemedDesktop {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                z: 2

                hoverEnabled: false
                editable: false
                from: 2300
                to: 2600
                legend: "MHz"

                value: SettingsManager.ubertooth_freqMin
                onValueModified: {
                    SettingsManager.ubertooth_freqMin = value
                    if (ubertooth.running) {
                        restartUbertoothTimer.restart()
                    }
                }
            }

            ButtonDesktop {
                anchors.centerIn: parent
                visible: (SettingsManager.ubertooth_freqMin !== 2402 || SettingsManager.ubertooth_freqMax !== 2480)

                text: qsTr("2.4 GHz Default")
                onClicked: {
                    SettingsManager.ubertooth_freqMin = 2400
                    SettingsManager.ubertooth_freqMax = 2500
                    if (ubertooth.running) {
                        ubertooth.restartWork()
                    }
                }
            }

            SpinBoxThemedDesktop {
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                z: 2

                hoverEnabled: false
                editable: false
                from: 2300
                to: 2600
                legend: "MHz"

                value: SettingsManager.ubertooth_freqMax
                onValueModified: {
                    SettingsManager.ubertooth_freqMax = value
                    if (ubertooth.running) {
                        restartUbertoothTimer.restart()
                    }
                }
            }
        }

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: txtStrRtl.height + 16
            color: Theme.colorForeground

            IconSvg {
                width: 28
                height: 28
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/IconLibrary/material-symbols/help-fill.svg"
                color: Theme.colorSubText
                opacity: 0.5
            }

            Text {
                id: txtStrRtl
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("<a href=\"https://www.rtl-sdr.com/about-rtl-sdr/\">RTL-SDR</a> are affordable USB dongles that can be used as a computer based radio scanner for receiving live radio signals.")
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
                linkColor:Theme.colorText
                wrapMode: Text.WordWrap

                onLinkActivated: (link) => {
                    Qt.openUrlExternally(link)
                }
            }
        }

        ////

        Column {
            width: settingsColumn.flowElementWidth
            spacing: 2

            enabled: (Qt.platform.os === "linux" || Qt.platform.os === "osx")

            ////

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48
                color: Theme.colorForeground

                FileInputArea {
                    id: rtlsdrPath
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    anchors.verticalCenter: parent.verticalCenter

                    selectByMouse: true

                    text: SettingsManager.rtlsdr_path
                    placeholderText: "soapy_power, rtl_power_fftw, rtl_power"

                    dialogTitle: qsTr("Please specify the path to the choosen RtlSdr binary")
                    dialogFilter: ["specan binary (soapy_power, rtl_power_fftw, rtl_power)"]
                    dialogFileMode: FileDialog.OpenFile

                    IconSvg {
                        anchors.right: parent.right
                        anchors.rightMargin: parent.buttonWidth+4
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24

                        visible: rtlsdr.toolsAvailable
                        source: "qrc:/IconLibrary/material-symbols/check_circle.svg"
                        color: Theme.colorSuccess
                    }

                    onTextChanged: {
                        SettingsManager.rtlsdr_path = text
                        rtlsdr.checkPaths()
                    }
                }
            }

            ////

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48
                color: Theme.colorForeground

                SliderThemed {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 2

                    from: 52
                    to: 2200
                    value: SettingsManager.rtlsdr_freqTarget
                    onMoved: {
                        SettingsManager.rtlsdr_freqTarget = value
                        if (rtlsdr.running) {
                            restartRtlSdrTimer.restart()
                        }
                    }
                }
            }

            ////

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48
                clip: true

                color: Theme.colorForeground

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    height: 48
                    spacing: 8

                    SpinBoxThemedDesktop {
                        anchors.verticalCenter: parent.verticalCenter

                        hoverEnabled: false
                        editable: false
                        from: 52
                        to: 2200
                        legend: "MHz"

                        value: SettingsManager.rtlsdr_freqTarget
                        onValueModified: {
                            SettingsManager.rtlsdr_freqTarget = value
                            if (rtlsdr.running) {
                                restartRtlSdrTimer.restart()
                            }
                        }
                    }

                    ButtonDesktop {
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("100 MHz")
                        onClicked: {
                            SettingsManager.rtlsdr_freqTarget = 100
                            if (rtlsdr.running) {
                                restartRtlSdrTimer.restart()
                            }
                        }
                    }
                    ButtonDesktop {
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("433 MHz")
                        onClicked: {
                            SettingsManager.rtlsdr_freqTarget = 433
                            if (rtlsdr.running) {
                                restartRtlSdrTimer.restart()
                            }
                        }
                    }
                    ButtonDesktop {
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("868 MHz")
                        onClicked: {
                            SettingsManager.rtlsdr_freqTarget = 868
                            if (rtlsdr.running) {
                                restartRtlSdrTimer.restart()
                            }
                        }
                    }
                }
            }

            ////
        }

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Scanning bandwidth")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                font.bold: false
                color: Theme.colorText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            SpinBoxThemedDesktop {
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                z: 2

                hoverEnabled: false
                editable: false
                from: 2400
                to: 3200
                stepSize: 100
                legend: "kHz"

                value: SettingsManager.rtlsdr_freqBandwidth
                onValueModified: {
                    SettingsManager.rtlsdr_freqBandwidth = value
                    if (rtlsdr.running) {
                        restartRtlSdrTimer.restart()
                    }
                }
            }
        }

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Maximum sampling frequency")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                font.bold: false
                color: Theme.colorText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            SpinBoxThemedDesktop {
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                editable: false
                legend: "Hz"
                from: 10
                to: 120
                stepSize: 1

                value: SettingsManager.spectrogram_samplingFreq
                onValueModified: {
                    SettingsManager.spectrogram_samplingFreq = value
                    if (ubertooth.running) {
                        //restartUbertoothTimer.restart()
                    }
                }
            }
        }

        ////

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("History curves")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                font.bold: false
                color: Theme.colorText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            SpinBoxThemedDesktop {
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                editable: false
                from: 16
                to: 64
                stepSize: 1

                value: SettingsManager.spectrogram_historyCurves
                onValueModified: {
                    SettingsManager.spectrogram_historyCurves = value
                    if (ubertooth.running) {
                        //restartUbertoothTimer.restart()
                    }
                }
            }
        }

        ////
/*
        Rectangle { // DEBUG
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: Theme.colorForeground

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Graph load")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                font.bold: false
                color: Theme.colorText
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            ButtonFlat {
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                property int pointCount: (SettingsManager.ubertooth_freqMax - SettingsManager.ubertooth_freqMin) *
                                          SettingsManager.spectrogram_samplingFreq * SettingsManager.spectrogram_historyCurves

                text: (pointCount / 1000) + "k points"

                color: {
                    if (pointCount > 256000) return Theme.colorMaterialRed
                    if (pointCount > 192000) return Theme.colorMaterialOrange
                    if (pointCount > 128000) return Theme.colorMaterialAmber
                    if (pointCount > 64000) return Theme.colorMaterialLightGreen
                    return Theme.colorMaterialLime
                }
            }
        }
*/
        ////
    }

    ////////
}
