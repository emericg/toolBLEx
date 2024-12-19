import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.HorizontalHeaderView {
    id: control

    implicitWidth: syncView ? syncView.width : 0
    implicitHeight: 36

    Rectangle { // background
        width: syncView ? syncView.width : 0
        height: parent.height
        color: Theme.colorLVheader
    }

    delegate: Item {
        implicitWidth: 64
        implicitHeight: 34

        Text { // cell title
            anchors.fill: parent
            anchors.margins: 10

            text: {
                if (model[control.textRole] === 1) return ""
                if (model[control.textRole] === 2) return qsTr("Address")
                if (model[control.textRole] === 3) return qsTr("Advertised name")
                if (model[control.textRole] === 4) return qsTr("Manufacturer")
                if (model[control.textRole] === 5) return qsTr("RSSI")
                if (model[control.textRole] === 6) return qsTr("Interval")
                if (model[control.textRole] === 7) return qsTr("Last seen")
                if (model[control.textRole] === 8) return qsTr("First seen")
                return model[control.textRole]
            }
            textFormat: Text.PlainText
            font.bold: ccc
            color: Theme.colorText
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        property bool ccc: {
            if (model[control.textRole] === 2 && deviceManager.orderBy_role === "address") return true
            if (model[control.textRole] === 3 && deviceManager.orderBy_role === "name") return true
            if (model[control.textRole] === 4 && deviceManager.orderBy_role === "manufacturer") return true
            if (model[control.textRole] === 5 && deviceManager.orderBy_role === "rssi") return true
            if (model[control.textRole] === 6 && deviceManager.orderBy_role === "interval") return true
            if (model[control.textRole] === 7 && deviceManager.orderBy_role === "firstseen") return true
            if (model[control.textRole] === 8 && deviceManager.orderBy_role === "lastseen") return true
            return false
        }

        MouseArea {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (model[control.textRole] === 2) deviceManager.orderby_address()
                    else if (model[control.textRole] === 3) deviceManager.orderby_name()
                    else if (model[control.textRole] === 4) deviceManager.orderby_manufacturer()
                    else if (model[control.textRole] === 5) deviceManager.orderby_rssi()
                    else if (model[control.textRole] === 6) deviceManager.orderby_interval()
                    else if (model[control.textRole] === 7) deviceManager.orderby_firstseen()
                    else if (model[control.textRole] === 8) deviceManager.orderby_lastseen()
                } else if (mouse.button === Qt.RightButton) {
                   if (ccc) deviceManager.orderby_default()
                }
            }
        }

        Canvas {
            id: indicatorName
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            width: 8
            height: 4
            rotation: deviceManager.orderBy_order ? 0 : 180
            visible: ccc

            Connections {
                target: ThemeEngine
                function onCurrentThemeChanged() { indicatorName.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width / 2, height)
                ctx.closePath()
                ctx.fillStyle = Theme.colorIcon
                ctx.fill()
            }
        }

        Rectangle { // cell separator
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter

            width: 2
            height: 18
            color: Theme.colorLVseparator
        }
    }

    Rectangle { // bottom separator
        anchors.bottom: parent.bottom
        width: syncView ? syncView.width : 0
        height: 2
        color: Qt.lighter(Theme.colorLVseparator, 1.06)
    }
}
