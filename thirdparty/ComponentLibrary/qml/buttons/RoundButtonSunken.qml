import QtQuick

import ComponentLibrary

SquareButtonImpl {
    colorBackground: Theme.colorBackground

    colorHighlight: UtilsColor.emphasize(colorBackground)
    colorRipple: UtilsColor.opacify(colorHighlight, 0.5)
    colorBorder: colorBackground
    colorIcon: UtilsColor.contrastColor(colorBackground)

    flat: true
    radius: width / 2
}
