import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtQuick.Dialogs 1.3 // Qt5
import QtQuick.Dialogs // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsPath.js" as UtilsPath

T.TextField {
    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    clip: false
    color: colorText
    opacity: control.enabled ? 1 : 0.66

    text: ""
    font.pixelSize: Theme.componentFontSize
    verticalAlignment: TextInput.AlignVCenter

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText

    selectByMouse: false
    selectionColor: colorSelection
    selectedTextColor: colorSelectedText

    onEditingFinished: focus = false

    // settings
    property string buttonText: qsTr("change")
    property int buttonWidth: (buttonChange.visible ? buttonChange.width + 2 : 2)

    property string dialogTitle: qsTr("Please choose a file!")
    property var dialogFilter: ["All files (*)"]

    property string statusSource: ""
    property string statuscolor: Theme.colorPrimary

    // colors
    property string colorText: Theme.colorComponentText
    property string colorPlaceholderText: Theme.colorSubText
    property string colorBorder: Theme.colorComponentBorder
    property string colorBackground: Theme.colorComponentBackground
    property string colorSelection: Theme.colorPrimary
    property string colorSelectedText: "white"

    ////////////////

    Loader {
        id: pathDialogLoader

        active: false
        asynchronous: false
        sourceComponent: FileDialog {
            title: control.dialogTitle
            nameFilters: control.dialogFilter

            //currentFolder: UtilsPath.makeUrl(control.text)
            currentFile: UtilsPath.makeUrl(control.text)

            onAccepted: {
                //console.log("fileDialog URL: " + selectedFolder)

                //var f = UtilsPath.cleanUrl(selectedFolder)
                var f = UtilsPath.cleanUrl(selectedFile)
                if (f.slice(0, -1) !== "/") f += "/"

                control.text = f
            }
        }
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 256
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        color: control.colorBackground
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

    ButtonThemed {
        id: buttonChange
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0

        text: control.buttonText

        onClicked: {
            pathDialogLoader.active = true
            pathDialogLoader.item.open()
        }
    }

    Rectangle {
        anchors.fill: background
        radius: Theme.componentRadius
        color: "transparent"

        border.width: 2
        border.color: control.activeFocus ? control.colorSelection : control.colorBorder
    }

    ////////////////
}
