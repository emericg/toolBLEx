import QtQuick
import QtQuick.Controls.Material.impl as QQuickMaterial

import ComponentLibrary

QQuickMaterial.Ripple {
    clip: true
    color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.5)
}
