import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Tumbler {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    opacity: control.enabled ? 1 : 0.66

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight * 2
    }

    ////////////////

    contentItem: PathView {
        id: pathView

        model: control.model
        delegate: control.delegate

        clip: true
        pathItemCount: control.visibleItemCount + 1
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        dragMargin: (width / 2)

        path: Path {
            startX: (pathView.width / 2)
            startY: -(pathView.delegateHeight / 2)

            PathLine {
                x: (pathView.width / 2)
                y: (pathView.pathItemCount * pathView.delegateHeight) - (pathView.delegateHeight / 2)
            }
        }

        property real delegateHeight: (control.availableHeight / control.visibleItemCount)
    }

    ////////////////

    delegate: Text {
        required property var modelData
        required property int index

        text: modelData
        textFormat: Text.PlainText
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: (control.currentIndex === index) ? Theme.colorPrimary : Theme.colorText
        Behavior on color { ColorAnimation { duration: 133 } }

        opacity: 1.0 - Math.abs(T.Tumbler.displacement) / (control.visibleItemCount / 2)

        //scale: 1.0 + Math.max(0, 1 - Math.abs(T.Tumbler.displacement)) * 0.33
        //scale: (control.currentIndex === index) ? 1.33 : 1.0
    }

    ////////////////
}
