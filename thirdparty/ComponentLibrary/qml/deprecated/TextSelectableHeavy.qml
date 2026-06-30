import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.TextField {
    id: control

    implicitWidth: textMetrics.boundingRect.width + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             topPadding + bottomPadding)

    color: Theme.colorText
    font.pixelSize: Theme.fontSizeContent
    //verticalAlignment: Text.AlignVCenter

    readOnly: true
    selectByMouse: true
    selectionColor: Theme.colorPrimary
    selectedTextColor: "white"

    background: Item {
        implicitWidth: 128
        implicitHeight: 16
    }

    TextMetrics {
        id: textMetrics
        font: control.font
        text: control.text
    }
}
