import QtCore
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import ComponentLibrary
import DeviceUtils

Popup {
    id: popupExportDeviceData

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))

    width: 800
    padding: 0
    margins: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    ////////////////////////////////////////////////////////////////////////////

    property int exportFormat: 0 // 0: text, 1: JSON device profile

    readonly property var exportSuffixes: [".txt", ".toolblex.json"]

    onExportFormatChanged: {
        // swap the suffix of the current path, if it has one of ours
        var path = tfExportPath.text
        for (var i = 0; i < exportSuffixes.length; i++) {
            if (path.endsWith(exportSuffixes[i])) {
                path = path.slice(0, -exportSuffixes[i].length)
                tfExportPath.text = path + exportSuffixes[exportFormat]
                break
            }
        }
    }

    onAboutToShow: {
        buttonError.visible = false

        // reset toggles
        exportFormat = 0
        cbGenericInfo.checked = true
        cbAdvPackets.checked = true
        cbServices.checked = true
        cbData.checked = true
        taComment.text = ""

        var foldersep = "/"
        if (SettingsManager.exportDirectory_str.substr(-1) === "/") foldersep = ""

        tfExportPath.currentFolder = SettingsManager.exportDirectory_url
        tfExportPath.text = SettingsManager.exportDirectory_str + foldersep +
                            selectedDevice.deviceName_export + "-" +
                            selectedDevice.deviceAddr_export + exportSuffixes[exportFormat]
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.333 : 0.666
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground

        Item {
            anchors.fill: parent

            Rectangle { // title area
                anchors.left: parent.left
                anchors.right: parent.right
                height: 96
                color: Theme.colorPrimary
            }

            Rectangle { // border
                anchors.fill: parent
                radius: Theme.componentRadius
                color: "transparent"
                border.color: Theme.colorSeparator
                border.width: Theme.componentBorderWidth
                opacity: 0.4
            }

            layer.enabled: true
            layer.effect: MultiEffect { // clip
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#aa444444"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        spacing: Theme.componentMarginXL

        ////////

        Item { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right
            height: 96

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginXL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginXL
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Export device data")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Text {
                        Layout.fillWidth: true

                        text: selectedDevice.deviceName
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeTitle-4
                        elide: Text.ElideRight
                        color: "white"
                        opacity: 0.92
                    }
                    Text {
                        text: selectedDevice.deviceAddress
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeTitle-4
                        elide: Text.ElideRight
                        color: "white"
                        opacity: 0.88
                    }
                }
            }
        }

        ////////

        Column { // contentArea
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMarginXL

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginS

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    height: 40
                    radius: Theme.componentRadius
                    color: Theme.colorForeground
                    visible: (selectedDevice && selectedDevice.servicesCached)

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24
                        source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"
                        color: Theme.colorSubText
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 52
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Services info loaded from cache")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                    }
                }

                Flow { // status row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Theme.componentMarginS

                    TagClear {
                        height: 36
                        text: qsTr("%n Advertisement packet(s)", "", selectedDevice.advCount)
                        //colorText: Theme.colorSubText
                    }
                    TagClear {
                        height: 36
                        text: qsTr("%n Service(s)", "", selectedDevice.servicesCount)
                        //colorText: Theme.colorSubText
                    }
                    TagClear {
                        height: 36
                        text: qsTr("%n Characteristic(s)", "", selectedDevice.characteristicsCount)
                        //colorText: Theme.colorSubText
                    }

                    ButtonFlat {
                        height: 36

                        text: qsTr("Load cache")
                        //color: Theme.colorSubText

                        visible: (selectedDevice && selectedDevice.hasServiceCache &&
                                  !selectedDevice.servicesCached &&
                                  selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)

                        onClicked: selectedDevice.restoreServiceCache()
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginS

                Text {
                    text: qsTr("Export format")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                SelectorMenuColorful {
                    height: 32

                    model: ListModel {
                        ListElement { idx: 0; txt: qsTr("Device info recap (text)"); src: ""; sz: 16; }
                        ListElement { idx: 1; txt: qsTr("Device structured profile (JSON)"); src: ""; sz: 16; }
                    }

                    currentSelection: popupExportDeviceData.exportFormat
                    onMenuSelected: (index) => {
                        popupExportDeviceData.exportFormat = index
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginS

                Text {
                    text: qsTr("Select data to export")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                Column {
                    Row {
                        CheckBoxThemed {
                            id: cbGenericInfo
                            text: qsTr("Generic info")
                            checked: true
                        }
                        CheckBoxThemed {
                            id: cbAdvPackets
                            text: qsTr("Advertisement packets")
                            checked: true
                        }
                    }
                    Row {
                        CheckBoxThemed {
                            id: cbServices
                            text: qsTr("Services & Characteristics scanned")
                            checked: true
                        }
                        CheckBoxThemed {
                            id: cbData
                            text: qsTr("Characteristics data")
                            checked: true
                        }
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginS

                Text {
                    text: qsTr("Capture comment")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                TextAreaThemed {
                    id: taComment
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Theme.componentHeight * 2

                    wrapMode: Text.Wrap
                    placeholderText: qsTr("Attach a comment to this capture")
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginS

                Text {
                    text: qsTr("Select export file")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                FileInputArea {
                    id: tfExportPath
                    anchors.left: parent.left
                    anchors.right: parent.right

                    dialogTitle: qsTr("Please select the export file")
                    dialogFilter: (popupExportDeviceData.exportFormat === 1)
                                    ? ["Device structured profile (*.toolblex.json)"]
                                    : ["Device info recap (*.txt)"]
                    dialogFileMode: FileDialog.SaveFile

                    currentFolder: SettingsManager.exportDirectory_url
                }
            }
        }

        ////////

        Item  { width: 1; height: 1; } // spacer

        Item {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            height: Theme.componentHeight

            ButtonSolid {
                id: buttonError
                color: Theme.colorWarning
                visible: false
                text: qsTr("Export error :(")
            }

            Row {
                anchors.right: parent.right
                spacing: Theme.componentMargin

                ButtonSolid {
                    color: Theme.colorMaterialGrey

                    text: qsTr("Cancel")
                    onClicked: popupExportDeviceData.close()
                }

                ButtonSolid {
                    color: Theme.colorMaterialAmber

                    text: qsTr("Export data")
                    onClicked: {
                        var status = false

                        if (popupExportDeviceData.exportFormat === 1) {
                            status = selectedDevice.exportDeviceProfile(tfExportPath.text,
                                                                        cbGenericInfo.checked, cbAdvPackets.checked,
                                                                        cbServices.checked, cbData.checked,
                                                                        taComment.text)
                        } else {
                            status = selectedDevice.exportDeviceInfo(tfExportPath.text,
                                                                     cbGenericInfo.checked, cbAdvPackets.checked,
                                                                     cbServices.checked, cbData.checked,
                                                                     taComment.text)
                        }

                        if (status) {
                            buttonError.visible = false
                            popupExportDeviceData.close()
                        } else {
                            buttonError.visible = true
                        }
                    }
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
