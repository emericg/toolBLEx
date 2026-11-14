import QtQuick

import ComponentLibrary

/*!
 * \brief A TextFieldThemed in the SelectorMenuColorful style.
 *
 * A pill with a border, highlighted (primary color) while editing,
 * to sit next to SelectorMenuColorful and ComboBoxColorful controls.
 * An optional icon is drawn inside the field, on its left or right side, the text padded around it.
 *
 * \property iconSource The icon drawn inside the field, none when empty.
 * \property iconPosition The side of the icon, Qt.AlignLeft or Qt.AlignRight.
 */
TextFieldThemed {
    id: control

    leftPadding: (hasIcon && iconPosition === Qt.AlignLeft) ? height : 16
    rightPadding: (hasIcon && iconPosition === Qt.AlignRight) ? height : 16
    topPadding: 0
    bottomPadding: 0

    property url iconSource
    property int iconPosition: Qt.AlignRight
    readonly property bool hasIcon: (iconSource.toString().length > 0)

    // colors
    colorBorder: Theme.colorComponentBorder
    colorBackground: Theme.colorComponentBackground
    colorSelection: Theme.colorPrimary

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 32

        radius: height
        color: control.colorBackground

        border.width: 2
        border.color: control.activeFocus ? control.colorSelection : control.colorBorder
    }

    ////////////////

    IconSvg {
        x: (control.iconPosition === Qt.AlignLeft) ? (control.height - width) / 2
                                                   : control.width - (control.height + width) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: Math.round(control.height * 0.666)
        height: width

        visible: control.hasIcon
        source: control.iconSource
        color: control.activeFocus ? control.colorSelection : control.colorPlaceholderText
    }

    ////////////////
}
