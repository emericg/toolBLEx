import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

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
