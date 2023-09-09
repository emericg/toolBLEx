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

    leftPadding: 12
    rightPadding: 12

    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: 26

    // colors
    property string colorContent: Theme.colorTabletmenuContent
    property string colorHighlight: Theme.colorTabletmenuHighlight

    ////////////////

    background: Item {}

    ////////////////

    contentItem: ColumnLayout {
        spacing: 0

        IconSvg { // contentImage
            width: control.sourceSize
            height: control.sourceSize
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize
            Layout.alignment: Qt.AlignHCenter

            visible: source.toString().length

            source: control.source
            opacity: control.enabled ? 1.0 : 0.33
            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 133 } }
        }

        Text { // contentText
            width: control.width
            Layout.alignment: Qt.AlignHCenter

            visible: text

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.bold: false
            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 133 } }
        }
    }

    ////////
}
