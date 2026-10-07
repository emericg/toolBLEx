import QtQuick
import QtQuick.Layouts

import ComponentLibrary
import AppUtils

Item {
    id: bleDescriptorWidget

    width: parent.width
    height: columnDescriptor.height

    property var descriptor: modelData

    property bool editable: (selectedDevice && selectedDevice.connected)

    Rectangle {
        id: background
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4

        height: columnDescriptor.height
        radius: 4
        color: Theme.colorBox

        ////////

        Column {
            id: columnDescriptor

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 4

            topPadding: 2
            bottomPadding: 2
            spacing: 0

            ////

            Item { // title and actions
                width: parent.width
                height: Math.max(28, rowTitle.height)

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: -2
                    height: parent.height
                    radius: 3
                    color: Qt.darker(Theme.colorBackground, 1.01)
                }

                Row {
                    id: rowTitle
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.right: rowActions.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: bleDescriptorWidget.descriptor.name
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: "(" + bleDescriptorWidget.descriptor.uuid_short + ")"
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        //font.family: fontMonospace
                        color: Theme.colorSubText
                    }
                }

                Row {
                    id: rowActions
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    SquareButtonSunken {
                        width: 24; height: 24;

                        visible: bleDescriptorWidget.descriptor.readable
                        enabled: bleDescriptorWidget.editable

                        tooltipText: qsTr("read")
                        tooltipPosition: "left"
                        source: "qrc:/IconLibrary/material-symbols/refresh.svg"

                        colorBackground: {
                            if (bleDescriptorWidget.descriptor.readInProgress) return Theme.colorWarning
                            if (bleDescriptorWidget.descriptor.readInError) return Theme.colorError
                            return Theme.colorBackground
                        }

                        onClicked: selectedDevice.askForDescriptorRead(bleDescriptorWidget.descriptor)
                    }

                    SquareButtonSunken {
                        id: buttonCopy
                        width: 24; height: 24;

                        visible: (bleDescriptorWidget.descriptor.dataSize > 0)

                        tooltipText: qsTr("copy")
                        tooltipPosition: "left"
                        source: "qrc:/IconLibrary/material-symbols/content_copy.svg"

                        property bool copied: false
                        colorBackground: copied ? Theme.colorPrimary : Theme.colorBackground

                        Connections {
                            target: bleDescriptorWidget.descriptor
                            function onValueChanged() { buttonCopy.copied = false }
                        }

                        onClicked: {
                            copied = true
                            UtilsClipboard.setText(bleDescriptorWidget.descriptor.valueHex)
                        }
                    }
                }
            }

            ////

            Item { // data
                width: parent.width
                height: Math.max(28, dataTxt.height)

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: -2
                    height: parent.height
                    color: Qt.darker(Theme.colorBackground, 1.00)
                }

                TextSelectable {
                    id: dataTxt
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 4

                    visible: (bleDescriptorWidget.descriptor.dataSize > 0)
                    color: Theme.colorSubText

                    text: "0x" + bleDescriptorWidget.descriptor.valueHex
                    font.pixelSize: Theme.fontSizeContent
                    font.family: fontMonospace
                    wrapMode: Text.WrapAnywhere
                }
            }

            ////

            Column {
                id: columnFields
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4

                topPadding: 4
                bottomPadding: 4
                spacing: 2

                readonly property int legendWidth: {
                    const fields = bleDescriptorWidget.descriptor.fields
                    let w = 0
                    for (let i = 0; i < fields.length; i++) {
                        w = Math.max(w, fontMetricsLegend.advanceWidth(fields[i].label))
                    }
                    return Math.ceil(w)
                }
                FontMetrics {
                    id: fontMetricsLegend
                    font.pixelSize: Theme.fontSizeContent
                }

                Repeater { // decoded fields
                    model: bleDescriptorWidget.descriptor.fields

                    RowLayout {
                        required property var modelData

                        width: columnFields.width
                        spacing: 4

                        Text {
                            Layout.preferredWidth: columnFields.legendWidth

                            text: modelData.label
                            textFormat: Text.PlainText
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                        }
                        Text {
                            Layout.fillWidth: true

                            text: modelData.value
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                            wrapMode: Text.Wrap
                            color: Theme.colorText
                        }
                    }
                }
            }

            ////
        }

        ////////
    }

    Rectangle {
        anchors.fill: background
        radius: 4
        color: "transparent"
        border.color: Theme.colorSeparator
        border.width: 2
    }
}
