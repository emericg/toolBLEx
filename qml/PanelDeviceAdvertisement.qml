import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ComponentLibrary
import DeviceUtils

Item {
    id: panelDeviceAdvertisement

    ////////////////

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16

        z: 5
        spacing: 16
        visible: (selectedDevice && !selectedDevice.hasAdvertisement)

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 16 + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && !selectedDevice.hasAdvertisement)

            Text {
                id: adv_nodata
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("No advertisement data...")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }
    }

    ////////////////

    ListView { // advertisementsView
        anchors.fill: parent

        clip: false
        visible: true

        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBarThemed { policy: ScrollBar.AsNeeded; }

        spacing: 12

        ////////

        header: Column {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16

            topPadding: 16
            bottomPadding: 16
            spacing: 12

            visible: (selectedDevice && selectedDevice.hasAdvertisement)

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32 + 32 + 24
                radius: 4

                clip: false
                color: Theme.colorBox
                border.width: 2
                border.color: Theme.colorBoxBorder

                ////

                RowLayout {
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 16

                    height: 32
                    spacing: 12

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 16; height: 16; radius: 4;
                        color: Theme.colorGreen
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Service data")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        color: Theme.colorText
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Manufacturer data")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContentBig
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                        color: Theme.colorText
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 16; height: 16; radius: 4;
                        color: Theme.colorBlue
                    }
                }

                ////

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    height: 28
                    spacing: 12

                    Repeater {
                        model: (selectedDevice && selectedDevice.svd_uuid)

                        ButtonToggle {
                            height: 28

                            text: "0x" + modelData.uuid.toUpperCase()
                            font.bold: false
                            colorBackground: Theme.colorComponent
                            colorText: Theme.colorText

                            checked: modelData.selected
                            onClicked: {
                                modelData.selected = !modelData.selected
                                selectedDevice.advModel.syncUuid(modelData)
                            }
                        }
                    }
                }

                ////

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    height: 28
                    spacing: 12

                    Repeater {
                        model: (selectedDevice && selectedDevice.mfd_uuid)

                        ButtonToggle {
                            height: 28

                            text: "0x" + modelData.uuid.toUpperCase()
                            font.bold: false
                            colorBackground: Theme.colorComponent
                            colorText: Theme.colorText

                            checked: modelData.selected
                            onClicked: {
                                modelData.selected = !modelData.selected
                                selectedDevice.advModel.syncUuid(modelData)
                            }
                        }
                    }
                }

                ////
            }
        }

        ////////

        model: selectedDevice && selectedDevice.advModel
        delegate: AdvertisementDataWidgetAdvanced {
            width: ListView.view.width
        }

        ////////
    }

    ////////////////

    Row { // buttons row
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 8

        ButtonSolid {
            visible: (selectedDevice && selectedDevice.hasAdvertisement)

            text: qsTr("Clear")
            color: Theme.colorGrey

            onClicked: {
                selectedDevice.clearAdvertisement()
            }
        }
    }

    ////////////////
}
