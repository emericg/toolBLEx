import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Templates as T

import ThemeEngine
import DeviceUtils
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + 28 + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12 + (control.source.toString().length && control.text ? 2 : 0)

    font.pixelSize: Theme.componentFontSize
    font.bold: false

    focusPolicy: Qt.NoFocus

    // icon
    property url source: {
        if (!selectedDevice) return ""
        if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
            return "qrc:/assets/icons_material/baseline-bluetooth-24px.svg"
        else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
            return "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
        else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
            return "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
        else
            return "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
    }
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)

    // colors
    property string color: Theme.colorPrimary
    property string colorText: "white"

    // animation
    property bool hoverAnimation: isDesktop

    ////////////////

    text: {
        if (!selectedDevice) return ""
        if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
            return qsTr("scan device")
        else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
            return qsTr("scanning...")
        else if (selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED)
            return qsTr("connected")
        else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
            return qsTr("connecting...")
    }

    ////////////////

    onClicked: {
        if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
            selectedDevice.actionScanWithValues()
        }
    }

    Connections {
        target: screenScanner.item
        function onSelectedDeviceChanged() { actionMenu.close() }
    }

    ////////////////

    MouseArea {
        id: mousearea
        anchors.fill: control

        enabled: control.hoverAnimation
        hoverEnabled: control.hoverAnimation

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: {
            mouseBackground.width = (control.width * 2)
        }
        onReleased: {
            //mouseBackground.width = 0 // disabled, we let the click expand the ripple
        }

        onEntered: {
            mouseBackground.width = 72
        }
        onExited: {
            mouseBackground.width = 0
        }
        onCanceled: {
            mouseBackground.width = 0
        }
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? (mousearea.containsPress && !control.hoverAnimation ? 0.8 : 1.0) : 0.4
        color: control.color
        border.width: Theme.componentBorderWidth
        border.color: Qt.darker(color, 1.03)

        Rectangle { // menu toggle
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            width: 32
            color: Qt.darker(control.color, 1.03)

            IconSvg {
                anchors.centerIn: parent
                width: 28
                height: 28

                Layout.maximumWidth: control.sourceSize
                Layout.maximumHeight: control.sourceSize
                Layout.alignment: Qt.AlignVCenter

                opacity: enabled ? 1.0 : 0.66
                color: control.colorText
                source: "qrc:/assets/icons/material-symbols/more_vert.svg"
            }
        }

        Rectangle { // mouse circle
            id: mouseBackground
            width: 0; height: width; radius: width;
            x: mousearea.mouseX - (width / 2)
            y: mousearea.mouseY - (width / 2)

            visible: control.hoverAnimation
            color: "white"
            opacity: mousearea.containsMouse ? 0.16 : 0
            Behavior on opacity { NumberAnimation { duration: 333 } }
            Behavior on width { NumberAnimation { duration: 200 } }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
        }
    }

    ////////////////

    contentItem: RowLayout {
        x: leftPadding
        height: control.height
        spacing: 6

        IconSvg {
            source: control.source
            width: control.sourceSize
            height: control.sourceSize

            visible: control.source.toString().length
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize
            Layout.alignment: Qt.AlignVCenter

            opacity: enabled ? 1.0 : 0.66
            color: control.colorText
        }
        Text {
            text: control.text
            textFormat: Text.PlainText

            visible: control.text
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            font: control.font
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            opacity: enabled ? (mousearea.containsPress && !control.hoverAnimation ? 0.8 : 1.0) : 0.66
            color: control.colorText
        }
    }

    MouseArea { // menu toggle clickable area
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 32

        hoverEnabled: false
        onClicked: (mouse) => {
            actionMenu.open()
            mouse.accepted = true
        }
    }

    ////////////////

    Popup { // menu
        id: actionMenu
        x: 0
        y: 0
        width: control.width

        padding: 0
        margins: 0

        modal: true
        dim: false
        clip: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        //enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
        //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

        ////////

        background: Rectangle {
            color: control.color
            radius: Theme.componentRadius
            border.color: Theme.colorPrimary
            border.width: Theme.componentBorderWidth

            Rectangle { // menu toggle
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                width: 32
                //height: 32
                color: Qt.darker(control.color, 1.03)

                IconSvg {
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    //anchors.centerIn: parent
                    width: 28
                    height: 28

                    Layout.maximumWidth: control.sourceSize
                    Layout.maximumHeight: control.sourceSize
                    Layout.alignment: Qt.AlignVCenter

                    opacity: enabled ? 1.0 : 0.66
                    color: control.colorText
                    source: "qrc:/assets/icons/material-symbols/more_vert.svg"
                }
            }

            MouseArea { // menu toggle clickable area
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 32

                hoverEnabled: false
                onClicked: (mouse) => {
                    actionMenu.close()
                    mouse.accepted = true
                }
            }

            layer.enabled: control.hoverAnimation
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem:Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }

        ////////

        contentItem: Column {
            width: control.width - 32

            topPadding: 0
            bottomPadding: 0
            spacing: -Theme.componentBorderWidth

            ButtonFlat {
                width: control.width - 32

                color: control.color
                layoutDirection: Qt.RightToLeft
                visible: (selectedDevice && selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)

                text: qsTr("scan services & data")
                source: "qrc:/assets/icons/material-icons/duotone/bluetooth_searching.svg"
                sourceSize: 20

                onClicked: {
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.actionScanWithValues()
                        actionMenu.close()
                    }
                }
            }
            ButtonFlat {
                width: control.width - 32

                color: control.color
                layoutDirection: Qt.RightToLeft
                visible: (selectedDevice && selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)

                text: qsTr("scan services only")
                source: "qrc:/assets/icons/material-icons/duotone/bluetooth_searching.svg"
                sourceSize: 20

                onClicked: {
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.actionScanWithoutValues()
                        actionMenu.close()
                    }
                }
            }
            ButtonFlat {
                width: control.width - 32

                color: control.color
                layoutDirection: Qt.RightToLeft
                visible: (selectedDevice && selectedDevice.hasServiceCache &&
                          selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)

                text: qsTr("load from cache")
                source: "qrc:/assets/icons/material-symbols/save.svg"
                sourceSize: 20

                onClicked: {
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.restoreServiceCache()
                        actionMenu.close()
                    }
                }
            }

            ButtonFlat { // status
                width: control.width - 32

                color: control.color
                visible: (selectedDevice && selectedDevice.status !== DeviceUtils.DEVICE_OFFLINE)

                text: {
                    if (!selectedDevice) return ""
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                        return qsTr("scan device")
                    else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
                        return qsTr("scanning...")
                    else if (selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED)
                        return qsTr("connected")
                    else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                        return qsTr("connecting...")
                }
                source: {
                    if (!selectedDevice) return ""
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                        return "qrc:/assets/icons_material/baseline-bluetooth-24px.svg"
                    else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                        return "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
                    else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
                        return "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
                    else
                        return "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                }

                onClicked: {
                    //
                }
            }
            ButtonFlat {
                width: control.width - 32

                color: control.color
                visible: (selectedDevice && selectedDevice.status !== DeviceUtils.DEVICE_OFFLINE)

                text: (selectedDevice && selectedDevice.connected) ? qsTr("disconnect") : qsTr("abort")
                source: "qrc:/assets/icons/material-icons/outlined/bluetooth_disabled.svg"

                onClicked: {
                    if (selectedDevice.status !== DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.deviceDisconnect()
                        actionMenu.close()
                    }
                }
            }
        }

        ////////
    }

    ////////////////
}
