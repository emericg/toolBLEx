import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.TextField {
    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    padding: 12
    leftPadding: padding + 4

    opacity: 1
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
    property string colorText: Theme.colorComponentContent
    property string colorPlaceholderText: Theme.colorSubText
    property string colorBorder: Theme.colorSubText
    property string colorBackground: Theme.colorBackground
    property string colorSelection: Theme.colorPrimary
    property string colorSelectedText: "white"

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
        implicitHeight: 48

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
