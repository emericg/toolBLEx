import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import ComponentLibrary

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    // settings
    font.pixelSize: Theme.componentFontSize
    property int radius: Theme.componentRadius

    // colors
    property color colorBackground: control.down ? Theme.colorComponentDown : Theme.colorComponent
    property color colorBackgroundBorder: Theme.colorComponentBorder

    // secondary text
    property string subText: ""
    property string subTextRole: ""

    // icon
    property string iconRole: "source"
    readonly property var currentIconSource: currentRoleData(currentIndex, iconRole)
    readonly property bool hasCurrentIcon: currentIconSource.toString().length > 0

    function currentRoleData(index, role) {
        if (index < 0 || !role || !control.model)
            return ""

        if (Array.isArray(control.model)) {
            const item = control.model[index]
            return (item && item[role]) ? item[role] : ""
        }
        if (typeof control.model.get === "function") {
            const entry = control.model.get(index)
            return (entry && entry[role]) ? entry[role] : ""
        }
        return ""
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.componentHeight

        radius: control.radius
        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground
        border.width: 2
        border.color: control.colorBackgroundBorder
    }

    ////////////////

    contentItem: RowLayout {
        IconSvg {
            Layout.preferredWidth: control.hasCurrentIcon ? 20 : 0
            Layout.preferredHeight: 20

            visible: control.hasCurrentIcon
            source: control.currentIconSource
            color: Theme.colorIcon
            opacity: control.enabled ? 1 : 0.66
        }

        Text {
            Layout.leftMargin: control.hasCurrentIcon ? 8 : 0
            Layout.fillWidth: !control.subText
            Layout.maximumWidth: control.availableWidth - control.indicator.width - (control.subText ? 8 : 0)

            rightPadding: control.subText ? 0 : control.indicator.width
            verticalAlignment: Text.AlignVCenter

            text: control.displayText
            textFormat: Text.PlainText

            font: control.font
            elide: Text.ElideRight

            color: Theme.colorComponentContent
            opacity: control.enabled ? 1 : 0.66
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 0

            rightPadding: control.indicator.width
            verticalAlignment: Text.AlignVCenter

            visible: control.subText
            text: control.subText
            textFormat: Text.PlainText

            font: control.font
            elide: Text.ElideRight

            color: Theme.colorSubText
            opacity: control.enabled ? 1 : 0.66
        }
    }

    ////////////////

    indicator: Canvas {
        x: control.width - width - control.rightPadding
        y: control.topPadding + ((control.availableHeight - height) / 2)
        width: 12
        height: 8
        opacity: control.enabled ? 1 : 0.66
        rotation: control.popup.visible ? 180 : 0

        Connections {
            target: Theme
            function onCurrentThemeChanged() { control.indicator.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = Theme.colorIcon
            ctx.fill()
        }
    }

    ////////////////

    delegate: T.ItemDelegate {
        required property var model
        required property int index

        readonly property var iconSource: (control.iconRole && model && model[control.iconRole]) ? model[control.iconRole] : ""
        readonly property bool hasIcon: iconSource ? iconSource.toString().length > 0 : false
        readonly property string subText: (control.subTextRole && model && model[control.subTextRole]) ? model[control.subTextRole] : ""
        readonly property bool selected: (control.currentIndex === index)

        width: control.width - 2
        height: control.height
        highlighted: (control.highlightedIndex === index)

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: Theme.componentHeight

            radius: control.radius - 1
            color: {
                if (highlighted) return Theme.colorComponentDown
                if (selected) return Qt.alpha(Theme.colorPrimary, 0.12)
                return Theme.colorComponentBackground
            }
        }

        contentItem: RowLayout {
            IconSvg {
                Layout.leftMargin: hasIcon ? control.leftPadding : 0
                Layout.preferredWidth: hasIcon ? 24 : 0
                Layout.preferredHeight: 24

                visible: hasIcon
                source: iconSource
                color: selected ? Theme.colorPrimary : Theme.colorIcon
            }

            Text {
                Layout.leftMargin: hasIcon ? control.leftPadding / 2 : control.leftPadding
                Layout.rightMargin: subText ? 0 : control.rightPadding
                Layout.fillWidth: true

                color: {
                    if (selected) return Theme.colorPrimary
                    if (highlighted) return Theme.colorComponentContent
                    return Theme.colorSubText
                }
                opacity: 1.0

                text: control.textAt(index)
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                Layout.leftMargin: 8
                Layout.rightMargin: control.rightPadding
                Layout.maximumWidth: parent.width / 2

                visible: subText.length > 0
                color: Theme.colorSubText
                opacity: 0.8

                text: subText
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ////////////////

    popup: T.Popup {
        width: control.width
        height: contentItem.implicitHeight ? contentItem.implicitHeight + 4 : 0
        padding: 2

        topMargin: Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop)
        bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }

        background: Rectangle {
            radius: control.radius
            color: Theme.colorComponentBackground
            border.color: Theme.colorComponentBorder
            border.width: 2
        }
    }

    ////////////////
}
