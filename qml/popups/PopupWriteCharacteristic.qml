import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ThemeEngine

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

    property var characteristic: null

    function openCC(cc) {
        characteristic = cc
        uuid_tf.text = characteristic.uuid_full
        open()
    }

    onAboutToShow: { }
    onAboutToHide: { } // TODO // cleanup

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.33; to: 1.0; duration: 233; } }

    background: Item {
        Rectangle {
            id: bgrect
            anchors.fill: parent

            radius: Theme.componentRadius
            color: Theme.colorBackground
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth
        }
        DropShadow {
            anchors.fill: parent
            source: bgrect
            color: "#60000000"
            samples: 24
            cached: true
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: 24

        ////////

        Rectangle { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            height: 80
            color: Theme.colorPrimary
            radius: Theme.componentRadius

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: qsTr("Write to characteristic")
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    color: "white"
                    opacity: 0.98
                }
                Text {
                    id: uuid_tf
                    text: "00000000-0000-1000-8000-00805F9B34FB"
                    font.pixelSize: Theme.fontSizeTitle-4
                    color: "white"
                    opacity: 0.9
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Repeater { // characteristic properties
                    anchors.verticalCenter: parent.verticalCenter
                    model: characteristic && characteristic.propertiesList
                    ItemTag {
                        text: modelData
                        textColor: Theme.colorLightGrey
                        opacity: 0.8
                    }
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

                property string mode: qsTr("data")

                onModeChanged: columnTf.updateTextFields()

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("data")
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
                id: rowSubType_data
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("bytes")
                property string mode: qsTr("bytes")

                onModeChanged: columnTf.updateTextFields()

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_data.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_data.mode = text

                    text: qsTr("bytes")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_data.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_data.mode = text

                    text: qsTr("byte")
                }
            }

            Row {
                id: rowSubType_text
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("text")
                property string mode: qsTr("ascii")

                onModeChanged: columnTf.updateTextFields()

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
                property string mode_signed: qsTr("signed")
                property string mode_endian: qsTr("le")

                onMode_signedChanged: columnTf.updateTextFields()
                onMode_endianChanged: columnTf.updateTextFields()

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

                Item { width: 1; height: 1; } // spacer

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
                id: rowSizeType_int
                width: parent.width
                spacing: 8

                visible: rowType.mode === qsTr("integer")
                property string mode: "32 bits"

                onModeChanged: columnTf.updateTextFields()

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: "8 bits"
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: "16 bits"
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: "32 bits"
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: "64 bits"
                }
            }

            Row {
                id: rowSubType_float
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("float")
                property string mode: "IEEE 754"

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_float.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSubType_float.mode = text

                    text: "IEEE 754"
                }
            }

            Row {
                id: rowSizeType_float
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("float")
                property string mode: "32 bits"

                onModeChanged: columnTf.updateTextFields()

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_float.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSizeType_float.mode = text

                    text: "32 bits"
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_float.mode === text) ? Theme.colorGrey : Theme.colorLightGrey
                    onClicked: rowSizeType_float.mode = text

                    text: "64 bits"
                }
            }
        }

        ////////

        Column {
            id: columnTf
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

            ////

            function updateTextFields() {
                var value = ""
                var type = ""

                if (rowType.mode === qsTr("data")) {

                    type = "data"
                    value = textfieldValue_data.text

                } else if (rowType.mode === qsTr("text")) {

                    type = "ascii"
                    value = textfieldValue_text.text

                } else if (rowType.mode === qsTr("integer")) {

                    if (rowSubType_int.mode_signed === qsTr("signed")) type = "int"
                    if (rowSubType_int.mode_signed === qsTr("unsigned")) type = "uint"
                    if (rowSizeType_int.mode === "8 bits") type += "8"
                    if (rowSizeType_int.mode === "16 bits") type += "16"
                    if (rowSizeType_int.mode === "32 bits") type += "32"
                    if (rowSizeType_int.mode === "64 bits") type += "64"
                    if (rowSubType_int.mode_endian === qsTr("le")) type += "_le"
                    if (rowSubType_int.mode_endian === qsTr("be")) type += "_be"
                    value = textfieldValue_int.text

                } else if (rowType.mode === qsTr("float")) {

                    if (rowSizeType_float.mode === "32 bits") type = "float32"
                    if (rowSizeType_float.mode === "64 bits") type = "float64"
                    value = textfieldValue_float.text

                }

                data_hex.model = selectedDevice.askForData_strlst(value, type)
            }

            ////

            TextFieldThemed {
                id: textfieldValue_text
                width: parent.width

                visible: rowType.mode === qsTr("text")
                placeholderText: "ascii text"

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                maximumLength: 20
                //validator: RegularExpressionValidator { regularExpression: /[a-zA-Z0-9]+/ } // poor man ascii
                validator: RegularExpressionValidator { regularExpression: /([\x00-\x7F])+/ } // ascii

                onTextChanged: columnTf.updateTextFields()
            }
            TextFieldThemed {
                id: textfieldValue_data
                width: parent.width

                visible: rowType.mode === qsTr("data")
                placeholderText: "hexadecimal data"

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                maximumLength: 40
                validator: RegularExpressionValidator { regularExpression: /[a-fA-F0-9]+/ }
                //inputMask: "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"

                onTextChanged: columnTf.updateTextFields()
            }
            TextFieldThemed {
                id: textfieldValue_int
                width: parent.width

                visible: rowType.mode === qsTr("integer")
                placeholderText: "integer"

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                property var v_int1 : IntValidator { bottom: parseInt(-2147483647); top: parseInt(2147483647); }
                property var v_int : RegularExpressionValidator { regularExpression: /[0-9--]+/ }
                property var v_uint : RegularExpressionValidator { regularExpression: /[0-9]+/ }

                validator: RegularExpressionValidator { regularExpression: /[0-9--]+/ }

                onTextChanged: columnTf.updateTextFields()
            }
            TextFieldThemed {
                id: textfieldValue_float
                width: parent.width

                visible: rowType.mode === qsTr("float")
                placeholderText: "floating point"

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                validator: DoubleValidator { }

                onTextChanged: columnTf.updateTextFields()
            }
        }

        ////////////////////////////////////////////////////////////////////////

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 8

            Text {
                width: parent.width

                text: qsTr("Data to be written (hexadecimal)")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVeryBig
                color: Theme.colorText
                wrapMode: Text.WordWrap
            }

            Rectangle {
                id: rectNoData
                width: 26
                height: 26

                visible: !data_hex.model.length
                color: Theme.colorForeground

                Canvas {
                    width: 26
                    height: 26
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.moveTo(0, width)
                        ctx.lineTo(width, width)
                        ctx.lineTo(width, 0)
                        ctx.closePath()
                        ctx.fillStyle = Theme.colorBox
                        ctx.fill()
                    }
                    Connections {
                        target: ThemeEngine
                        function onCurrentThemeChanged() { indicator.requestPaint() }
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 0

                Repeater {
                    id: data_hex
                    model: null

                    Rectangle {
                        width: 26
                        height: 26
                        color: (index % 2 === 0) ? Theme.colorForeground : Theme.colorBox

                        Text {
                            height: 26
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: modelData
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent-1
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.colorText
                            font.family: fontMonospace
                        }
                    }
                }
            }
        }

        ////////

        Item  { width: 1; height: 1; } // spacer

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 16

            ButtonWireframe {
                primaryColor: Theme.colorSubText
                secondaryColor: Theme.colorForeground

                text: qsTr("Cancel")
                onClicked: popupWriteCharacteristic.close()
            }
            ButtonWireframe {
                fullColor: true
                primaryColor: Theme.colorPrimary

                enabled: data_hex.model.length

                text: qsTr("Write value")
                onClicked: {
                    var value = ""
                    var type = ""

                    if (rowType.mode === qsTr("data")) {

                        type = "data"
                        value = textfieldValue_data.text

                    } else if (rowType.mode === qsTr("text")) {

                        type = "ascii"
                        value = textfieldValue_text.text

                    } else if (rowType.mode === qsTr("integer")) {

                        if (rowSubType_int.mode_signed === qsTr("signed")) type = "int"
                        if (rowSubType_int.mode_signed === qsTr("unsigned")) type = "uint"
                        if (rowSizeType_int.mode === "8 bits") type += "8"
                        if (rowSizeType_int.mode === "16 bits") type += "16"
                        if (rowSizeType_int.mode === "32 bits") type += "32"
                        if (rowSizeType_int.mode === "34 bits") type += "34"
                        if (rowSubType_int.mode_endian === qsTr("le")) type += "_le"
                        if (rowSubType_int.mode_endian === qsTr("be")) type += "_be"
                        value = textfieldValue_int.text

                    } else if (rowType.mode === qsTr("float")) {

                        if (rowSizeType_float.mode === "32 bits") type = "float32"
                        if (rowSizeType_float.mode === "64 bits") type = "float64"
                        value = textfieldValue_float.text

                    }

                    selectedDevice.askForWrite(characteristic.uuid_full, value, type)
                    popupWriteCharacteristic.confirmed()
                    popupWriteCharacteristic.close()
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }
}
