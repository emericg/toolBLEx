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
        anchors.margins: Theme.componentMargin

        z: 5
        spacing: Theme.componentMargin
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
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
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

        spacing: Theme.componentMarginS

        ////////

        header: Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMargin
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin

            topPadding: Theme.componentMargin
            bottomPadding: Theme.componentMargin
            spacing: Theme.componentMarginS

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
                    anchors.topMargin: Theme.componentMarginS
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    height: 32
                    spacing: Theme.componentMarginS

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
                    anchors.leftMargin: Theme.componentMargin
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    height: 28
                    spacing: Theme.componentMarginS

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
                    anchors.rightMargin: Theme.componentMargin
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    height: 28
                    spacing: Theme.componentMarginS

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
        anchors.margins: Theme.componentMarginXS
        spacing: Theme.componentMarginXS

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
