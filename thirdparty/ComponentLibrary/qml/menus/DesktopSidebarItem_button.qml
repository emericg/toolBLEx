import QtQuick

import ComponentLibrary

DesktopSidebarMenu {
    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.right: parent.right

    height: Theme.componentHeight

    source: checked ? "qrc:/IconLibrary/material-symbols/circle-fill.svg"
                    : "qrc:/IconLibrary/material-symbols/circle.svg"
    sourceSize: 12
}
