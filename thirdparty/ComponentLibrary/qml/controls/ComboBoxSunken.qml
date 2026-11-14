import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

ComboBoxThemed {
    id: control

    colorBackground: control.down ? UtilsColor.emphasize(Theme.colorBackground) : Theme.colorBackground
    colorBackgroundBorder: control.colorBackground

    ////////////////

    popup: T.Popup {
        width: control.width
        height: contentItem.implicitHeight ? contentItem.implicitHeight + 4 : 0
        padding: 2

        topMargin: Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop)
        bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }

        background: Rectangle {
            radius: control.radius
            color: Theme.colorComponentBackground
        }
    }

    ////////////////
}
