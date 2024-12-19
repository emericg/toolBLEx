import QtQuick

import ComponentLibrary

RoundButtonImpl {
    property color color: Theme.colorPrimary

    colorBackground: color
    colorHighlight: "white"
    colorBorder: Qt.darker(color, 1.02)
    colorIcon: "white"
    flat: false
}
