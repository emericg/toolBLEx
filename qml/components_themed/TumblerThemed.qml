import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Tumbler {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight * 2

    model: 24

    ////////////////

    background: Item {
        //
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
        dragMargin: width / 2

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

    delegate: Text {
        text: modelData
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: (control.currentIndex === modelData) ? Theme.colorPrimary : Theme.colorText
        opacity: (control.enabled ? 1.0 : 0.8) - (Math.abs(T.Tumbler.displacement) / (control.visibleItemCount * 0.55))
        font.pixelSize: (control.currentIndex === modelData) ? Theme.componentFontSize+2 : Theme.componentFontSize
        font.bold: false

        required property var modelData
        required property int index
    }

    ////////////////
}
