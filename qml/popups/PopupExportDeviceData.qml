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
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    ////////////////////////////////////////////////////////////////////////////

    onAboutToShow: {
        buttonError.visible = false

        cbGenericInfo.checked = true
        cbAdvPackets.checked = true
        cbServices.checked = true
        cbData.checked = true

        var foldersep = "/"
        if (settingsManager.exportDirectory_str.substr(-1) === "/") foldersep = ""

        tfExportPath.currentFolder = settingsManager.exportDirectory_url
        tfExportPath.text = settingsManager.exportDirectory_str + foldersep +
                            selectedDevice.deviceName_export + "-" +
                            selectedDevice.deviceAddr_export + ".txt"
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: ThemeEngine.isLight ? 0.333 : 0.666
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
            shadowColor: ThemeEngine.isLight ? "#aa000000" : "#aaffffff"
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
                        font.pixelSize: Theme.fontSizeTitle-4
                        elide: Text.ElideRight
                        color: "white"
                        opacity: 0.92
                    }
                    Text {
                        text: selectedDevice.deviceAddress
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
                spacing: 12

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
                        color: Theme.colorSubText
                    }
                }

                Flow { // status row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    TagClear {
                        height: 36
                        text: qsTr("%n adv packet(s)", "", selectedDevice.advCount)
                        //colorText: Theme.colorSubText
                    }
                    TagClear {
                        height: 36
                        text: qsTr("%n service(s)", "", selectedDevice.servicesCount)
                        //colorText: Theme.colorSubText
                    }
                    TagClear {
                        height: 36
                        text: qsTr("%n characteristic(s)", "", selectedDevice.characteristicsCount)
                        //colorText: Theme.colorSubText
                    }

                    ButtonFlat {
                        height: 36

                        text: qsTr("load cache")
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
                spacing: 12

                Text {
                    text: qsTr("Select data to export")
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
                            text: qsTr("Services scanned")
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
                spacing: 12

                Text {
                    text: qsTr("Select export file")
                    color: Theme.colorText
                }

                FileInputArea {
                    id: tfExportPath
                    anchors.left: parent.left
                    anchors.right: parent.right

                    dialogTitle: qsTr("Please select the export file")
                    dialogFilter: ["Text file (*.txt)"]
                    dialogFileMode: FileDialog.SaveFile

                    currentFolder: settingsManager.exportDirectory_url
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
                        var status = selectedDevice.exportDeviceInfo(tfExportPath.text,
                                                                     cbGenericInfo.checked, cbAdvPackets.checked,
                                                                     cbServices.checked, cbData.checked)
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
