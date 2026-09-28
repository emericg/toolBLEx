import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.TabBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    // settings
    spacing: 0
    bottomPadding: separatorHeight
    property int separatorHeight: Theme.componentBorderWidth

    // colors
    property color colorBackground: Theme.colorForeground
    property color colorSeparator: Theme.colorSeparator

    ////////////////

    contentItem: ListView {
        model: control.contentModel
        currentIndex: control.currentIndex

        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem
        clip: true

        highlightMoveDuration: 0
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 40
        preferredHighlightEnd: width - 40
    }

    ////////////////

    background: Rectangle {
        color: control.colorBackground

        Rectangle { // bottom separator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: control.separatorHeight
            color: control.colorSeparator
        }
    }

    ////////////////
}
