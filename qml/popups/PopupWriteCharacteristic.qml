import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import ThemeEngine

Popup {
    id: popupWriteCharacteristic

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }

    signal confirmed()

    property var characteristic: null

    ////////////////////////////////////////////////////////////////////////////

    onAboutToShow: { }
    onAboutToHide: { }

    function openCC(cc) {
        characteristic = cc
        uuid_tf.text = characteristic.uuid_full
        open()
    }

    ////////////////////////////////////////////////////////////////////////////

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: ThemeEngine.isLight ? 0.333 : 0.666
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: ThemeEngine.isLight ? "#aa000000" : "#aaffffff"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: Theme.componentMarginXL

        ////////

        Rectangle { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            height: 96
            color: Theme.colorPrimary
            radius: Theme.componentRadius

            border.color: Qt.darker(color, 1.05)
            border.width: Theme.componentBorderWidth

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginXL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginXL
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Write to characteristic")
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    id: uuid_tf
                    text: "00000000-0000-1000-8000-00805F9B34FB"
                    font.pixelSize: Theme.fontSizeContentBig
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.88
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Repeater { // characteristic properties
                    anchors.verticalCenter: parent.verticalCenter
                    model: characteristic && characteristic.propertiesList

                    ItemTag {
                        text: modelData
                        textColor: "white"
                        color: Qt.darker(Theme.colorPrimary, 1.1)
                        opacity: 0.84
                    }
                }
            }
        }

        ////////

        Column { // contentArea
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
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
                    primaryColor: (rowType.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("data")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("text")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowType.mode = text

                    text: qsTr("integer")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowType.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
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
                    primaryColor: (rowSubType_data.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_data.mode = text

                    text: qsTr("bytes")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_data.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
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
                    primaryColor: (rowSubType_text.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_text.mode = text

                    text: qsTr("ascii")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_text.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_text.mode = text

                    text: qsTr("UTF-8")
                    visible: false
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
                    primaryColor: (rowSubType_int.mode_signed === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_signed = text

                    text: qsTr("signed")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_signed === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_signed = text

                    text: qsTr("unsigned")
                }

                Item { width: 1; height: 1; } // spacer

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_endian === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_endian = text

                    text: qsTr("le")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_int.mode_endian === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_int.mode_endian = text

                    text: qsTr("be")
                }
            }

            Row {
                id: rowSizeType_int
                width: parent.width
                spacing: 8

                visible: rowType.mode === qsTr("integer")
                property string mode: qsTr("32 bits")

                onModeChanged: columnTf.updateTextFields()

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: qsTr("8 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: qsTr("16 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: qsTr("32 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_int.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSizeType_int.mode = text

                    text: qsTr("64 bits")
                }
            }

            Row {
                id: rowSubType_float
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("float")
                property string mode: qsTr("IEEE 754")

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSubType_float.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSubType_float.mode = text

                    text: qsTr("IEEE 754")
                }
            }

            Row {
                id: rowSizeType_float
                width: parent.width
                spacing: 10

                visible: rowType.mode === qsTr("float")
                property string mode: qsTr("32 bits")

                onModeChanged: columnTf.updateTextFields()

                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_float.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSizeType_float.mode = text

                    text: qsTr("32 bits")
                }
                ButtonWireframe {
                    height: 28
                    fullColor: true
                    primaryColor: (rowSizeType_float.mode === text) ? Theme.colorPrimary : Theme.colorLightGrey
                    onClicked: rowSizeType_float.mode = text

                    text: qsTr("64 bits")
                }
            }
        }

        ////////

        Column {
            id: columnTf
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
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
                placeholderText: qsTr("ascii text")

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
                placeholderText: qsTr("hexadecimal data")

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
                placeholderText: qsTr("integer")

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
                placeholderText: qsTr("floating point")

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
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
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
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMargin

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
