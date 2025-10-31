import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import ComponentLibrary
import DeviceUtils

Flickable {
    id: panelDeviceLog

    ////////////////

    property string logFormat: "adv" // "adv" or "txt"
    property bool logVisible: (selectedDevice && selectedDevice.deviceLogCount > 0)

    property bool legendVisible: false

    ////////////////

    Item {
        width: parent.width
        height: log_nodata.height + 64

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16

            width: detailView.ww
            height: log_nodata.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: !logVisible

            Text {
                id: log_nodata
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("No event logged yet...")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }
    }

    ////////////////

    Loader {
        anchors.fill: parent

        active: (logFormat === "txt")
        asynchronous: true
        sourceComponent: logTextView
    }

    Loader {
        anchors.fill: parent

        active: (logFormat === "adv")
        asynchronous: true
        sourceComponent: logAdvView
    }

    ////////////////

    Column {
        id: columnLegendLeft

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 8

        visible: logVisible

        Row {
            visible: (logFormat === "adv" && legendVisible)
            spacing: 8

            Repeater {
                model: [
                    "CONNECTION",
                    "STATE",
                    "DATA",
                    "ADVERTISEMENT",
                    "USER ACTION",
                    "ERROR",
                ]
                delegate: Row {
                    spacing: 6

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        radius: 4
                        color: {
                            if (index === 0) return Theme.colorMaterialGreen
                            if (index === 1) return Theme.colorMaterialLime
                            if (index === 2) return Theme.colorMaterialBlue
                            if (index === 3) return Theme.colorMaterialLightBlue
                            if (index === 4) return Theme.colorPrimary
                            if (index === 5) return Theme.colorError
                            return Theme.colorBox
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        textFormat: Text.PlainText
                        color: {
                            if (index === 0) return Theme.colorMaterialGreen
                            if (index === 1) return Theme.colorMaterialLime
                            if (index === 2) return Theme.colorMaterialBlue
                            if (index === 3) return Theme.colorMaterialLightBlue
                            if (index === 4) return Theme.colorPrimary
                            if (index === 5) return Theme.colorError
                            return Theme.colorBox
                        }
                    }
                }
            }
        }

        Row { // buttons row (left)
            spacing: 8

            ButtonSolid { // formatButton
                color: Theme.colorGrey

                text: qsTr("format:") + " " + logFormat

                onClicked: {
                    if (logFormat === "adv") logFormat = "txt"
                    else logFormat = "adv"
                }
            }

            ButtonSolid { // legendButton
                visible: (logFormat === "adv")
                color: legendVisible ? Theme.colorGrey : Theme.colorGrey

                text: qsTr("legend")

                onClicked: {
                    legendVisible = !legendVisible
                }
            }
        }
    }

    ////////////////

    Row { // buttons row (right)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 8

        visible: logVisible

        ButtonSolid { // clearButton
            color: Theme.colorGrey

            text: qsTr("Clear")
            //source: "qrc:/IconLibrary/material-symbols/save.svg"

            onClicked: {
                selectedDevice.clearDeviceLog()
            }
        }

        ButtonSolid { // saveButton
            color: Theme.colorGrey

            text: qsTr("Save")
            source: "qrc:/IconLibrary/material-symbols/save.svg"

            onClicked: {
                var foldersep = "/"
                if (settingsManager.exportDirectory_str.substr(-1) === "/") foldersep = ""

                pathDialog.currentFolder = settingsManager.exportDirectory_url
                pathDialog.selectedFile = settingsManager.exportDirectory_str + foldersep +
                                          selectedDevice.deviceName_export + "-" +
                                          selectedDevice.deviceAddr_export + "-log.txt"
                pathDialog.open()
            }

            ////

            FileDialog {
                id: pathDialog
                title: qsTr("Please choose a file!")
                nameFilters: ["All files (*)"]

                fileMode: FileDialog.SaveFile
                currentFolder: settingsManager.exportDirectory_url
                selectedFile: UtilsPath.makeUrl("log.txt")

                onAccepted: {
                    //console.log("fileDialog currentFolder: " + currentFolder)
                    //console.log("fileDialog selectedFile: " + selectedFile)

                    selectedDevice.exportDeviceLog(UtilsPath.cleanUrl(selectedFile))
                }
            }

            ////
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Component {
        id: logTextView

        ScrollView {
            anchors.fill: parent
            anchors.bottomMargin: columnLegendLeft.height + 16

            TextArea {
                text: (selectedDevice && selectedDevice.deviceLogStr)
                textFormat: Text.PlainText
                color: Theme.colorText
                wrapMode: Text.WrapAnywhere
                readOnly: true
            }
        }
    }

    Component {
        id: logAdvView

        ListView {
            anchors.fill: parent
            bottomMargin: columnLegendLeft.height + 16

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            model: (selectedDevice && selectedDevice.deviceLog)
            delegate: DeviceLogWidget {
                width: ListView.view.width
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
