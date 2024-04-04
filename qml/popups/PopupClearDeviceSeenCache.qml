import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ThemeEngine

Popup {
    id: popupClearDeviceSeenCache

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }

    ////////////////////////////////////////////////////////////////////////////

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: ThemeEngine.isLight ? 0.333 : 0.666
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: ThemeEngine.isLight ? "#aa000000" : "#aaffffff"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: Theme.componentMarginXL

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
                anchors.leftMargin: Theme.componentMarginXL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginXL
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Device seen cache")
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Are you sure you want to clear the device seen cache?")
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
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMarginXL

            Rectangle {
                width: parent.width
                height: Theme.componentHeight
                color: Theme.colorForeground

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.componentMargin
                    anchors.rightMargin: Theme.componentMargin

                    text: qsTr("There are %n device(s) in the cache.", "", deviceManager.deviceSeenCached)
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
                    text: qsTr("Devices in the cache persists between sessions, even if they are not detected nearby.")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    text: qsTr("Clear the cache if you have too many or too old devices.")
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
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMargin

            ButtonWireframe {
                primaryColor: Theme.colorSubText
                secondaryColor: Theme.colorForeground

                text: qsTr("Cancel")
                onClicked: popupClearDeviceSeenCache.close()
            }
            ButtonWireframe {
                fullColor: true
                primaryColor: Theme.colorOrange

                text: qsTr("Clear cache")
                onClicked: {
                    deviceManager.clearDeviceSeenCache()
                    popupClearDeviceSeenCache.close()
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
