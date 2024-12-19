import QtQuick

import ComponentLibrary

SquareButtonImpl {
    property color color: Theme.colorPrimary

    colorBackground: color
    colorHighlight: "white"
    colorBorder: color
    colorIcon: "white"
    flat: true
}
