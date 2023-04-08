import QtQuick
import QtQuick.Templates as T

import ThemeEngine 1.0

T.HorizontalHeaderView {
    id: control

    implicitWidth: syncView ? syncView.width : 0
    implicitHeight: 36

    Rectangle { // background
        width: syncView ? syncView.width : 0
        height: 36
        color: Theme.colorLVheader
    }

    delegate: Item {
        implicitWidth: 64
        implicitHeight: 34

        Text { // cell title
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.colorText

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
