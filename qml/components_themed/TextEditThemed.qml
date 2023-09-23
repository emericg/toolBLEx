import QtQuick 2.15

import ThemeEngine 1.0

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
