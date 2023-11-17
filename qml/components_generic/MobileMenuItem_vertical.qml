import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 0
    rightPadding: 0

    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: 26

    // colors
    property string colorContent: Theme.colorTabletmenuContent
    property string colorHighlight: Theme.colorTabletmenuHighlight

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight
    }

    ////////////////

    contentItem: ColumnLayout {
        spacing: -2

        IconSvg { // contentImage
            Layout.preferredWidth: control.sourceSize
            Layout.preferredHeight: control.sourceSize
            Layout.alignment: Qt.AlignHCenter

            visible: source.toString().length

            source: control.source
            opacity: control.enabled ? 1.0 : 0.33
            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 233 } }

            Rectangle { // backgroundIndicator
                anchors.centerIn: parent
                z: -1

                width: 60
                height: 32
                radius: height
                color: control.colorHighlight

                opacity: control.highlighted ? 0.2 : 0
                Behavior on opacity { OpacityAnimator { duration: 233 } }
            }
        }

        Text { // contentText
            Layout.preferredWidth: control.width
            Layout.alignment: Qt.AlignHCenter

            visible: text

            text: control.text
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.bold: true

            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 233 } }
        }
    }

    ////////////////
}
