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

    padding: Theme.componentMargin
    spacing: Theme.componentMargin
    verticalPadding: 0

    property bool clickable: false
    hoverEnabled: control.clickable

    // settings
    property int headerHeight: Theme.isMobile ? 56 : 64
    property int headerPosition: Theme.isMobile ? 56 : 64

    // icon
    property url source
    property color sourceColor: Theme.colorIcon
    property int sourceSize: 24

    // text
    property color textColor: Theme.colorText
    property int textSize: Theme.fontSizeContent

    // legend
    property string legend
    property color legendColor: Theme.colorSubText
    property int legendSize: Theme.fontSizeContentSmall

    // embedded setting
    default property alias settingControl: controlSlot.data

    // embedded setting control
    property real wrapRatio: 2/3
    readonly property bool wrapped: (control.width > 0 && controlSlot.implicitWidth > control.wrapRatio * control.width)

    ////////////////

    background: Rectangle {
        implicitHeight: Theme.componentHeightXL

        color: control.highlighted ? Theme.colorForeground : Theme.colorBackground

        RippleThemed {
            anchors.fill: parent
            anchor: control
            visible: control.clickable
        }
    }

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin

        opacity: control.enabled ? 1 : 0.4
        spacing: 0

        Item {
            Layout.preferredWidth: control.headerPosition
            Layout.preferredHeight: Theme.componentHeightXL
            Layout.alignment: Qt.AlignTop

            IconSvg {
                anchors.horizontalCenter: parent.left
                anchors.horizontalCenterOffset: (control.headerHeight / 2)
                anchors.verticalCenter: parent.verticalCenter

                width: control.sourceSize
                height: control.sourceSize
                color: control.sourceColor
                source: control.source
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            columns: control.wrapped ? 1 : 2
            columnSpacing: control.spacing
            rowSpacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                spacing: 0

                Text {
                    id: titleText
                    Layout.fillWidth: true
                    Layout.minimumHeight: Theme.componentHeightXL

                    text: control.text
                    textFormat: Text.PlainText
                    color: control.textColor
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: control.textSize
                }

                Text {
                    Layout.fillWidth: true

                    visible: (control.legend.length > 0)
                    bottomPadding: Theme.componentMarginXS

                    text: control.legend
                    textFormat: Text.PlainText
                    color: control.legendColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: control.legendSize
                }
            }

            Item {
                id: controlSlot
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: control.wrapped ? 0 : Math.max(0, (titleText.height - height) / 2)
                Layout.bottomMargin: control.wrapped ? Theme.componentMargin : 0

                z: 1
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }
    }

    ////////////////
}
