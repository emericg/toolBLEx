import QtQuick

import ThemeEngine

TextEdit {
    readOnly: false

    selectByMouse: isDesktop
    selectionColor: Theme.colorPrimary
    selectedTextColor: "white"

    onEditingFinished: focus = false
    Keys.onBackPressed: focus = false

    color: Theme.colorText
    font.pixelSize: Theme.componentFontSize
    wrapMode: Text.WrapAnywhere
}
