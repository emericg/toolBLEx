import QtQuick 2.15
import QtQuick.Controls 2.15

import ThemeEngine 1.0

Popup {
    id: popupWriteCharacteristic

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height / 2))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    signal confirmed()

    onAboutToShow: {
        //
    }
    onAboutToHide: {
        //
    }

    function openU(uuid) {
        uuid_tf.text = uuid
        open()
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: 24

        ////////

        Rectangle { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            height: 64
            color: Theme.colorPrimary
            radius: Theme.componentRadius

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Write to characteristic")
                font.pixelSize: Theme.fontSizeTitle
                font.bold: true
                color: "white"
            }
        }

        ////////

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 8

            Text {
                width: parent.width

                text: qsTr("Target UUID")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            TextFieldThemed { // UUID
                id: uuid_tf
                width: parent.width

                readOnly: true
                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
            }
        }

        ////////

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 8

            Text {
                text: qsTr("Format")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Row {
                id: rowType
                width: parent.width
                spacing: 10

                property string mode: "bytes"

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("bytes")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("text")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("integer")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("float")
                }
            }

            Row {
                id: rowSubType_bytes
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("bytes")
                property string mode: "bytes"

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_bytes.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_bytes.mode = text

                    text: qsTr("bytes")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_bytes.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_bytes.mode = text

                    text: qsTr("byte")
                }
            }

            Row {
                id: rowSubType_text
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("text")
                property string mode: "ascii"

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_text.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_text.mode = text

                    text: qsTr("ascii")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_text.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_text.mode = text

                    text: qsTr("UTF-8")
                }
            }

            Row {
                id: rowSubType_int
                width: parent.width
                spacing: 8

                visible: rowType.mode === qsTr("integer")
                property string mode: "32 bits"
                property string mode_signed: "signed"
                property string mode_endian: "le"

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_signed === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_signed = text

                    text: qsTr("signed")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_signed === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_signed = text

                    text: qsTr("unsigned")
                }

                ////

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode = text

                    text: qsTr("8 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode = text

                    text: qsTr("16 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode = text

                    text: qsTr("32 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode = text

                    text: qsTr("64 bits")
                }

                ////

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_endian === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_endian = text

                    text: qsTr("le")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_endian === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_endian = text

                    text: qsTr("be")
                }
            }

            Row {
                id: rowSubType_float
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("float")
                property string mode: "32 bits"

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_float.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_float.mode = text

                    text: qsTr("16 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_float.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_float.mode = text

                    text: qsTr("32 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_float.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_float.mode = text

                    text: qsTr("64 bits")
                }

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: Theme.colorGrey

                    text: qsTr("IEEE 754")
                }
            }
        }

        ////////

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 8

            Text {
                width: parent.width

                text: qsTr("Value")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            TextFieldThemed { // value
                width: parent.width

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText

                placeholderText: ""
            }
        }

        ////////

        Item  { width: 1; height: 1; } // spacer

        Row {
            id: flowContent
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 16

            ButtonWireframe {
                text: qsTr("Cancel")
                primaryColor: Theme.colorSubText
                secondaryColor: Theme.colorForeground

                onClicked: {
                    popupWriteCharacteristic.close()
                }
            }
            ButtonWireframe {
                width: parent.btnSize

                text: qsTr("Write value")
                primaryColor: Theme.colorPrimary
                fullColor: true

                onClicked: {
                    popupWriteCharacteristic.confirmed()
                    popupWriteCharacteristic.close()
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }
}
