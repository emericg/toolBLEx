import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: 16
    rightPadding: 16

    font.pixelSize: Theme.fontSizeComponent
    opacity: enabled ? 1.0 : 0.4

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
        border.width: 2
        border.color: Theme.colorComponentBorder
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.displayText
        textFormat: Text.PlainText

        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter

        color: Theme.colorComponentContent
    }

    ////////////////////////////////////////////////////////////////////////////

    indicator: Canvas {
        x: control.width - width - control.rightPadding
        y: control.topPadding + ((control.availableHeight - height) / 2)
        width: 12
        height: 8
        rotation: control.popup.visible ? 180 : 0

        Connections {
            target: ThemeEngine
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

    ////////////////////////////////////////////////////////////////////////////

    delegate: T.ItemDelegate {
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
            text: control.textRole
                ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole])
                : modelData
            color: highlighted ? "black" : Theme.colorSubText
            font.pixelSize: Theme.fontSizeComponent
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    popup: T.Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: (contentItem.implicitHeight) ? contentItem.implicitHeight + 2 : 0
        padding: 1

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

    ////////////////////////////////////////////////////////////////////////////
}
