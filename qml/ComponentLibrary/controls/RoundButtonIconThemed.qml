import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    focusPolicy: Qt.NoFocus

    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)

    ////////////////

    background: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        radius: Theme.componentHeight
        opacity: control.enabled ? 1 : 0.66
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
        border.width: 2
        border.color: Theme.colorComponentBorder
    }

    ////////////////

    contentItem: Item {
        IconSvg {
            anchors.centerIn: parent
            width: control.sourceSize
            height: control.sourceSize

            opacity: control.enabled ? 1 : 0.66
            source: control.source
            color: Theme.colorComponentContent
        }
    }

    ////////////////
}
