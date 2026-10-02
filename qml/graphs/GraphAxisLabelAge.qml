import QtQuick

import ComponentLibrary

/*!
 * Axis label delegate for time axes expressed as (negative) seconds before now.
 * Shows "60s" ... "10s", and "now" for 0.
 */
Item {
    property string text

    Text {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        text: {
            var v = Math.round(Math.abs(Number(parent.text)))
            return (v === 0) ? qsTr("now") : v + "s"
        }
        color: Theme.colorSubText
        font.pixelSize: Theme.fontSizeContentVerySmall
    }
}
