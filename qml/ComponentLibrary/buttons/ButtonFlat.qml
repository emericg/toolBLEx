import QtQuick
import ThemeEngine

ButtonImpl {
    property color color: Theme.colorPrimary

    colorBackground: color
    colorHighlight: "white"
    colorBorder: color
    colorText: "white"
    flat: true
}
