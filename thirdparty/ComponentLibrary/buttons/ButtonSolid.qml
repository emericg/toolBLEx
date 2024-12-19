import QtQuick

import ComponentLibrary

ButtonImpl {
    property color color: Theme.colorPrimary

    colorBackground: color
    colorHighlight: "white"
    colorBorder: Qt.darker(color, 1.02)
    colorText: "white"
    flat: false
}
