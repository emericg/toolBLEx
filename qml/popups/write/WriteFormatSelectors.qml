import QtQuick
import QtQuick.Controls

import ComponentLibrary
import BleFormat

/*!
 * How the value to write is typed and encoded: value type, size, byte order...
 * Follows the presentation format descriptor of the characteristic, when there is one.
 */
Column {
    id: writeFormatSelectors

    spacing: Theme.componentMarginXS

    property var characteristic: null

    // Selector indexes, to keep the selectors and the write logic in sync
    enum Type { Data, Text, Integer, Float }
    enum TextFormat { Ascii, Utf8 }
    enum Sign { Signed, Unsigned }
    enum Endian { LittleEndian, BigEndian }

    ////////////////

    // Current selection
    readonly property int type: selectorType.currentSelection
    readonly property int textFormat: selectorTextFormat.currentSelection
    readonly property bool isSigned: (selectorIntSign.currentSelection === WriteFormatSelectors.Sign.Signed)
    readonly property bool bigEndian: (selectorEndian.currentSelection === WriteFormatSelectors.Endian.BigEndian)

    // GATT formats of the integer selectors, [signed, unsigned] for each size (8 to 64 bits)
    readonly property var intFormats: [
        [ BleFormat.FORMAT_SINT8,  BleFormat.FORMAT_UINT8 ],
        [ BleFormat.FORMAT_SINT16, BleFormat.FORMAT_UINT16 ],
        [ BleFormat.FORMAT_SINT24, BleFormat.FORMAT_UINT24 ],
        [ BleFormat.FORMAT_SINT32, BleFormat.FORMAT_UINT32 ],
        [ BleFormat.FORMAT_SINT48, BleFormat.FORMAT_UINT48 ],
        [ BleFormat.FORMAT_SINT64, BleFormat.FORMAT_UINT64 ],
    ]

    // GATT formats of the float size selector (32 and 64 bits)
    readonly property var floatFormats: [ BleFormat.FORMAT_FLOAT32, BleFormat.FORMAT_FLOAT64 ]

    // GATT format of the current selectors (ascii is utf8, restricted by the text field validator)
    readonly property int selectedFormat: {
        switch (selectorType.currentSelection) {
        case WriteFormatSelectors.Type.Text: return BleFormat.FORMAT_UTF8S
        case WriteFormatSelectors.Type.Integer: return intFormats[selectorIntSize.currentSelection][selectorIntSign.currentSelection]
        case WriteFormatSelectors.Type.Float: return floatFormats[selectorFloatSize.currentSelection]
        }
        return BleFormat.FORMAT_STRUCT // raw hexadecimal data
    }

    ////////////////

    // Selectors matching the presentation format descriptor (null if there is
    // none, if it is an aggregate, or if the popup cannot write that format)
    readonly property var descriptorSelection: {
        if (!characteristic || characteristic.formatType < 0) return null

        const f = characteristic.formatType

        // sub-byte and 12 bits integers use the next integer size selectors
        const narrow = {
            [BleFormat.FORMAT_BOOLEAN]: BleFormat.FORMAT_UINT8,
            [BleFormat.FORMAT_UINT2]: BleFormat.FORMAT_UINT8,
            [BleFormat.FORMAT_UINT4]: BleFormat.FORMAT_UINT8,
            [BleFormat.FORMAT_UINT12]: BleFormat.FORMAT_UINT16,
            [BleFormat.FORMAT_SINT12]: BleFormat.FORMAT_SINT16,
        }
        const fi = narrow[f] ?? f

        for (let size = 0; size < intFormats.length; size++) {
            const sign = intFormats[size].indexOf(fi)
            if (sign >= 0) return { type: WriteFormatSelectors.Type.Integer, format: fi, sign: sign, size: size }
        }

        const fsize = floatFormats.indexOf(f)
        if (fsize >= 0) return { type: WriteFormatSelectors.Type.Float, format: f, size: fsize }

        if (f === BleFormat.FORMAT_UTF8S) {
            return { type: WriteFormatSelectors.Type.Text, text: WriteFormatSelectors.TextFormat.Utf8 }
        }
        if ([BleFormat.FORMAT_STRUCT, BleFormat.FORMAT_MEDASN1, BleFormat.FORMAT_UINT128,
             BleFormat.FORMAT_SINT128, BleFormat.FORMAT_UINT16_2].indexOf(f) >= 0) {
            return { type: WriteFormatSelectors.Type.Data }
        }

        return null // medfloat16, medfloat32, utf16s, RFU
    }

    // Do the selectors currently match the presentation format descriptor?
    readonly property bool formatMatchesDescriptor: {
        const d = descriptorSelection
        if (!d || selectorType.currentSelection !== d.type) return false

        if (d.type === WriteFormatSelectors.Type.Integer || d.type === WriteFormatSelectors.Type.Float)
            return (!bigEndian && selectedFormat === d.format)
        if (d.type === WriteFormatSelectors.Type.Text)
            return (selectorTextFormat.currentSelection === d.text)

        return true
    }

    // Are we writing the descriptor integer format? (then its exponent can apply, and
    // sub-byte and 12 bits integers keep their own range instead of the selector one)
    readonly property bool writeDescriptorInteger: (formatMatchesDescriptor &&
                                                    descriptorSelection.type === WriteFormatSelectors.Type.Integer)

    // GATT format used to encode the value
    readonly property int writeFormat: writeDescriptorInteger ? characteristic.formatType : selectedFormat

    ////////////////

    // Selector item matching the descriptor, for a value type: a descriptorSelection key, or a fixed index
    function descriptorDefault(type, key) {
        const d = descriptorSelection
        if (!d || d.type !== type) return -1
        return (typeof key === "string") ? d[key] : key
    }

    // Set the selectors from the presentation format descriptor (GATT values are always little endian)
    function applyDescriptorFormat() {
        const d = descriptorSelection
        if (d) {
            selectorType.currentSelection = d.type
            selectorEndian.currentSelection = WriteFormatSelectors.Endian.LittleEndian
            if (d.type === WriteFormatSelectors.Type.Integer) {
                selectorIntSign.currentSelection = d.sign
                selectorIntSize.currentSelection = d.size
            } else if (d.type === WriteFormatSelectors.Type.Float) {
                selectorFloatSize.currentSelection = d.size
            } else if (d.type === WriteFormatSelectors.Type.Text) {
                selectorTextFormat.currentSelection = d.text
            }
        }
    }

    // Back to the default selectors, or to the descriptor format if there is one
    function reset() {
        selectorType.currentSelection = WriteFormatSelectors.Type.Data
        selectorDataFormat.currentSelection = 0 // bytes
        selectorTextFormat.currentSelection = WriteFormatSelectors.TextFormat.Ascii
        selectorIntSign.currentSelection = WriteFormatSelectors.Sign.Signed
        selectorEndian.currentSelection = WriteFormatSelectors.Endian.LittleEndian
        selectorIntSize.currentSelection = 3 // 32 bits
        selectorFloatFormat.currentSelection = 0 // IEEE 754
        selectorFloatSize.currentSelection = 0 // 32 bits

        applyDescriptorFormat()
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        spacing: Theme.componentMargin

        SectionTitle {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Format")
        }

        AbstractButton { // descriptor format: in use, or apply it
            id: buttonDescriptorFormat
            anchors.verticalCenter: parent.verticalCenter
            height: 26

            leftPadding: 10
            rightPadding: 10
            focusPolicy: Qt.NoFocus

            readonly property bool inUse: writeFormatSelectors.formatMatchesDescriptor

            visible: (writeFormatSelectors.descriptorSelection !== null)
            enabled: !inUse
            hoverEnabled: enabled

            onClicked: writeFormatSelectors.applyDescriptorFormat()

            background: Rectangle {
                radius: parent.height / 2
                color: buttonDescriptorFormat.hovered ? Theme.colorComponentDown : Theme.colorComponent
            }

            contentItem: Row {
                spacing: 6

                IconSvg { // in use
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16

                    visible: buttonDescriptorFormat.inUse
                    source: "qrc:/IconLibrary/material-symbols/check.svg"
                    color: Theme.colorGreen
                }

                Rectangle { // same dot as the descriptor format in the selectors
                    anchors.verticalCenter: parent.verticalCenter
                    width: 8
                    height: 8
                    radius: 4

                    visible: !buttonDescriptorFormat.inUse
                    color: Theme.colorGreen
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: buttonDescriptorFormat.inUse ? qsTr("from descriptor") : qsTr("use descriptor format")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorSubText
                }
            }
        }
    }

    ////////////////

    Row { // value type, and its sub types
        width: parent.width
        spacing: Theme.componentMargin

        WriteSelector { // value type
            id: selectorType
            defaultSelection: writeFormatSelectors.descriptorSelection?.type ?? -1

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("data"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("text"); src: ""; sz: 16; }
                ListElement { idx: 2; txt: qsTr("integer"); src: ""; sz: 16; }
                ListElement { idx: 3; txt: qsTr("float"); src: ""; sz: 16; }
            }

            currentSelection: WriteFormatSelectors.Type.Data
        }

        WriteSelector { // data format
            id: selectorDataFormat
            defaultSelection: writeFormatSelectors.descriptorDefault(WriteFormatSelectors.Type.Data, 0)

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Data)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("bytes"); src: ""; sz: 16; }
            }

            currentSelection: 0
        }

        WriteSelector { // text format
            id: selectorTextFormat
            defaultSelection: writeFormatSelectors.descriptorDefault(WriteFormatSelectors.Type.Text, "text")

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Text)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("ascii"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("utf8"); src: ""; sz: 16; }
            }

            currentSelection: WriteFormatSelectors.TextFormat.Ascii
        }

        WriteSelector { // integer signedness
            id: selectorIntSign
            defaultSelection: writeFormatSelectors.descriptorDefault(WriteFormatSelectors.Type.Integer, "sign")

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Integer)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("signed"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("unsigned"); src: ""; sz: 16; }
            }

            currentSelection: WriteFormatSelectors.Sign.Signed
        }

        WriteSelector { // float format
            id: selectorFloatFormat
            defaultSelection: writeFormatSelectors.descriptorDefault(WriteFormatSelectors.Type.Float, 0)

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Float)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("IEEE 754"); src: ""; sz: 16; }
            }

            currentSelection: 0
        }
    }

    ////////////////

    Row { // value size
        width: parent.width
        spacing: Theme.componentMargin

        visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Integer ||
                  selectorType.currentSelection === WriteFormatSelectors.Type.Float)

        WriteSelector { // integer size
            id: selectorIntSize
            defaultSelection: writeFormatSelectors.descriptorDefault(WriteFormatSelectors.Type.Integer, "size")

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Integer)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("8 bits"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("16 bits"); src: ""; sz: 16; }
                ListElement { idx: 2; txt: qsTr("24 bits"); src: ""; sz: 16; }
                ListElement { idx: 3; txt: qsTr("32 bits"); src: ""; sz: 16; }
                ListElement { idx: 4; txt: qsTr("48 bits"); src: ""; sz: 16; }
                ListElement { idx: 5; txt: qsTr("64 bits"); src: ""; sz: 16; }
            }

            currentSelection: 3 // 32 bits
        }

        WriteSelector { // byte order
            id: selectorEndian
            defaultSelection: [ WriteFormatSelectors.Type.Integer, WriteFormatSelectors.Type.Float ]
                                  .includes(writeFormatSelectors.descriptorSelection?.type) ?
                                      WriteFormatSelectors.Endian.LittleEndian : -1

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Integer ||
                      selectorType.currentSelection === WriteFormatSelectors.Type.Float)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("le"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("be"); src: ""; sz: 16; }
            }

            currentSelection: WriteFormatSelectors.Endian.LittleEndian
        }

        WriteSelector { // float size
            id: selectorFloatSize
            defaultSelection: writeFormatSelectors.descriptorDefault(WriteFormatSelectors.Type.Float, "size")

            visible: (selectorType.currentSelection === WriteFormatSelectors.Type.Float)

            model: ListModel {
                ListElement { idx: 0; txt: qsTr("32 bits"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("64 bits"); src: ""; sz: 16; }
            }

            currentSelection: 0 // 32 bits
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
