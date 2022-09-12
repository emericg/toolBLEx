import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.TextField {
    id: control

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             topPadding + bottomPadding)

    text: ""
    color: Theme.colorText
    font.pixelSize: Theme.fontSizeContent
    verticalAlignment: Text.AlignVCenter

    readOnly: true
    selectByMouse: true
    selectionColor: Theme.colorPrimary
    selectedTextColor: "white"

    background: Item {
        implicitWidth: 256
        implicitHeight: 20
    }
}
