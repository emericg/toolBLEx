import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

/*!
 * \brief A ComboBoxBar with a square icon button at its end, opening a menu sliding down below it, or up above it.
 *
 * Taller, without radius nor side borders, separated from the content by a line above and below.
 * Meant to be anchored to the screen edges, its texts aligned with the screen margins.
 * The list, the search field and the menu slide down the same way (or up, for a bar along the bottom edge),
 * and opening one closes the others.
 *
 * \property menuContentItem The menu content, set by the caller (ex: a Column of controls).
 * \property menu The menu popup, to open() or close() it.
 * \property menuSource The menu button icon.
 * \property menuButtonVisible Show the menu button, ex: false for a view without a menu.
 * \property searchButtonVisible Show the search button, before the menu button.
 *           It opens a text field sliding below the bar (or above it), drawn over the content.
 *           Its icon stays highlighted while the field holds a text, the filter being active.
 * \property searchText The search field text.
 * \property searchPlaceholderText The search field placeholder.
 * \property searchPopup The search popup, to open() or close() it.
 * \property edge The screen edge the bar is along: Qt.TopEdge (default), opening the list and the menu below it,
 *           or Qt.BottomEdge, opening them above it. Any other edge is handled as Qt.TopEdge.
 * \property leftSafeArea, rightSafeArea Width of the screen safe areas beside the control, in pixels:
 *           its background, its list and its menu extend under them, their content stays clear of them.
 */
