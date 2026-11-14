import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

Item {
    id: control

    // A two-button action row: a primary (solid or clear) and an outlined secondary
    // The primary button is hidden (and takes no space) when it has neither text nor icon,the secondary one when its text is empty
    property string primaryText: "Action"
    property string secondaryText: ""

    // Primary button styles:
    // - Solid: filled with the primary color
    // - Clear: flat, tinted with the primary color
    enum ButtonStyle { Solid, Clear }
    property int primaryStyle: CardActionRow.ButtonStyle.Solid

    // Optional icon, drawn after the primary button text
    property url primarySource
    property int primarySourceRotation: 0

    readonly property bool hasPrimary: (control.primaryText.length > 0 || control.primarySource.toString().length > 0)
    readonly property T.AbstractButton primaryButton: buttonSolid.visible ? buttonSolid : (buttonClear.visible ? buttonClear : null)

    property int buttonHeight: Theme.componentHeight
    property int topPadding: 0

    signal primaryClicked()
    signal secondaryClicked()

    implicitWidth: row.width
    implicitHeight: row.height + topPadding

    Row {
        id: row
        y: control.topPadding
        spacing: Theme.componentMarginXS

        ButtonSolid {
            id: buttonSolid
            height: control.buttonHeight
            visible: control.hasPrimary && (control.primaryStyle === CardActionRow.ButtonStyle.Solid)
            text: control.primaryText
            color: Theme.colorPrimary
            source: control.primarySource
            sourceRotation: control.primarySourceRotation
            layoutDirection: Qt.RightToLeft
            onClicked: control.primaryClicked()
        }

        ButtonClear {
            id: buttonClear
            height: control.buttonHeight
            visible: control.hasPrimary && (control.primaryStyle === CardActionRow.ButtonStyle.Clear)
            text: control.primaryText
            color: Theme.colorPrimary
            source: control.primarySource
            sourceRotation: control.primarySourceRotation
            layoutDirection: Qt.RightToLeft
            onClicked: control.primaryClicked()
        }

        ButtonOutline {
            height: control.buttonHeight
            visible: (control.secondaryText.length > 0)
            text: control.secondaryText
            onClicked: control.secondaryClicked()
        }
    }
}
