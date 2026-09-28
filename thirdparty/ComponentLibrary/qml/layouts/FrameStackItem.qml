import QtQuick
import QtQuick.Layouts

import ComponentLibrary

/*!
 * \brief A padded item for FrameStackColumn and FrameStackRow, with an optional title and text.
 *
 * Extra children are appended below the title and text.
 * In a FrameStackRow, items share the available width equally and fill the height.
 */
Column {
    id: control

    width: parent ? parent.width : implicitWidth

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.preferredWidth: 1

    padding: Theme.componentMargin
    spacing: 4

    property string title
    property string text

    property color colorTitle: Theme.colorText
    property color colorText: Theme.colorSubText

    ////////////////

    Text {
        width: control.width - control.leftPadding - control.rightPadding
        visible: (control.title.length > 0)

        text: control.title
        textFormat: Text.PlainText
        color: control.colorTitle
        font.pixelSize: Theme.fontSizeContentBig
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
    }

    Text {
        width: control.width - control.leftPadding - control.rightPadding
        visible: (control.text.length > 0)

        text: control.text
        textFormat: Text.PlainText
        color: control.colorText
        font.pixelSize: Theme.fontSizeContent
        lineHeight: 1.1
        wrapMode: Text.WordWrap
    }

    ////////////////
}
