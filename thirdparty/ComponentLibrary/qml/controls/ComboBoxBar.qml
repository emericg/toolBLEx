import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

/*!
 * \brief A ComboBoxThemed filling a single column layout, side to side.
 *
 * Taller, without radius nor side borders, separated from the content by a line above and below.
 * Meant to be anchored to the screen edges, its texts aligned with the screen margins.
 *
 * \property edge The screen edge the bar is along: Qt.TopEdge (default), opening its list below it,
 *           or Qt.BottomEdge, opening it above it. Any other edge is handled as Qt.TopEdge.
 * \property leftSafeArea, rightSafeArea Width of the screen safe areas beside the control, in pixels:
 *           its background and its list extend under them, their content stays clear of them.
 */
ComboBoxThemed {
    id: control

    leftPadding: Theme.componentMarginXL
    rightPadding: Theme.componentMarginXL

    leftInset: -leftSafeArea
    rightInset: -rightSafeArea

    radius: 0

    colorBackground: control.down ? Theme.colorComponentDown : Qt.lighter(Theme.colorTabletmenu, Theme.isLight ? 1.02 : 1.1)
    colorBackgroundBorder: Theme.colorSeparator

    property int edge: Qt.TopEdge
    indicator.rotation: (popup.visible === (edge !== Qt.BottomEdge)) ? 180 : 0

    property real leftSafeArea: 0
    property real rightSafeArea: 0

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.componentHeightXL

        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground

        Rectangle { // top separator
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: control.colorBackgroundBorder
        }
        Rectangle { // bottom separator
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: control.colorBackgroundBorder
        }
    }

    ////////////////

    popup: T.Popup {
        x: -control.leftSafeArea
        y: (control.edge !== Qt.BottomEdge) ? control.height : -height
        width: control.leftSafeArea + control.width + control.rightSafeArea
        height: contentItem.implicitHeight ? contentItem.implicitHeight + 2 : 0
        padding: 1
        leftPadding: padding + control.leftSafeArea
        rightPadding: padding + control.rightSafeArea

        topMargin: Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop)
        bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }

        background: Rectangle {
            color: Theme.colorComponentBackground

            Rectangle { // separator
                y: (control.edge !== Qt.BottomEdge) ? (parent.height - height) : 0
                width: parent.width
                height: 1
                color: control.colorBackgroundBorder
            }
        }
    }

    ////////////////
}