ComboBoxThemed {
    id: control

    leftPadding: Theme.componentMarginXL
    rightPadding: Theme.componentMarginXL + (menuButton.visible ? menuButton.width : 0)
                                          + (searchButton.visible ? searchButton.width : 0)

    leftInset: -leftSafeArea
    rightInset: -rightSafeArea

    radius: 0

    colorBackground: control.down ? Theme.colorComponentDown : Qt.lighter(Theme.colorTabletmenu, Theme.isLight ? 1.02 : 1.1)
    colorBackgroundBorder: Theme.colorSeparator

    property alias menu: menuPopup
    property alias menuContentItem: menuPopup.contentItem
    property url menuSource: "qrc:/IconLibrary/material-symbols/settings.svg"
    property bool menuButtonVisible: true

    property alias searchPopup: searchPopup
    property alias searchText: searchField.text
    property string searchPlaceholderText
    property bool searchButtonVisible: false

    /*!
     * \brief Emitted when the user edits the search text, or clears it.
     */
    signal searchTextEdited()

    /*!
     * \brief Emitted when the user validates the search text (Return or Enter), closing the search field.
     */
    signal searchAccepted()

    /*!
     * \brief Open the search field, giving it the focus.
     */
    function openSearch() {
        searchPopup.open()
    }

    property int edge: Qt.TopEdge
    indicator.rotation: (popup.visible === (edge !== Qt.BottomEdge)) ? 180 : 0

    property real leftSafeArea: 0
    property real rightSafeArea: 0

    // A popup spanning the control width below it, sliding up/down when opened.
    component SlidingPopup: T.Popup {
        id: sliding

        property real revealed: 0
        property color colorBorder: Theme.colorSeparator

        x: -control.leftSafeArea
        y: (control.edge !== Qt.BottomEdge) ? control.height : -height
        width: control.leftSafeArea + (parent ? parent.width : 0) + control.rightSafeArea
        leftPadding: padding + control.leftSafeArea
        rightPadding: padding + control.rightSafeArea
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                 implicitContentHeight + topPadding + bottomPadding)
        height: implicitHeight * revealed

        topMargin: Math.max(Theme.screenPaddingStatusbar, Theme.screenPaddingTop)
        bottomMargin: Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)

        clip: true

        enter: Transition {
            NumberAnimation {
                property: "revealed"
                from: 0; to: 1
                duration: Theme.animationSpeedFast
                easing.type: Easing.OutQuad
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "revealed"
                to: 0
                duration: Theme.animationSpeedFast
                easing.type: Easing.InQuad
            }
        }

        background: Rectangle {
            color: Theme.colorComponentBackground

            Rectangle { // separator
                y: (control.edge !== Qt.BottomEdge) ? (parent.height - height) : 0
                width: parent.width
                height: 1
                color: sliding.colorBorder
            }
        }
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Theme.componentHeightXL

        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground

        Rectangle { // top separator
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: control.colorBackgroundBorder
        }
        Rectangle { // bottom separator
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: control.colorBackgroundBorder
        }
    }

    ////////////////

    popup: SlidingPopup {
        padding: 1

        colorBorder: control.colorBackgroundBorder

        onAboutToShow: {
            menuPopup.close()
            searchPopup.close()
        }

        contentItem: ListView {
            implicitHeight: contentHeight
            clip: true
            currentIndex: control.highlightedIndex
            model: control.popup.visible ? control.delegateModel : null
        }
    }

    SlidingPopup {
        id: menuPopup

        padding: Theme.componentMargin

        colorBorder: control.colorBackgroundBorder
        closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent

        onAboutToShow: {
            control.popup.close()
            searchPopup.close()
        }
    }

    SlidingPopup {
        id: searchPopup

        padding: Theme.componentMargin
        focus: true

        colorBorder: control.colorBackgroundBorder
        closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent

        onAboutToShow: {
            control.popup.close()
            menuPopup.close()
        }
        onOpened: searchField.forceActiveFocus()

        contentItem: TextFieldThemed {
            id: searchField

            rightPadding: clearButton.visible ? height : leftPadding
            placeholderText: control.searchPlaceholderText
            inputMethodHints: Qt.ImhNoPredictiveText

            Accessible.name: control.searchPlaceholderText

            onTextEdited: control.searchTextEdited()
            onAccepted: {
                searchPopup.close()
                control.searchAccepted()
            }

            T.Button {
                id: clearButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: searchField.height
                height: searchField.height

                visible: (searchField.length > 0)
                focusPolicy: Qt.NoFocus
                hoverEnabled: Theme.isDesktop

                Accessible.name: qsTr("Clear")

                onClicked: {
                    searchField.clear()
                    searchField.forceActiveFocus()
                    control.searchTextEdited()
                }

                contentItem: Item {
                    IconSvg {
                        anchors.centerIn: parent
                        width: Math.round(clearButton.height * 0.6)
                        height: width

                        source: "qrc:/IconLibrary/material-symbols/close.svg"
                        color: clearButton.hovered ? Theme.colorPrimary : searchField.colorPlaceholderText
                    }
                }
            }
        }
    }

    ////////////////

    // A square icon button along the bar end, toggling one of its popups.
    component BarButton: T.Button {
        id: barButton

        required property T.Popup target
        property url source
        property bool active: target.visible

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height

        focusPolicy: Qt.NoFocus
        hoverEnabled: Theme.isDesktop

        onClicked: target.visible ? target.close() : target.open()

        background: Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            anchors.bottomMargin: 1

            opacity: control.enabled ? 1 : 0.66
            color: (barButton.down || barButton.target.visible) ? Theme.colorComponentDown : "transparent"
        }

        contentItem: Item {
            IconSvg {
                anchors.centerIn: parent
                width: UtilsNumber.alignTo(barButton.height * 0.5, 2)
                height: width

                opacity: control.enabled ? 1 : 0.66
                color: barButton.active ? Theme.colorPrimary : Theme.colorIcon
                Behavior on color { ColorAnimation { duration: Theme.animationSpeedFast } }

                source: barButton.source
            }
        }
    }

    BarButton {
        id: searchButton
        anchors.right: menuButton.visible ? menuButton.left : parent.right

        visible: control.searchButtonVisible
        target: searchPopup
        source: "qrc:/IconLibrary/material-symbols/search.svg"
        active: searchPopup.visible || (control.searchText.length > 0)

        Accessible.name: control.searchPlaceholderText
    }

    BarButton {
        id: menuButton
        anchors.right: parent.right

        visible: control.menuButtonVisible
        target: menuPopup
        source: control.menuSource
    }

    ////////////////
}
