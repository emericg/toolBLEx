import QtQuick

import ComponentLibrary

RoundButtonImpl {
    colorBackground: Theme.colorBackground
    colorHighlight: Qt.lighter(colorBackground, 0.92)

    colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.5)
    colorBorder: colorBackground
    colorIcon: Theme.colorIcon
    flat: true
}
