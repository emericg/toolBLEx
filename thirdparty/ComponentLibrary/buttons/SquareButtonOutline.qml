import QtQuick

import ComponentLibrary

SquareButtonImpl {
    property color color: Theme.colorPrimary

    colorBackground: "transparent"
    colorHighlight: color
    colorBorder: Qt.rgba(color.r, color.g, color.b, 0.5)
    colorIcon: color
    flat: true
}
