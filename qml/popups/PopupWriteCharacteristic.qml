import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ComponentLibrary
import BleFormat

Popup {
    id: popupWriteCharacteristic

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))

    width: 800
    padding: 0
    margins: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    ////////////////////////////////////////////////////////////////////////////

    property var characteristic: null

    enum WriteMode { WithResponse, WithoutResponse }

    readonly property bool hasWriteWithResponse: (characteristic && characteristic.propertiesList.indexOf("Write") >= 0)
    readonly property bool hasWriteWithoutResponse: (characteristic && characteristic.propertiesList.indexOf("WriteNoResp") >= 0)

    // Only "with response" writes can be split into multiple packets by the stack
    readonly property bool writeWithResponse: (selectorWriteMode.currentSelection === PopupWriteCharacteristic.WriteMode.WithResponse)

    readonly property int maxValueSize: 512 // A GATT attribute value cannot exceed 512 bytes
    readonly property int maxPacketSize: (selectedDevice && selectedDevice.mtu > 0) ? (selectedDevice.mtu - 3) : -1
    readonly property int expectedSize: (characteristic && characteristic.formatSize > 0) ? characteristic.formatSize : -1
    readonly property int valueSize: encoded.hex.length

    // Hexadecimal data with an odd number of digits, the last byte is incomplete
    // (the complete bytes are still previewed, the incomplete one is highlighted)
    readonly property bool valueIncompleteByte: (formatSelectors.type === WriteFormatSelectors.Type.Data &&
                                                 textfieldValue_data.text.length % 2 !== 0)

    // The descriptor exponent is only applied on demand, the raw integer is written by default
    property bool scaleValue: false
    readonly property bool canScaleValue: (formatSelectors.writeDescriptorInteger && characteristic.formatExponent !== 0)
    readonly property int writeExponent: (canScaleValue && scaleValue) ? characteristic.formatExponent : 0

    // The value, encoded exactly as it will be written (see DeviceToolBLEx::encodeWriteValue())
    readonly property var encoded: {
        let value = getWriteValue()

        // encode the complete bytes only, the incomplete one is shown on its own
        if (valueIncompleteByte) value = value.slice(0, -1)

        if (!selectedDevice) return { bytes: null, hex: [], error: BleFormat.WRITE_OK, errorString: "" }
        return selectedDevice.encodeWriteValue(value, formatSelectors.writeFormat, formatSelectors.bigEndian, writeExponent)
    }

    // Can the value be written? Only the most severe problem is reported
    readonly property var writeStatus: {
        if (valueIncompleteByte)
            return makeStatus(WriteValuePreview.Status.Error, qsTr("Incomplete byte, hexadecimal digits go in pairs."))
        if (encoded.error !== BleFormat.WRITE_OK)
            return makeStatus(WriteValuePreview.Status.Error, qsTr("This value cannot be written: %1.").arg(encoded.errorString))
        if (valueSize === 0)
            return makeStatus(WriteValuePreview.Status.Empty, "")

        // Text fields are capped in characters, but utf8 can use up to 4 bytes per character
        if (valueSize > maxValueSize)
            return makeStatus(WriteValuePreview.Status.Error, qsTr("A GATT value cannot exceed %1 bytes.").arg(maxValueSize))

        if (!writeWithResponse && maxPacketSize > 0 && valueSize > maxPacketSize) {
            return makeStatus(WriteValuePreview.Status.Error, hasWriteWithResponse ?
                qsTr("A 'without response' write cannot be split into multiple packets, use 'with response' or a shorter value.") :
                qsTr("A 'without response' write cannot be split into multiple packets, use a shorter value."))
        }

        if (expectedSize > 0 && valueSize !== expectedSize)
            return makeStatus(WriteValuePreview.Status.Warning, qsTr("The descriptors expect %n byte(s), the device may reject this value.", "", expectedSize))

        return makeStatus(WriteValuePreview.Status.Ok, "")
    }

    function makeStatus(level, message) {
        return { level: level, message: message,
                 canWrite: (level === WriteValuePreview.Status.Ok || level === WriteValuePreview.Status.Warning) }
    }

    // The value to write, as typed by the user
    function getWriteValue() {
        switch (formatSelectors.type) {
        case WriteFormatSelectors.Type.Data: return textfieldValue_data.text
        case WriteFormatSelectors.Type.Text: return textfieldValue_text.text
        case WriteFormatSelectors.Type.Integer: return textfieldValue_int.text
        case WriteFormatSelectors.Type.Float: return textfieldValue_float.text
        }
        return ""
    }

    ////////////////////////////////////////////////////////////////////////////

    onAboutToShow: { }
    onAboutToHide: { }

    function openCC(cc, writeMode) {
        if (characteristic !== cc) {
            characteristic = cc
            uuid_tf.text = characteristic.uuid_full

            // reset selectors, to the presentation format descriptor if any
            formatSelectors.reset()

            // reset data
            scaleValue = false
            textfieldValue_data.clear()
            textfieldValue_text.clear()
            textfieldValue_int.clear()
            textfieldValue_float.clear()
        }

        // always follow the caller, even when reopening the same characteristic
        if (writeMode === undefined) {
            writeMode = hasWriteWithResponse ? PopupWriteCharacteristic.WriteMode.WithResponse :
                                               PopupWriteCharacteristic.WriteMode.WithoutResponse
        }
        selectorWriteMode.currentSelection = writeMode

        open()
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.333 : 0.666
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground

        Item {
            anchors.fill: parent

            Rectangle { // title area
                anchors.left: parent.left
                anchors.right: parent.right
                height: 96
                color: Theme.colorPrimary
            }

            Rectangle { // border
                anchors.fill: parent
                radius: Theme.componentRadius
                color: "transparent"
                border.color: Theme.colorSeparator
                border.width: Theme.componentBorderWidth
                opacity: 0.4
            }

            layer.enabled: true
            layer.effect: MultiEffect { // clip
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#aa444444"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: Theme.componentMarginXL

        ////////////////

        Item { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right
            height: 96

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
                anchors.rightMargin: Theme.componentMarginXL
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMarginXS

                Repeater { // characteristic properties
                    anchors.verticalCenter: parent.verticalCenter
                    model: characteristic && characteristic.propertiesList

                    TagClear {
                        text: modelData
                        colorText: "white"
                        color: Theme.colorForeground
                        opacity: 0.84
                    }
                }
            }
        }

        ////////////////

        WriteFormatHints { // what the descriptors say about the expected value
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL

            characteristic: popupWriteCharacteristic.characteristic
            expectedSize: popupWriteCharacteristic.expectedSize
            writeExponent: popupWriteCharacteristic.writeExponent
        }

        ////////////////

        WriteFormatSelectors {
            id: formatSelectors
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL

            characteristic: popupWriteCharacteristic.characteristic
        }

        ////////////////

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMarginXS

            visible: (popupWriteCharacteristic.hasWriteWithResponse &&
                      popupWriteCharacteristic.hasWriteWithoutResponse)

            ////

            SectionTitle {
                width: parent.width
                text: qsTr("Mode")
            }

            ////

            WriteSelector {
                id: selectorWriteMode

                model: ListModel {
                    ListElement { idx: 0; txt: qsTr("with response"); src: ""; sz: 16; }
                    ListElement { idx: 1; txt: qsTr("without response"); src: ""; sz: 16; }
                }

                currentSelection: PopupWriteCharacteristic.WriteMode.WithResponse
            }

            ////
        }

        ////////////////

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMarginXS

            ////

            Row {
                spacing: Theme.componentMargin

                SectionTitle {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Value")
                }

                SwitchThemed {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: popupWriteCharacteristic.canScaleValue
                    text: qsTr("scaled value (exponent %1)").arg(popupWriteCharacteristic.characteristic ?
                                                                 popupWriteCharacteristic.characteristic.formatExponent : 0)
                    checked: popupWriteCharacteristic.scaleValue
                    onClicked: popupWriteCharacteristic.scaleValue = checked
                }
            }

            ////

            TextFieldThemed {
                id: textfieldValue_text
                width: parent.width

                readonly property bool isAscii: (formatSelectors.textFormat === WriteFormatSelectors.TextFormat.Ascii)

                visible: (formatSelectors.type === WriteFormatSelectors.Type.Text)
                placeholderText: isAscii ? qsTr("ascii text") : qsTr("utf8 text")

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                // exact for ascii (one byte per character), an upper bound for utf8 (up to four)
                maximumLength: popupWriteCharacteristic.maxValueSize

                RegularExpressionValidator {
                    id: validatorAscii
                    regularExpression: /([\x00-\x7F])+/
                }
                validator: textfieldValue_text.isAscii ? validatorAscii : null
            }
            TextFieldThemed {
                id: textfieldValue_data
                width: parent.width

                visible: (formatSelectors.type === WriteFormatSelectors.Type.Data)
                placeholderText: qsTr("hexadecimal data")

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                maximumLength: popupWriteCharacteristic.maxValueSize * 2 // two characters per byte
                validator: RegularExpressionValidator { regularExpression: /[a-fA-F0-9]+/ }
                //inputMask: "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
            }
            TextFieldThemed {
                id: textfieldValue_int
                width: parent.width

                readonly property bool isScaled: (popupWriteCharacteristic.writeExponent !== 0)
                readonly property bool isSigned: formatSelectors.isSigned

                visible: (formatSelectors.type === WriteFormatSelectors.Type.Integer)
                placeholderText: isScaled ? qsTr("decimal value") : qsTr("integer")

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                RegularExpressionValidator {
                    id: validatorSigned
                    regularExpression: /-?[0-9]+/
                }
                RegularExpressionValidator {
                    id: validatorUnsigned
                    regularExpression: /[0-9]+/
                }
                RegularExpressionValidator {
                    id: validatorSignedDecimal
                    regularExpression: /-?[0-9]+(\.[0-9]*)?/
                }
                RegularExpressionValidator {
                    id: validatorUnsignedDecimal
                    regularExpression: /[0-9]+(\.[0-9]*)?/
                }
                validator: isScaled ? (isSigned ? validatorSignedDecimal : validatorUnsignedDecimal) :
                                      (isSigned ? validatorSigned : validatorUnsigned)
            }
            TextFieldThemed {
                id: textfieldValue_float
                width: parent.width

                visible: (formatSelectors.type === WriteFormatSelectors.Type.Float)
                placeholderText: qsTr("floating point")

                font.pixelSize: 18
                font.bold: false
                color: Theme.colorText
                selectByMouse: true

                validator: DoubleValidator { locale: "C" }
            }

            ////
        }

        ////////////////

        WriteValuePreview {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL

            bytes: popupWriteCharacteristic.encoded.hex
            partialNibble: popupWriteCharacteristic.valueIncompleteByte ?
                               textfieldValue_data.text.slice(-1).toLowerCase() : ""
            expectedSize: popupWriteCharacteristic.expectedSize
            maxPacketSize: popupWriteCharacteristic.maxPacketSize
            status: popupWriteCharacteristic.writeStatus
        }

        ////////////////

        Item { width: 1; height: 1; } // spacer

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMargin

            ButtonSolid {
                color: Theme.colorMaterialGrey

                text: qsTr("Cancel")
                onClicked: popupWriteCharacteristic.close()
            }

            ButtonSolid {
                color: Theme.colorMaterialAmber

                enabled: popupWriteCharacteristic.writeStatus.canWrite

                text: qsTr("Write value")
                onClicked: {
                    selectedDevice.askForWrite(characteristic.uuid_full,
                                               popupWriteCharacteristic.encoded.bytes,
                                               popupWriteCharacteristic.writeWithResponse)
                    popupWriteCharacteristic.close()
                }
            }
        }

        Item{ width: 1; height: 1; } // spacer

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
