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

    padding: Theme.componentMarginL
    spacing: Theme.componentMarginL
    verticalPadding: 0

    // settings
    property int headerHeight: Theme.isMobile ? 56 : 64
    property int headerPosition: Theme.isMobile ? 56 : 64

    // permission
    property bool status: false
    property int statusSize: 32

    // text
    property color textColor: Theme.colorText
    property int textSize: Theme.fontSizeContentBig

    // legend
    property string legend
    property color legendColor: Theme.colorSubText
    property int legendSize: Theme.fontSizeContentSmall

    ////////////////

    background: Rectangle {
        color: control.highlighted ? Theme.colorForeground : Theme.colorBackground
    }

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginL

        opacity: control.enabled ? 1 : 0.4
        spacing: 0

        Item {
            Layout.preferredWidth: control.headerPosition
            Layout.preferredHeight: titleText.height
            Layout.alignment: Qt.AlignTop

            RoundButtonFlat {
                anchors.horizontalCenter: parent.left
                anchors.horizontalCenterOffset: (control.headerHeight / 2)
                anchors.verticalCenter: parent.verticalCenter

                width: control.statusSize
                height: control.statusSize

                source: control.status ? "qrc:/IconLibrary/material-symbols/check.svg"
                                       : "qrc:/IconLibrary/material-symbols/close.svg"
                color: control.status ? Theme.colorPrimary : Theme.colorSubText
                colorIcon: "white"

                onClicked: control.clicked()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            spacing: 0

            Text {
                id: titleText
                Layout.fillWidth: true
                Layout.minimumHeight: control.statusSize

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

                text: control.legend
                textFormat: Text.PlainText
                color: control.legendColor
                wrapMode: Text.WordWrap
                font.pixelSize: control.legendSize
            }
        }
    }

    ////////////////
}
