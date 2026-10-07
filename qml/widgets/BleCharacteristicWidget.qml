import QtQuick
import QtQuick.Layouts

import ComponentLibrary
import AppUtils

Rectangle {
    id: bleCharacteristicWidget

    height: columnChar.height + 16
    Behavior on height { NumberAnimation { duration: 233 } }

    clip: true
    color: Theme.colorBox

    property var characteristic: modelData

    property bool editable: (selectedDevice && selectedDevice.connected) // && selectedDevice.servicesScanned)

    property bool descriptorsView: false

    ////////////////////////////////

    Loader {
        id: popupLoader_write

        active: false
        asynchronous: false
        sourceComponent: PopupWriteCharacteristic {
            id: popupWriteCharacteristic
            parent: appContent
        }
    }

    ////////////////////////////////

    Rectangle { // vertical bar
        anchors.top: columnChar.top
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin + 2
        anchors.bottom: columnChar.bottom
        width: 2
        opacity: 0.8
        color: Theme.colorSubText
    }
    Rectangle { // background
        anchors.fill: columnChar
        anchors.leftMargin: -Theme.componentMargin + 2
        opacity: 0.24
        color: Theme.colorForeground
    }

    ////////////////////////////////

    Column {
        id: columnChar

        anchors.top: parent.top
        anchors.topMargin: Theme.componentMarginXS
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginXS

        topPadding: 0
        bottomPadding: 0
        spacing: 4

        ////////////////

        Rectangle { // characteristic header
            anchors.left: parent.left
            anchors.leftMargin: -Theme.componentMargin + 4
            anchors.right: parent.right

            height: columnCharHeader.height
            color: Qt.darker(Theme.colorBackground, 1.02)

            Column {
                id: columnCharHeader
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right

                topPadding: 8
                bottomPadding: 8
                spacing: 4

                Text { // characteristic name
                    text: modelData.name
                    font.pixelSize: Theme.fontSizeContentBig
                    font.bold: true
                    color: Theme.colorText
                }

                Row { // characteristic uuid
                    spacing: 4

                    Text {
                        text: qsTr("UUID:")
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        text: modelData.uuid_full
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }
            }
        }

        ////////////////

        Row { // characteristic properties
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Properties:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Repeater {
                anchors.verticalCenter: parent.verticalCenter

                model: modelData.propertiesList
                ItemActionTag {
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: bleCharacteristicWidget.editable
                    text: modelData
                    colorBackground: {
                        if (characteristic) {
                            if (modelData === "Notify" && characteristic.notifyInProgress) return Theme.colorWarning
                            if (modelData === "Read" && characteristic.readInProgress) return Theme.colorWarning
                            if ((modelData === "Write" || modelData === "WriteNoResp") && characteristic.writeInProgress)
                                return Theme.colorWarning
                        }
                        return Theme.colorForeground
                    }
                    highlighted: {
                        if (characteristic) {
                            if (modelData === "Notify") return characteristic.notifyInProgress
                            if (modelData === "Read") return characteristic.readInProgress
                            if (modelData === "Write" || modelData === "WriteNoResp")
                                return characteristic.writeInProgress
                        }
                        return false
                    }
                    onClicked: {
                        if (bleCharacteristicWidget.editable) {
                            if (text === "Notify") {
                                selectedDevice.askForNotify(characteristic.uuid_full)
                            }
                            if (text === "Read") {
                                selectedDevice.askForRead(characteristic.uuid_full)
                            }
                            if (text === "Write" || text === "WriteNoResp") {
                                popupLoader_write.active = true
                                popupLoader_write.item.openCC(characteristic, (text === "Write")
                                                                ? PopupWriteCharacteristic.WriteMode.WithResponse
                                                                : PopupWriteCharacteristic.WriteMode.WithoutResponse)
                            }
                        }
                    }
                }
            }
        }

        ////////////////

        Row { // characteristic configuration (0x2902 / 0x2903)
            spacing: 4

            visible: (bleCharacteristicWidget.characteristic.notificationEnabled ||
                      bleCharacteristicWidget.characteristic.indicationEnabled ||
                      bleCharacteristicWidget.characteristic.broadcastEnabled)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Configuration:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TagClear {
                anchors.verticalCenter: parent.verticalCenter
                visible: bleCharacteristicWidget.characteristic.notificationEnabled
                text: qsTr("notifying")
                color: Theme.colorWarning
            }
            TagClear {
                anchors.verticalCenter: parent.verticalCenter
                visible: bleCharacteristicWidget.characteristic.indicationEnabled
                text: qsTr("indicating")
                color: Theme.colorWarning
            }
            TagClear {
                anchors.verticalCenter: parent.verticalCenter
                visible: bleCharacteristicWidget.characteristic.broadcastEnabled
                text: qsTr("broadcasting")
                color: Theme.colorWarning
            }
        }

        ////////////////

        Row { // characteristic data
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Data:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }

            Text { // characteristic data size
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (modelData.dataSize === 0) {
                        if (selectedDevice.servicesCached) return qsTr("no data from cache")
                        else return qsTr("no data")
                    } else {
                        return modelData.dataSize + " " + qsTr("bytes")
                    }
                }
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        ////////////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: (modelData.dataSize > 0)

            Item {
                height: 26
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 40 // legendWidth

                Text {
                    id: legendData_hex
                    width: 40 // legendWidth
                    height: 26

                    text: qsTr("(hex)")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.colorSubText
                }
            }
            Flow {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: modelData.valueHex_list

                    Rectangle {
                        width: 26
                        height: 26
                        color: (index % 2 === 0) ? Theme.colorForeground : Theme.colorBox
                        border.width: 0
                        border.color: Theme.colorForeground

                        Text {
                            height: 26
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: modelData
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent-1
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.colorText
                            font.family: fontMonospace
                        }
                    }
                }

                Item { width: 4; height: 4; } // spacer

                SquareButtonSunken {
                    id: buttonCopyHex
                    width: 26; height: 26;

                    property bool copied: false
                    colorBackground: copied ? Theme.colorPrimary : Theme.colorBackground

                    source: "qrc:/IconLibrary/material-symbols/content_copy.svg"
                    tooltipText: copied ? qsTr("copied") : qsTr("copy")
                    tooltipPosition: "right"

                    Connections {
                        target: bleCharacteristicWidget.characteristic
                        function onValueChanged() { buttonCopyHex.copied = false }
                    }

                    onClicked: {
                        copied = true
                        UtilsClipboard.setText(modelData.valueHex)
                    }
                }
            }
        }

        ////////////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: (modelData.dataSize > 0)

            Item {
                height: 26
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 40 // legendWidth

                Text {
                    id: legendData_str
                    width: 40 // legendWidth
                    height: 26

                    text: qsTr("(str)")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentSmall
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.colorSubText
                }
            }
            Flow {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: modelData.valueAscii_list

                    Rectangle {
                        width: 26
                        height: 26
                        color: (index % 2 === 0) ? Theme.colorForeground : Theme.colorBox
                        border.width: 0
                        border.color: Theme.colorForeground

                        Text {
                            height: 26
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: modelData
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent-1
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.colorText
                            font.family: fontMonospace
                        }
                    }
                }

                Item { width: 4; height: 4; } // spacer

                SquareButtonSunken {
                    id: buttonCopyAscii
                    width: 26; height: 26;

                    property bool copied: false
                    colorBackground: copied ? Theme.colorPrimary : Theme.colorBackground

                    source: "qrc:/IconLibrary/material-symbols/content_copy.svg"
                    tooltipText: copied ? qsTr("copied") : qsTr("copy")
                    tooltipPosition: "right"

                    Connections {
                        target: bleCharacteristicWidget.characteristic
                        function onValueChanged() { buttonCopyAscii.copied = false }
                    }

                    onClicked: {
                        copied = true
                        UtilsClipboard.setText(modelData.valueAscii)
                    }
                }
            }
        }

        ////////////////
