import QtCore
import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.TextField {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    leftPadding: 8
    rightPadding: buttonWidth + 6

    clip: true
    color: colorText
    //opacity: control.enabled ? 1 : 0.66

    text: ""
    font.pixelSize: Theme.componentFontSize
    verticalAlignment: TextInput.AlignVCenter

    placeholderText: ""
    placeholderTextColor: colorPlaceholderText

    selectByMouse: true
    selectionColor: colorSelection
    selectedTextColor: colorSelectedText

    onEditingFinished: focus = false
    Keys.onBackPressed: focus = false

    // settings
    property alias folder: control.text
    property alias file: fileArea.text
    property alias extension: extensionArea.text
    property string path: folder + file + "." + extension
    property bool isValid: (control.text.length > 0 && fileArea.text.length > 0 && extensionArea.text.length > 0)

    // settings
    property string dialogTitle: qsTr("Please choose a file!")
    property var dialogFilter: ["All files (*)"]
    property int dialogFileMode: FileDialog.SaveFile // OpenFile / OpenFiles / SaveFile
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
        id: fileDialogLoader

        active: false
        asynchronous: false
        sourceComponent: FileDialog {
            title: control.dialogTitle
            nameFilters: control.dialogFilter

            fileMode: control.dialogFileMode
            currentFolder: UtilsPath.makeUrl(control.text)
            currentFile: UtilsPath.makeUrl(control.text)

            onAccepted: {
                //console.log("fileDialog currentFolder: " + currentFolder)
                //console.log("fileDialog currentFile: " + currentFile)
                //console.log("fileDialog selectedFile: " + selectedFile)

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

    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.leftMargin: control.leftPadding + control.contentWidth
        anchors.right: parent.right
        anchors.rightMargin: control.rightPadding
        anchors.verticalCenter: parent.verticalCenter

        clip: true

        TextInput { // fileArea
            id: fileArea
            anchors.verticalCenter: parent.verticalCenter

            width: contentWidth
            autoScroll: false
            color: Theme.colorSubText

            selectByMouse: true
            selectionColor: control.colorSelection
            selectedTextColor: control.colorSelectedText

            onTextChanged: control.textChanged()
            onEditingFinished: focus = false
        }
        Text { // dot
            id: extensionDot
            anchors.verticalCenter: parent.verticalCenter
            text: "."
            color: Theme.colorSubText
            verticalAlignment: Text.AlignVCenter
        }
        Text { // extension
            id: extensionArea
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.colorSubText
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////

    ButtonThemed {
        id: buttonChange
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        text: control.buttonText

        onClicked: {
            fileDialogLoader.active = true
            fileDialogLoader.item.open()
        }
    }

    Rectangle {
        anchors.fill: background
        radius: Theme.componentRadius
        color: "transparent"

        border.width: 2
        border.color: (control.activeFocus || fileArea.activeFocus) ? control.colorSelection : control.colorBorder
    }

    ////////////////
}
