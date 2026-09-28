import QtQuick

import ComponentLibrary

ButtonImpl {
    id: control

    colorBackground: Theme.colorBackground

    colorHighlight: UtilsColor.emphasize(control.colorBackground)
    colorRipple: UtilsColor.opacify(control.colorHighlight, 0.5)
    colorBorder: control.colorBackground
    colorText: UtilsColor.contrastColor(control.colorBackground)

    flat: true
}
