import QtQuick

import ComponentLibrary

TextInput {
    id: control

    color: Theme.colorText
    font.pixelSize: Theme.fontSizeContent
    verticalAlignment: Text.AlignVCenter

    readOnly: true
    selectByMouse: true
    selectionColor: Theme.colorPrimary
    selectedTextColor: "white"
}
