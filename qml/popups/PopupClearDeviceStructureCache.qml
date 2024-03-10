import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import ThemeEngine

Popup {
    id: popupClearDeviceStructureCache

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 233; } }

    onAboutToShow: deviceManager.countDeviceStructureCached()
    onAboutToHide: deviceManager.countDeviceStructureCached()

    ////////////////////////////////////////////////////////////////////////////

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: ThemeEngine.isLight ? 0.333 : 0.666
    }

    background: Item {
        MultiEffect {
            anchors.fill: parent
            source: bgrect
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: ThemeEngine.isLight ? "#aa000000" : "#aaffffff"
        }
        Rectangle {
            id: bgrect
            anchors.fill: parent

            radius: Theme.componentRadius
            color: Theme.colorBackground
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: 24

        ////////

        Rectangle { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            height: 96
            color: Theme.colorPrimary
            radius: Theme.componentRadius

            border.color: Qt.darker(color, 1.05)
            border.width: Theme.componentBorderWidth

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Device structure cache")
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Are you sure you want to clear the device structure cache files?")
                    font.pixelSize: Theme.fontSizeTitle-4
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.92
                }
            }
        }

        ////////

        Column { // contentArea
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 24

            Rectangle {
                width: parent.width
                height: Theme.componentHeight
                color: Theme.colorForeground

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    text: qsTr("There are %n device(s) in the cache.", "", deviceManager.deviceStructureCached)
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8

                Text {
                    width: parent.width
                    text: qsTr("Devices structure can be saved to disk, so devices services and characteristics can be browsed in the user interface even if the device is offline or not availabe to be re-scanned.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    text: qsTr("Clear the cache files if you have too many or too old devices.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
            }
        }

        ////////

        Item  { width: 1; height: 1; } // spacer

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 16

            ButtonWireframe {
                primaryColor: Theme.colorSubText
                secondaryColor: Theme.colorForeground

                text: qsTr("Cancel")
                onClicked: popupClearDeviceStructureCache.close()
            }
            ButtonWireframe {
                primaryColor: Theme.colorSubText
                secondaryColor: Theme.colorForeground

                text: qsTr("Open folder")
                onClicked: {
                    // TODO
                    Qt.openUrlExternally("file://" +deviceManager.getDeviceStructureDirectory())
                }
            }
            ButtonWireframe {
                fullColor: true
                primaryColor: Theme.colorOrange

                text: qsTr("Clear cache")
                onClicked: {
                    deviceManager.clearDeviceStructureCache()
                    popupClearDeviceStructureCache.close()
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
