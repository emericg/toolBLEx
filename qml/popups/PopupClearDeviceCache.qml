import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ThemeEngine

Popup {
    id: popupClearDeviceCache

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.33; to: 1.0; duration: 233; } }

    background: Item {
        Rectangle {
            id: bgrect
            anchors.fill: parent

            radius: Theme.componentRadius
            color: Theme.colorBackground
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth
        }
        DropShadow {
            anchors.fill: parent
            source: bgrect
            color: "#60000000"
            samples: 24
            cached: true
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

            height: 88
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
                spacing: 2

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Clear device cache")
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Are you sure you want to clear the device cache?")
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

                    text: qsTr("There are %n device(s) in the cache.", "", deviceManager.deviceCached)
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
                    text: qsTr("Cached devices persists between session, even if they are not detected nearby.")
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
            anchors.rightMargin: 24
            spacing: 16

            ButtonWireframe {
                primaryColor: Theme.colorSubText
                secondaryColor: Theme.colorForeground

                text: qsTr("Cancel")
                onClicked: popupClearDeviceCache.close()
            }
            ButtonWireframe {
                fullColor: true
                primaryColor: Theme.colorOrange

                text: qsTr("Clear cache")
                onClicked: {
                    popupClearDeviceCache.confirmed()
                    popupClearDeviceCache.close()
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
