import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import ComponentLibrary

T.ItemDelegate {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: Theme.componentMarginS
    spacing: Theme.componentMarginS
    verticalPadding: Theme.componentMarginS

    hoverEnabled: Theme.isDesktop

    // icon
    property url source
    property color sourceColor: Theme.colorIcon
    property int sourceSize: 24

    // texts
    property string subtitle
    property color textColor: Theme.colorText
    property color subtitleColor: Theme.colorSubText

    // trailing indicator
    property url indicatorSource: "qrc:/ComponentLibraryAssets/icons/chevron_right.svg"
    property color indicatorColor: Theme.colorSubText
    property int indicatorSize: 24

    ////////////////

    background: Rectangle {
        implicitHeight: Theme.componentHeight
        radius: Theme.componentRadius

        color: (control.highlighted || control.hovered) ? Theme.colorForeground
                                                         : Theme.colorBackground
        Behavior on color { ColorAnimation { duration: 133 } }

        RippleThemed {
            anchors.fill: parent
            anchor: control

            clip: visible
            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus || control.hovered)
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.5)
        }
    }

    ////////////////

    contentItem: RowLayout {
        spacing: control.spacing
        opacity: control.enabled ? 1 : 0.4

        IconSvg {
            Layout.preferredWidth: control.sourceSize
            Layout.preferredHeight: control.sourceSize
            Layout.alignment: Qt.AlignVCenter

            visible: (control.source.toString().length > 0)

            color: control.sourceColor
            source: control.source
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true

                text: control.text
                textFormat: Text.PlainText
                color: control.textColor
                font.pixelSize: Theme.fontSizeContent
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true

                visible: (control.subtitle.length > 0)

                text: control.subtitle
                textFormat: Text.PlainText
                color: control.subtitleColor
                font.pixelSize: Theme.fontSizeContentSmall
                elide: Text.ElideRight
            }
        }

        IconSvg {
            Layout.preferredWidth: control.indicatorSize
            Layout.preferredHeight: control.indicatorSize
            Layout.alignment: Qt.AlignVCenter

            visible: (control.indicatorSource.toString().length > 0)

            color: control.indicatorColor
            source: control.indicatorSource
        }
    }

    ////////////////
}
