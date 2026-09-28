import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

/*!
 * \brief Sidebar header item, with an icon, a title, and an action bar.
 *
 * The action bar is a slot (default property) populated by the caller,
 * items are laid out horizontally inside a RowLayout of barHeight height.
 * The bar is hidden when it has no visible items.
 */
T.Button {
    id: control

    anchors.left: parent.left
    anchors.right: parent.right
    height: headerHeight + (barVisible ? barHeight : 0)

    leftPadding: 0
    rightPadding: 0
    spacing: 12

    font.pixelSize: Theme.fontSizeContentBig
    font.bold: true

    // settings
    flat: true
    checkable: false
    hoverEnabled: isDesktop
    focusPolicy: Qt.NoFocus

    // layout
    property int headerHeight: Theme.componentHeight + 20
    property int barHeight: Theme.componentHeightS
    property int barSpacing: 2
    property bool barEnabled: checked
    readonly property bool barVisible: barRow.visibleChildren.length > 0

    // icon
    property url source
    property color sourceColor: {
        if (!checked) return Theme.isLight ? "#999" : Theme.colorGrey
        return Theme.colorPrimary
    }

    // action bar slot
    default property alias barContent: barRow.data

    // colors
    property color color: checked ? Theme.colorPrimary : Theme.colorSidebarContent
    property color colorBackground: Qt.rgba(color.r, color.g, color.b, checked ? 0.2 : 1)
    property color colorHighlight: checked ? Theme.colorPrimary : Theme.colorSidebarHighlight
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.16)
    property color colorText: checked ? Theme.colorPrimary : Theme.colorSubText
    property color colorBarBackground: barColor(checked ? Theme.colorPrimary : Theme.colorSidebarHighlight, 0.33)

    // colors (helpers for the action bar items)
    property color colorButtonPrimary: barColor(Theme.colorPrimary, 0.66)
    property color colorButtonBlue: barColor(Theme.colorBlue, 0.77)
    property color colorButtonOrange: barColor(Theme.colorOrange, 0.66)

    /*!
     * \brief Compute an action bar item background color.
     * \param c: the color used when the header is checked.
     * \param alpha: the opacity applied to that color.
     * \return the translucent color if checked, a neutral sidebar color otherwise.
     */
    function barColor(c, alpha) {
        if (checked) return Qt.rgba(c.r, c.g, c.b, alpha)
        return Qt.rgba(Theme.colorSidebarHighlight.r, Theme.colorSidebarHighlight.g,
                       Theme.colorSidebarHighlight.b, 0.5)
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
        implicitWidth: 128
        implicitHeight: Theme.componentHeightXL

        Rectangle { // background
            anchors.fill: parent
            color: control.colorBackground
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control

            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple
        }

        Rectangle { // action bar background
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: control.barHeight
            visible: control.barVisible
            color: control.colorBarBackground
        }
    }

    ////////////////

    contentItem: Item {
        RowLayout {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10

            height: Theme.componentHeight
            spacing: control.spacing

            SquareButtonClear {
                Layout.preferredWidth: Theme.componentHeight
                Layout.preferredHeight: Theme.componentHeight
                Layout.alignment: Qt.AlignVCenter

                visible: control.source.toString().length
                color: control.sourceColor
                source: control.source

                onClicked: control.clicked()
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                color: control.colorText
                opacity: control.enabled ? 1 : 0.66

                visible: control.text
                text: control.text
                textFormat: Text.PlainText

                font: control.font
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    MouseArea { // prevents clicks on the empty bar area from triggering the header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: control.barHeight
        visible: control.barVisible
        enabled: control.barEnabled
    }

    RowLayout {
        id: barRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: control.barHeight
        spacing: control.barSpacing
        enabled: control.barEnabled
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        maskEnabled: true
        maskInverted: false
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        maskSpreadAtMax: 0.0
        maskSource: ShaderEffectSource {
            sourceItem: Rectangle {
                x: control.background.x
                y: control.background.y
                width: control.background.width
                height: control.background.height
                radius: Theme.componentRadius
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
