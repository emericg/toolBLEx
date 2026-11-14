import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import ComponentLibrary

ComboBoxThemed {
    id: control

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    radius: height

    // colors
    colorBackground: Theme.colorComponentBackground
    colorBackgroundBorder: Theme.colorComponentBorder
    property color colorContent: Theme.colorComponentText
    property color colorContentHighlight: "white"
    property color colorBackgroundHighlight: Theme.colorPrimary

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 32

        radius: control.radius
        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground
        border.width: 2
        border.color: control.colorBackgroundBorder
    }

    ////////////////

    contentItem: Item {
        implicitWidth: currentRow.implicitWidth + 32 + control.indicator.width + 8
        implicitHeight: 32

        Rectangle {
            id: currentPill
            anchors.fill: parent

            radius: height
            color: control.colorBackgroundHighlight
            opacity: control.enabled ? (control.pressed ? 0.8 : 1) : 0.66

            RowLayout {
                id: currentRow
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16 + control.indicator.width + 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                IconSvg {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    visible: control.hasCurrentIcon

                    source: control.currentIconSource
                    color: control.colorContentHighlight
                }

                Text {
                    Layout.fillWidth: true

                    text: control.displayText
                    textFormat: Text.PlainText
                    font: control.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    color: control.colorContentHighlight
                }
            }
        }
    }

    ////////////////

    indicator: Canvas {
        x: control.width - width - 16
        y: (control.height - height) / 2
        z: 1
        width: 12
        height: 8
        opacity: control.enabled ? 1 : 0.66
        rotation: control.popup.visible ? 180 : 0

        readonly property color colorIndicator: control.colorContentHighlight
        onColorIndicatorChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = String(colorIndicator)
            ctx.fill()
        }
    }

    ////////////////

    delegate: T.ItemDelegate {
        id: itemDelegate

        required property var model
        required property int index

        readonly property var iconSource: (control.iconRole && model && model[control.iconRole]) ? model[control.iconRole] : ""
        readonly property bool hasIcon: iconSource ? iconSource.toString().length > 0 : false
        readonly property bool selected: (control.currentIndex === index)

        width: ListView.view ? ListView.view.width : control.width
        height: control.height
        highlighted: (control.highlightedIndex === index)
        hoverEnabled: true

        background: Rectangle {
            radius: height
            color: control.colorBackgroundHighlight
            opacity: {
                if (itemDelegate.selected) return 1
                if (itemDelegate.highlighted || itemDelegate.hovered) return 0.2
                return 0
            }
            Behavior on opacity { OpacityAnimator { duration: Theme.animationSpeedFast } }
        }

        contentItem: RowLayout {
            spacing: 4

            IconSvg {
                Layout.leftMargin: 16
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                visible: itemDelegate.hasIcon

                source: itemDelegate.iconSource
                color: itemDelegate.selected ? control.colorContentHighlight : control.colorContent
                opacity: itemDelegate.selected ? 1 : 0.66
            }

            Text {
                Layout.leftMargin: itemDelegate.hasIcon ? 0 : 16
                Layout.rightMargin: 16
                Layout.fillWidth: true

                text: control.textAt(itemDelegate.index)
                textFormat: Text.PlainText
                font: control.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter

                color: itemDelegate.selected ? control.colorContentHighlight : control.colorContent
                opacity: itemDelegate.selected ? 1 : 0.66
            }
        }
    }

    ////////////////

    popup: T.Popup {
        y: control.height + 4
        width: control.width
        height: contentItem.implicitHeight ? contentItem.implicitHeight + 8 : 0
        padding: 4

        topMargin: Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop)
        bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            spacing: 2
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }

        background: Rectangle {
            radius: (control.height + 8) / 2
            color: control.colorBackground
            border.width: 2
            border.color: control.colorBackgroundBorder
        }
    }

    ////////////////
}
