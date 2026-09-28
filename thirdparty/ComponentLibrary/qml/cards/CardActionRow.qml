import QtQuick

import ComponentLibrary

Item {
    id: control

    // A two-button action row: a primary (solid or clear) and an outlined secondary.
    // The secondary button is hidden (and takes no space) when its text is empty.
    property string primaryText: "Action"
    property string secondaryText: ""

    // Primary button styles:
    // - Solid: filled with the primary color.
    // - Clear: flat, tinted with the primary color.
    enum ButtonStyle { Solid, Clear }
    property int primaryStyle: CardActionRow.ButtonStyle.Solid

    // Optional icon, drawn after the primary button text.
    property url primarySource
    property int primarySourceRotation: 0

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
            height: control.buttonHeight
            visible: (control.primaryStyle === CardActionRow.ButtonStyle.Solid)
            text: control.primaryText
            color: Theme.colorPrimary
            source: control.primarySource
            sourceRotation: control.primarySourceRotation
            layoutDirection: Qt.RightToLeft
            onClicked: control.primaryClicked()
        }

        ButtonClear {
            height: control.buttonHeight
            visible: (control.primaryStyle === CardActionRow.ButtonStyle.Clear)
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
