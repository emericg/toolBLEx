import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Rectangle {
    id: devicesSummaryWidget
    height: box.height + 28
    radius: 4

    clip: false
    color: Theme.colorBox
    border.width: 2
    border.color: Theme.colorBoxBorder

    ////////////////

    Column {
        id: box
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMarginL
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginL
        anchors.verticalCenter: parent.verticalCenter

        ////////

        property int legendWidth: 64

        Component.onCompleted: {
            legendWidth = 64
            legendWidth = Math.max(legendWidth, legendDevices.contentWidth)
            legendWidth = Math.max(legendWidth, legendTypes.contentWidth)
            legendWidth = Math.max(legendWidth, legendCache.contentWidth)
        }

        ////////

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            height: 32

            text: qsTr("Devices list")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.colorText
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            Text {
                id: legendDevices
                Layout.preferredWidth: box.legendWidth
                Layout.preferredHeight: 32

                text: qsTr("Devices")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.colorSubText
            }

            Flow {
                Layout.fillWidth: true
                spacing: 4

                TagDesktop {
                    text: qsTr("%n found", "", deviceManager.deviceCountFound)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                }
                TagDesktop {
                    text: qsTr("%n shown", "", deviceManager.deviceCountShown)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                }
                TagDesktop {
                    visible: (deviceManager.deviceCountHidden > 0)
                    text: qsTr("%n hidden", "", deviceManager.deviceCountHidden)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                }
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            Text {
                id: legendTypes
                Layout.preferredWidth: box.legendWidth
                Layout.preferredHeight: 32

                text: qsTr("Types")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.colorSubText
            }

            Flow {
                Layout.fillWidth: true
                spacing: 4

                TagDesktop {
                    text: qsTr("%n Bluetooth Low Energy", "", deviceManager.deviceCountBLE)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                }
                TagDesktop {
                    text: qsTr("%n Bluetooth Classic", "", deviceManager.deviceCountClassic)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                }
                TagDesktop {
                    text: qsTr("%n beacon(s)", "", deviceManager.deviceCountBeacon)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                }
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: (deviceManager.deviceCountCached > 0 ||
                      deviceManager.deviceCountBlacklisted > 0)

            Text {
                id: legendCache
                Layout.preferredWidth: box.legendWidth
                Layout.preferredHeight: 32

                text: qsTr("Cache")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.colorSubText
            }

            Flow {
                Layout.fillWidth: true
                spacing: 4

                TagDesktop {
                    text: qsTr("%n cached", "", deviceManager.deviceCountCached)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                    visible: (deviceManager.deviceCountCached > 0)
                }
                TagDesktop {
                    text: qsTr("%n blacklisted", "", deviceManager.deviceCountBlacklisted)
                    colorBackground: Theme.colorForeground
                    colorBorder: Theme.colorForeground
                    visible: (deviceManager.deviceCountBlacklisted > 0)
                }
            }
        }

        ////////

        Row {
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            ButtonSolid {
                height: Theme.componentHeight

                color: Theme.colorGrey
                enabled: (deviceManager.deviceCountShown > 0)

                text: qsTr("Clear list")
                source: "qrc:/IconLibrary/material-symbols/delete.svg"

                onClicked: deviceManager.clearResults()
            }

            ButtonSolid {
                height: Theme.componentHeight

                color: Theme.colorMaterialAmber
                enabled: (deviceManager.deviceCountShown > 0)

                text: qsTr("Export list")
                source: "qrc:/IconLibrary/material-symbols/share.svg"

                onClicked: devicesSummaryWidget.exportList()
            }
        }

        Item { width: Theme.componentMarginXS; height: Theme.componentMarginXS; } // spacer

        ////////
    }

    ////////////////

    signal exportList()

    ////////////////
}
