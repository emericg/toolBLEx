import QtQuick

import ComponentLibrary

Column {
    id: sidebarSubMenu

    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 8

    //height: checked ? cccccc.height : Theme.componentHeight
    //Behavior on height { NumberAnimation { duration: Theme.animationSlowSpeed } }

    property string category
    property string text: "submenu"
    property url source: "qrc:/ComponentLibraryAssets/icons/menu.svg"

    property bool checked: false
    property int selected: 0

    signal clicked()

    /////////

    property var submenus

    ////////

    DesktopSidebarItem_menu {
        text: sidebarSubMenu.text
        source: sidebarSubMenu.source
        checked: sidebarSubMenu.checked
        onClicked: sidebarSubMenu.clicked()

        DesktopSidebarMenuTree {
            visible: true
            enabled: parent.checked
            buttonCount: sidebarSubMenu.submenus.length
        }
    }
    ////////

    Repeater {
        model: sidebarSubMenu.submenus
        delegate: DesktopSidebarItem_button {
            text: modelData.text

            checked: sidebarSubMenu.checked && sidebarSubMenu.selected === index
            onClicked: {
                sidebarSubMenu.selected = index
                modelData.onClicked()
            }
        }
    }

    ////////

    component DesktopSidebarMenuTree: Rectangle {
        anchors.top: parent.bottom
        anchors.topMargin: 8 + Theme.componentHeight / 2
        anchors.left: parent.left
        anchors.leftMargin: 2

        width: 2
        height: (Theme.componentHeight + 8) * (buttonCount-1) + 2

        visible: true
        enabled: false

        color: enabled ? Theme.colorPrimary : Theme.colorSeparator
        opacity: 1

        property int buttonCount: 4

        Repeater {
            model: buttonCount
            Rectangle {
                anchors.left: parent.right
                y: index*(Theme.componentHeight+8)
                width: 6
                height: parent.width
                color: parent.color
                opacity: parent.opacity
            }
        }
    }

    ////////
}
