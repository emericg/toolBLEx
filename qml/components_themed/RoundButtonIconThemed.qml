import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

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
        opacity: enabled ? 1 : 0.33
        color: control.down ? Theme.colorComponentDown : Theme.colorComponent
    }

    ////////////////

    contentItem: Item {
        IconSvg {
            anchors.centerIn: parent
            width: control.sourceSize
            height: control.sourceSize

            opacity: enabled ? 1.0 : 0.33
            source: control.source
            color: Theme.colorComponentContent
        }
    }

    ////////////////
}
