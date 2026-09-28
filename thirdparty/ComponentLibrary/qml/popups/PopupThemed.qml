import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ComponentLibrary

/*!
 * \brief Themed popup, made of stacked colored areas sharing one rounded background.
 *
 * Four named slots are available: header, banner, the default slot (body) and footer.
 * Each slot is backed by a PopupSection, only shown when it has content.
 * The sections are sized by their content, and the popup is sized by its sections.
 * Items put in a slot are stacked in a Column, and should use `width: parent.width`.
 *
 * The sections are exposed as headerArea, bannerArea, bodyArea and footerArea,
 * to tweak their color, paddings, minimum height, or to force their visibility (shown).
 */
Popup {
    id: popupThemed

    x: Theme.singleColumn ? 0 : Math.round((Theme.appWidth / 2) - (width / 2))
    y: Theme.singleColumn ? (Theme.appHeight - height)
                          : Math.round((Theme.appHeight / 2) - (height / 2))

    width: {
        if (Theme.singleColumn) return Theme.appWidth
        if (Theme.isTablet && Theme.screenOrientation === Qt.LandscapeOrientation) return 512
        return 720
    }
    padding: 0
    margins: 0

    leftInset: 1
    rightInset: 1
    topInset: 1
    bottomInset: 1

    dim: true
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    // settings
    readonly property real cornerRadius: Theme.singleColumn ? 0 : Theme.componentRadius
    property real bottomSafePadding: Theme.singleColumn ? Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom) : 0

    // areas
    property alias headerArea: sectionHeader
    property alias bannerArea: sectionBanner
    property alias bodyArea: sectionBody
    property alias footerArea: sectionFooter

    // slots
    property alias header: sectionHeader.content
    property alias banner: sectionBanner.content
    property alias footer: sectionFooter.content
    default property alias content: sectionBody.content

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.5; to: 1.0; duration: Theme.animationSpeedFast; } }
    //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animationSpeedMedium; } }

    Overlay.modal: Item {
        Rectangle {
            anchors.fill: parent
            anchors.margins: Theme.windowBorders
            radius: Theme.windowCornersRadius
            color: "#000000"
            opacity: Theme.isLight ? 0.24 : 0.48
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: popupThemed.cornerRadius
        color: Theme.colorBackground

        layer.enabled: !Theme.singleColumn
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            blurMax: 64
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#cc000000"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        implicitHeight: columnSections.implicitHeight

        ////

        Column {
            id: columnSections

            anchors.left: parent.left
            anchors.right: parent.right

            readonly property var sections: [sectionHeader, sectionBanner, sectionBody, sectionFooter]
            readonly property var first: sections.find(s => s.shown) ?? null
            readonly property var last: sections.slice().reverse().find(s => s.shown) ?? null

            ////

            PopupSection {
                id: sectionHeader
                color: Theme.colorPrimary

                topPadding: Theme.componentMarginXL
                bottomPadding: solid ? Theme.componentMarginXL : 0
                minimumHeight: solid ? 80 : 0

                radiusTop: columnSections.first === sectionHeader ? popupThemed.cornerRadius : 0
                radiusBottom: columnSections.last === sectionHeader ? popupThemed.cornerRadius : 0
                safePadding: columnSections.last === sectionHeader ? popupThemed.bottomSafePadding : 0
            }

            ////

            PopupSection {
                id: sectionBanner
                color: Theme.colorForeground

                topPadding: {
                    if (solid) return Theme.componentMargin
                    return (columnSections.first === sectionBanner) ? Theme.componentMarginXL : Theme.componentMarginS
                }
                bottomPadding: solid ? Theme.componentMargin : 0
                minimumHeight: solid ? Theme.componentHeightXL : 0

                radiusTop: columnSections.first === sectionBanner ? popupThemed.cornerRadius : 0
                radiusBottom: columnSections.last === sectionBanner ? popupThemed.cornerRadius : 0
                safePadding: columnSections.last === sectionBanner ? popupThemed.bottomSafePadding : 0
            }

            ////

            PopupSection {
                id: sectionBody
                color: Theme.colorBackground

                topPadding: Theme.componentMarginXL
                bottomPadding: Theme.componentMarginXL

                radiusTop: columnSections.first === sectionBody ? popupThemed.cornerRadius : 0
                radiusBottom: columnSections.last === sectionBody ? popupThemed.cornerRadius : 0
                safePadding: columnSections.last === sectionBody ? popupThemed.bottomSafePadding : 0
            }

            ////

            PopupSection {
                id: sectionFooter
                color: Theme.colorForeground

                topPadding: solid ? Theme.componentMarginL : 0
                bottomPadding: solid ? Theme.componentMarginL : Theme.componentMarginL
                leftPadding: solid ? Theme.componentMarginL : Theme.componentMarginL
                rightPadding: solid ? Theme.componentMarginL : Theme.componentMarginL
                minimumHeight: solid ? Theme.componentHeightXL + Theme.componentMargin * 2 : 0

                radiusTop: columnSections.first === sectionFooter ? popupThemed.cornerRadius : 0
                radiusBottom: columnSections.last === sectionFooter ? popupThemed.cornerRadius : 0
                safePadding: columnSections.last === sectionFooter ? popupThemed.bottomSafePadding : 0
            }

            ////
        }

        ////////

        Rectangle { // area border
            anchors.fill: columnSections
            radius: popupThemed.cornerRadius
            visible: !Theme.singleColumn

            color: "transparent"
            opacity: 0.4
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth
        }

        Rectangle { // top separator (single column)
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.componentBorderWidth
            visible: Theme.singleColumn

            readonly property var first: columnSections.first
            color: (first && first.solid && (first === sectionHeader || first === sectionBanner))
                       ? Qt.darker(first.color, 1.05) : Theme.colorSeparator
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    /*!
     * \brief One area of the popup, sized by the content of its slot.
     *
     * The slot content is vertically centered when minimumHeight is larger than the content.
     * `shown` defaults to "has content", and can be overridden to hide an area that has content.
     * `solid` fills the area with its color, otherwise with the popup background color,
     * and the popup default values for paddings and minimumHeight are tighter.
     * Corner radii and safePadding are driven by the popup, depending on the area position.
     */
    component PopupSection: Item {
        property bool shown: slot.children.length > 0
        property bool solid: true
        property color color: "transparent"

        property real topPadding: Theme.componentMargin
        property real bottomPadding: Theme.componentMargin
        property real leftPadding: Theme.componentMarginXL
        property real rightPadding: Theme.componentMarginXL
        property real minimumHeight: 0
        property real safePadding: 0

        property real radiusTop: 0
        property real radiusBottom: 0

        default property alias content: slot.data

        width: parent ? parent.width : 0
        height: Math.round(Math.max(minimumHeight, slot.implicitHeight + topPadding + bottomPadding) + safePadding)
        visible: shown

        Rectangle {
            anchors.fill: parent

            antialiasing: true
            color: parent.solid ? parent.color : Theme.colorBackground

            topLeftRadius: parent.radiusTop
            topRightRadius: parent.radiusTop
            bottomLeftRadius: parent.radiusBottom
            bottomRightRadius: parent.radiusBottom
        }

        Column {
            id: slot

            anchors.left: parent.left
            anchors.leftMargin: parent.leftPadding
            anchors.right: parent.right
            anchors.rightMargin: parent.rightPadding

            y: {
                const avail = parent.height - parent.safePadding - parent.topPadding - parent.bottomPadding
                return parent.topPadding + Math.max(0, (avail - implicitHeight) / 2)
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