/*
        RowLayout { // DEPRECATED // old way to present characteristic data
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            Text {
                id: t1
                Layout.alignment: Qt.AlignTop

                text: qsTr("Value:")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                Layout.alignment: Qt.AlignTop

                text: "0x"
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TextSelectable {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignBaseline

                text: modelData.valueHex
                font.pixelSize: Theme.fontSizeContent
                font.family: fontMonospace
                wrapMode: Text.WrapAnywhere
                color: Theme.colorText
            }
        }
        RowLayout { // DEPRECATED // old way to present characteristic data
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            visible: modelData.valueAscii.length

            Text {
                id: t2
                Layout.alignment: Qt.AlignTop

                text: qsTr("Value:")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            TextSelectable {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignBaseline

                text: modelData.valueAscii
                color: Theme.colorText
                wrapMode: Text.WrapAnywhere
            }
        }
*/
        ////////////////

        Row { // presentation format (0x2904)
            spacing: 4

            visible: bleCharacteristicWidget.characteristic.hasPresentationFormat

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Format:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater { // one line per presentation format, aggregates have many
                    model: bleCharacteristicWidget.characteristic.formatsList

                    Text {
                        text: modelData
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }
            }
        }

        Text { // aggregate format (0x2905), with formats declared on other characteristics
            visible: !bleCharacteristicWidget.characteristic.formatsResolved
            text: qsTr("Some formats are declared on other characteristics, value not decoded")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorWarning
        }

        ////////////////

        Row { // valid range (0x2906)
            spacing: 4

            visible: bleCharacteristicWidget.characteristic.hasValidRange

            Text {
                text: qsTr("Valid range:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                text: bleCharacteristicWidget.characteristic.validRange
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        Row { // valid range and accuracy (0x2911)
            spacing: 4

            visible: bleCharacteristicWidget.characteristic.hasValidRangeAndAccuracy

            Text {
                text: qsTr("Range and accuracy:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Text {
                text: bleCharacteristicWidget.characteristic.validRangeAndAccuracy
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        ////////////////

        Row { // characteristic value, decoded using the presentation format (0x2904)
            spacing: 4

            visible: (bleCharacteristicWidget.characteristic.valueFormatted_list.length > 0)

            readonly property int expectedSize: bleCharacteristicWidget.characteristic.formatSize
            readonly property bool sizeMismatch: (expectedSize > 0 &&
                                                  bleCharacteristicWidget.characteristic.dataSize !== expectedSize)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Value:")
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater { // one line per presentation format, aggregates have many
                    model: bleCharacteristicWidget.characteristic.valueFormatted_list

                    Text {
                        text: modelData
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: parent.sizeMismatch
                text: qsTr("(format expects %n byte(s))", "", parent.expectedSize)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorWarning
            }
        }

        ////////////////

        Rectangle { // descriptors header
            anchors.left: columnChar.left
            anchors.leftMargin: -Theme.componentMargin + 4
            anchors.right: columnChar.right
            height: 32

            visible: (bleCharacteristicWidget.characteristic.descriptorsCount > 0)
            color: Qt.darker(Theme.colorBackground, maDescriptorHeader.containsMouse ? 1.02 : 1.01)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin - 4
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                ItemBadge {
                    anchors.verticalCenter: parent.verticalCenter
                    text: bleCharacteristicWidget.characteristic.descriptorsCount
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Descriptors")
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }

                IconSvg {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.colorIcon
                    source: bleCharacteristicWidget.descriptorsView ?
                                "qrc:/IconLibrary/material-symbols/unfold_less.svg" :
                                "qrc:/IconLibrary/material-symbols/unfold_more.svg"
                }
            }

            MouseArea {
                id: maDescriptorHeader
                anchors.fill: parent
                hoverEnabled: true
                onClicked: bleCharacteristicWidget.descriptorsView = !bleCharacteristicWidget.descriptorsView
            }
        }

        ////////////////

        Column { // descriptors list
            id: columnDescriptor

            width: parent.width

            topPadding: 12
            bottomPadding: 12
            spacing: 12

            visible: (bleCharacteristicWidget.descriptorsView &&
                      bleCharacteristicWidget.characteristic.descriptorsCount > 0)

            Repeater {
                model: bleCharacteristicWidget.characteristic.descriptorsList

                BleDescriptorWidget {
                    width: parent.width
                }
            }
        }

        ////////////////
    }

    ////////////////////////////////
}
