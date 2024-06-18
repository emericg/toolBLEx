import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: 24

    // colors
    property color colorContent: Theme.colorTabletmenuContent
    property color colorHighlight: Theme.colorTabletmenuHighlight

    ////////////////

    background: Item {
        implicitWidth: 72
        implicitHeight: Theme.componentHeight
    }

    ////////////////

    contentItem: ColumnLayout {
        spacing: 0

        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignHCenter

            IconSvg { // contentImage
                anchors.centerIn: parent
                width: control.sourceSize
                height: control.sourceSize

                visible: control.source.toString().length
                source: control.source

                opacity: control.enabled ? 1 : 0.66
                color: control.highlighted ? control.colorHighlight : control.colorContent
                Behavior on color { ColorAnimation { duration: 133 } }

                Rectangle { // backgroundIndicator
                    anchors.centerIn: parent
                    z: -1

                    height: 32
                    radius: height
                    color: control.colorHighlight

                    width: control.highlighted ? 60 : 0
                    Behavior on width { NumberAnimation { duration: 133 } }

                    opacity: control.highlighted ? 0.2 : 0
                    Behavior on opacity { OpacityAnimator { duration: 133 } }
                }
            }
        }

        Text { // contentText
            Layout.preferredWidth: control.width
            Layout.alignment: Qt.AlignHCenter

            visible: control.text

            text: control.text
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeContentSmall - 1
            font.bold: true

            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 233 } }
        }
    }

    ////////////////
}
