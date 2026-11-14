import QtQuick

import ComponentLibrary
import AppUtils


Column {
    id: control

    // settings
    property int headerHeight: Theme.isMobile ? 56 : 64
    property int headerPosition: Theme.isMobile ? 56 : 64

    // application
    property string applicationID

    ////////////////

    Item { // info
        anchors.left: parent.left
        anchors.right: parent.right

        height: Math.max(32, infoText.height)

        IconSvg {
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: (control.headerHeight / 2)
            anchors.verticalCenter: parent.verticalCenter

            width: 32
            height: 32
            source: "qrc:/IconLibrary/material-icons/duotone/info.svg"
            color: Theme.colorSubText
        }

        Text {
            id: infoText
            anchors.left: parent.left
            anchors.leftMargin: control.headerPosition
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Click on the checkmarks to request missing permissions.")
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: Theme.colorText
            font.pixelSize: Theme.fontSizeContentSmall
        }
    }

    ListSpacer { space: Theme.componentMargin }

    Text { // legend
        anchors.left: parent.left
        anchors.leftMargin: control.headerPosition
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginL

        text: qsTr("If it has no effect, you may have previously refused a permission and clicked on \"don't ask again\".") + "<br>" +
              qsTr("You can go to the Android \"application info\" panel to change a permission manually.")
        textFormat: Text.StyledText
        wrapMode: Text.WordWrap
        color: Theme.colorSubText
        font.pixelSize: Theme.fontSizeContentSmall
    }

    ListSpacer { space: Theme.componentMarginL }

    ButtonWireframe { // button
        anchors.left: parent.left
        anchors.leftMargin: control.headerPosition
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginL

        visible: (control.applicationID.length > 0)

        layoutAlignment: Qt.AlignLeft
        colorBackground: Theme.colorForeground

        text: qsTr("Application info")
        source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"
        onClicked: UtilsOS.openAppInfo(control.applicationID)
    }

    ////////////////
}
