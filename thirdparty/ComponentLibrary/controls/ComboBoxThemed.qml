import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    font.pixelSize: Theme.componentFontSize

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: control.enabled ? 1 : 0.66
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
        border.width: 2
        border.color: Theme.colorComponentBorder
    }

    ////////////////

    contentItem: Text {
        rightPadding: indicator.width
        verticalAlignment: Text.AlignVCenter

        text: control.displayText
        textFormat: Text.PlainText

        font: control.font
        elide: Text.ElideRight

        opacity: control.enabled ? 1 : 0.66
        color: Theme.colorComponentContent
    }

    ////////////////

    indicator: Canvas {
        x: control.width - width - control.rightPadding
        y: control.topPadding + ((control.availableHeight - height) / 2)
        width: 12
        height: 8
        opacity: control.enabled ? 1 : 0.66
        rotation: control.popup.visible ? 180 : 0

        Connections {
            target: Theme
            function onCurrentThemeChanged() { indicator.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = Theme.colorIcon
            ctx.fill()
        }
    }

    ////////////////

    delegate: T.ItemDelegate {
        required property var model
        required property int index

        width: control.width - 2
        height: control.height
        highlighted: (control.highlightedIndex === index)

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: Theme.componentHeight

            radius: Theme.componentRadius
            color: highlighted ? "#F6F6F6" : "white"
        }

        contentItem: Text {
            leftPadding: control.leftPadding
            rightPadding: control.rightPadding
            text: model[control.textRole]
            color: highlighted ? "black" : Theme.colorSubText
            font.pixelSize: Theme.componentFontSize
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////

    popup: T.Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight ? contentItem.implicitHeight + 2 : 0
        padding: 1

        topMargin: Math.max(screenPaddingStatusbar, screenPaddingTop)
        bottomMargin: Math.max(screenPaddingNavbar, screenPaddingBottom)

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }

        background: Rectangle {
            radius: Theme.componentRadius
            color: "white"
            border.color: Theme.colorComponentBorder
            border.width: control.visualFocus ? 0 : 1
        }
    }

    ////////////////
}
