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
    property string path: control.text
    property bool isValid: (control.text.length > 0)

    // settings
    property string dialogTitle: qsTr("Please choose a directory!")
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
        id: folderDialogLoader

        active: false
        asynchronous: false
        sourceComponent: FolderDialog {
            title: control.dialogTitle

            currentFolder: UtilsPath.makeUrl(control.text)
            //currentFolder: UtilsPath.makeUrl(control.currentFolder)

            onAccepted: {
                //console.log("folderDialog currentFolder: " + currentFolder)
                //console.log("folderDialog selectedFolder: " + selectedFolder)

                var f = UtilsPath.cleanUrl(selectedFolder)
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

    ButtonThemed {
        id: buttonChange
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        text: control.buttonText

        onClicked: {
            folderDialogLoader.active = true
            folderDialogLoader.item.open()
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
