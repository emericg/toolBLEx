import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtQuick.Controls.impl 2.15
//import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

Tumbler {
    id: control
    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight * 2

    model: 24

    background: Item {
        //
    }

    delegate: Text {
        text: modelData
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: (control.currentIndex === modelData) ? Theme.colorPrimary : Theme.colorText
        opacity: 1.0 - (Math.abs(Tumbler.displacement) / (control.visibleItemCount * 0.55))
        font.pixelSize: (control.currentIndex === modelData) ? Theme.fontSizeComponent+2 : Theme.fontSizeComponent
        font.bold: false
    }
}
