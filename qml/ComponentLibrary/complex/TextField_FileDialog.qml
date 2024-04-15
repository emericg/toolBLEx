import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import QtQuick.Dialogs
import QtCore

import ThemeEngine
import "qrc:/utils/UtilsPath.js" as UtilsPath

T.TextField {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    clip: true
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
    Keys.onBackPressed: focus = false

    // settings
    property string dialogTitle: qsTr("Please choose a file!")
    property var dialogFilter: ["All files (*)"]
    property int dialogFileMode: FileDialog.SaveFile

    property var currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)

    // button
    property string buttonText: qsTr("change")
    property int buttonWidth: (buttonChange.visible ? buttonChange.width + 2 : 2)

    // colors
    property color colorText: Theme.colorComponentText
    property color colorPlaceholderText: Theme.colorSubText
    property color colorBorder: Theme.colorComponentBorder
    property color colorBackground: Theme.colorComponentBackground
    property color colorSelection: Theme.colorPrimary
    property color colorSelectedText: "white"

    ////////////////

    Loader {
        id: pathDialogLoader

        active: false
        asynchronous: false
        sourceComponent: FileDialog {
            title: control.dialogTitle
            nameFilters: control.dialogFilter

            fileMode: control.dialogFileMode
            currentFolder: UtilsPath.makeUrl(control.currentFolder)
            currentFile: UtilsPath.makeUrl(control.text)

            onAccepted: {
                //console.log("fileDialog currentFolder: " + currentFolder)
                //console.log("fileDialog currentFile: " + currentFile)
                //console.log("fileDialog selectedFile: " + selectedFile)

                var f = UtilsPath.cleanUrl(selectedFile)

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
