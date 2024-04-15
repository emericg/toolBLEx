import QtQuick
import ThemeEngine

ButtonImpl {
    property color color: Theme.colorPrimary

    colorBackground: Qt.rgba(color.r, color.g, color.b, 0.2)
    colorHighlight: color
    colorBorder: colorBackground
    colorText: color
    flat: true
}
