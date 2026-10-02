import QtQuick

import ComponentLibrary

/*!
 * Bar strip of the most recently received advertisement packets of a device.
 * One bar per packet, its height is the packet RSSI, newest packet on the right.
 * Bars are colored by payload content (manufacturer data, service data, both, or neither).
 */
Item {
    id: advTimelineBars

    property var device: null
    property int barCount: 60 // matches DeviceToolBLEx::s_max_entries_packets
    property int barSpacing: 2

    ////////

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: advTimelineBars.barSpacing

        Repeater {
            model: (advTimelineBars.device && advTimelineBars.device.rssiHistory)

            Rectangle {
                width: (advTimelineBars.width - (advTimelineBars.barCount - 1) * advTimelineBars.barSpacing) / advTimelineBars.barCount
                height: advTimelineBars.height
                radius: 2
                color: Theme.colorForeground

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: ((100 - Math.abs(modelData.rssi)) / 100) * parent.height
                    radius: 2

                    color: {
                        if (modelData.hasMFD && modelData.hasSVD) return Theme.colorOrange
                        if (modelData.hasMFD) return Theme.colorBlue
                        if (modelData.hasSVD) return Theme.colorGreen
                        return Theme.colorPrimary
                    }
                }
            }
        }
    }

    ////////
}
