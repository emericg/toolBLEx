import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Popup {
    id: popupClearDeviceCache
    x: (appWindow.width / 2) - (width / 2)
    y: singleColumn ? (appWindow.height - height) : ((appWindow.height / 2) - (height / 2) /*- (appHeader.height)*/)

    width: singleColumn ? parent.width : 640
    height: columnContent.height + padding*2
    padding: singleColumn ? 20 : 24

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: singleColumn ? 0 : Theme.componentBorderWidth
        radius: singleColumn ? 0 : Theme.componentRadius

        Rectangle {
            width: parent.width
            height: Theme.componentBorderWidth
            visible: singleColumn
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: columnContent
            width: parent.width
            spacing: 20

            Text {
                width: parent.width

                text: qsTr("Are you sure you want to clear the device cache?")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Rectangle {
                width: parent.width
                height: Theme.componentHeight
                color: Theme.colorForeground

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    text: qsTr("There are %1 device(s) in the cache.").arg(deviceManager.deviceCached)
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                width: parent.width

                text: qsTr("Cached devices will persist between session, even if they are not detected nearby.") + "<br>" +
                      qsTr("Clear the cache if you have too many or too old devices.")
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                wrapMode: Text.WordWrap
            }

            Flow {
                id: flowContent
                width: parent.width
                height: singleColumn ? 120+32 : 40

                property var btnSize: singleColumn ? width : ((width-spacing) / 2)
                spacing: 16

                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Cancel")
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground

                    onClicked: popupClearDeviceCache.close()
                }
                ButtonWireframe {
                    width: parent.btnSize

                    text: qsTr("Clear cache")
                    primaryColor: Theme.colorOrange
                    fullColor: true

                    onClicked: {
                        popupClearDeviceCache.confirmed()
                        popupClearDeviceCache.close()
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
