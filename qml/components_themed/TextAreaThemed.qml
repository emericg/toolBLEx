import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.TextArea {
    id: control

    implicitWidth: Math.max(contentWidth + leftPadding + rightPadding,
                            implicitBackgroundWidth + leftInset + rightInset,
                            placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             implicitBackgroundHeight + topInset + bottomInset,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    padding: 12

    color: colorText
    opacity: control.enabled ? 1 : 0.66

    text: ""
    font.pixelSize: Theme.componentFontSize
    verticalAlignment: Text.AlignTop

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText

    selectByMouse: false
    selectionColor: colorSelection
    selectedTextColor: colorSelectedText

    onEditingFinished: focus = false
    Keys.onBackPressed: focus = false

    // colors
    property string colorText: Theme.colorComponentContent
    property string colorPlaceholderText: Theme.colorSubText
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorComponentBackground
    property string colorSelection: Theme.colorPrimary
    property string colorSelectedText: "white"

    ////////////////

    background: Rectangle {
        implicitWidth: 256
        implicitHeight: Theme.componentHeight*2

        radius: Theme.componentRadius
        color: control.colorBackground

        border.width: 2
        border.color: control.activeFocus ? control.colorSelection : control.colorBorder
    }

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
}
