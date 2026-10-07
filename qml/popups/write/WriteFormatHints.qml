import QtQuick
import QtQuick.Layouts

import ComponentLibrary

/*!
 * What the characteristic descriptors tell us about the value to write.
 * Hidden when the descriptors tell us nothing.
 */
Rectangle {
    id: writeFormatHints

    height: columnExpected.height
    radius: Theme.componentRadius
    color: Theme.colorBox

    visible: (characteristic && (characteristic.hasPresentationFormat ||
                                 characteristic.hasValidRange ||
                                 characteristic.isAggregate))

    property var characteristic: null

    ////////////////

    //! Size of the value, in bytes, -1 if unknown
    property int expectedSize: -1

    //! Exponent applied to the value being typed, 0 if it is written raw
    property int writeExponent: 0

    //! What the descriptors tell us about the value, as { label, value }, the empty ones are skipped
    readonly property var hints: {
        if (!characteristic) return []

        const exponent = characteristic.formatExponent
        let exponentHint = ""
        if (exponent !== 0) {
            exponentHint = (writeExponent !== 0) ?
                qsTr("%1, write the actual value, it will be scaled").arg(exponent) :
                qsTr("%1, write the raw value (the actual value multiplied by %2)").arg(exponent).arg(Math.pow(10, -exponent))
        }

        return [
            { label: qsTr("Format"), value: characteristic.formatName ?
                  "%1 (%2)".arg(characteristic.formatName).arg(characteristic.formatInfo) : "" },
            { label: qsTr("Size"), value: (expectedSize > 0) ? qsTr("%n byte(s)", "", expectedSize) : "" },
            { label: qsTr("Exponent"), value: exponentHint },
            { label: qsTr("Unit"), value: characteristic.formatUnit },
            { label: qsTr("Valid range"), value: characteristic.hasValidRange ? characteristic.validRange : "" },
            { label: qsTr("Aggregate of"), value: characteristic.isAggregate ? characteristic.formatsList.join("\n") : "" },
        ].filter(h => h.value)
    }

    ////////////////////////////////////////////////////////////////////////

    Column {
        id: columnExpected
        width: parent.width

        ////////

        Rectangle { // banner
            width: parent.width
            height: 44
            radius: Theme.componentRadius
            color: Qt.darker(Theme.colorBackground, 1.02)

            Rectangle { // square bottom corners
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
                color: Theme.colorPrimary
            }

            SectionTitle {
                anchors.left: parent.left
                anchors.leftMargin: 52
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Expected value")
            }
        }

        ////////

        Column {
            id: columnHints
            x: Theme.componentMargin
            width: parent.width - Theme.componentMargin * 2

            topPadding: Theme.componentMarginS
            bottomPadding: Theme.componentMarginS
            spacing: 2

            readonly property int legendWidth: {
                let w = 0
                for (const h of writeFormatHints.hints) {
                    w = Math.max(w, fontMetricsHints.advanceWidth(h.label))
                }
                return Math.ceil(w)
            }
            FontMetrics {
                id: fontMetricsHints
                font.pixelSize: Theme.fontSizeContent
            }

            Repeater {
                model: writeFormatHints.hints

                RowLayout {
                    required property var modelData

                    width: columnHints.width
                    spacing: Theme.componentMargin

                    Text {
                        Layout.preferredWidth: columnHints.legendWidth
                        Layout.alignment: Qt.AlignTop

                        text: modelData.label
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        text: modelData.value
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        wrapMode: Text.Wrap
                        color: Theme.colorText
                    }
                }
            }

            Text { // aggregate, with formats declared elsewhere
                width: parent.width

                visible: (writeFormatHints.characteristic &&
                          writeFormatHints.characteristic.isAggregate &&
                          !writeFormatHints.characteristic.formatsResolved)
                text: qsTr("Some of these formats are declared on other characteristics, the fields order is unknown.")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                wrapMode: Text.WordWrap
                color: Theme.colorWarning
            }
        }

        ////////
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: Theme.colorSeparator
        border.width: 2
    }

    ////////////////////////////////////////////////////////////////////////
}
