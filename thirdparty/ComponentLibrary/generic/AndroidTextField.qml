import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.TextField {
    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    padding: 12
    leftPadding: padding + 4

    color: colorText
    font.pixelSize: Theme.componentFontSize
    verticalAlignment: Text.AlignVCenter

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText

    selectByMouse: false
    selectedTextColor: colorSelectedText
    selectionColor: colorSelection

    onEditingFinished: focus = false
    Keys.onBackPressed: focus = false

    // settings
    property string title: ""

    // colors
    property color colorText: Theme.colorComponentContent
    property color colorPlaceholderText: Theme.colorSubText
    property color colorBorder: Theme.colorSubText
    property color colorBackground: Theme.colorBackground
    property color colorSelection: Theme.colorPrimary
    property color colorSelectedText: "white"

    ////////////////

    PlaceholderText {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)

        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
        renderType: control.renderType
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 256
        implicitHeight: 46

        radius: 8
        color: control.colorBackground
        border.width: 1
        border.color: control.activeFocus ? control.colorSelection : control.colorBorder

        Text { // textTitle
            x: 16
            y: (-height / 2)

            text: control.title
            textFormat: Text.PlainText
            color: control.activeFocus ? control.colorSelection : control.colorBorder
            font: control.font

            Rectangle { // textTitleBackground
                anchors.fill: parent
                anchors.margins: -6
                z: -1
                visible: control.title
                color: control.colorBackground
            }
        }
    }

    ////////////////
}
