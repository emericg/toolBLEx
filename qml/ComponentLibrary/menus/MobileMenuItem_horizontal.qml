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

    leftPadding: 12
    rightPadding: 12

    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: 24

    // colors
    property color colorContent: Theme.colorTabletmenuContent
    property color colorHighlight: Theme.colorTabletmenuHighlight

    ////////////////

    background: Item {}

    ////////////////

    contentItem: RowLayout {
        spacing: isPhone ? 6 : 12

        IconSvg { // contentImage
            width: control.sourceSize
            height: control.sourceSize
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            visible: source.toString().length

            source: control.source
            opacity: control.enabled ? 1 : 0.66
            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 133 } }
        }

        Text { // contentText
            height: control.height
            Layout.alignment: Qt.AlignVCenter

            visible: text

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: Theme.componentFontSize
            font.bold: true
            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 133 } }
        }
    }

    ////////////////
}
