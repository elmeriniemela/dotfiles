import Quickshell
import Quickshell.Wayland
import QtQuick

StatusButton {
    id: root
    required property var date
    property bool calendarOpen: false
    text: Qt.formatDateTime(date, "ddd d MMM  HH:mm")
    onClicked: event => {
        if (event.button === Qt.LeftButton) calendarOpen = !calendarOpen;
    }

    // Each monitor gets a transparent input layer while the calendar is open.
    // The calendar sits above it on the monitor containing this clock.
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: overlay
            required property var modelData
            readonly property bool calendarScreen: modelData === root.QsWindow.window?.screen
            objectName: "calendarDismissLayer"
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: root.calendarOpen
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: calendarScreen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            MouseArea {
                objectName: "calendarOutsideClick"
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: root.calendarOpen = false
            }
            Loader {
                anchors { top: parent.top; topMargin: Theme.height + 4; horizontalCenter: parent.horizontalCenter }
                active: root.calendarOpen && overlay.calendarScreen
                sourceComponent: Calendar {
                    date: root.date
                    onDismissed: root.calendarOpen = false
                }
            }
            Item {
                focus: root.calendarOpen && overlay.calendarScreen
                Keys.onEscapePressed: root.calendarOpen = false
            }
        }
    }
}
