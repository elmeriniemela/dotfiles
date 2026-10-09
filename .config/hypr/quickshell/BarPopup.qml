pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    required property Item anchorItem
    property bool open: false
    property int popupWidth: 360
    property Component content
    signal dismissed()

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: overlay
            required property var modelData
            readonly property var anchorWindow: root.anchorItem.QsWindow.window
            readonly property bool popupScreen: modelData === anchorWindow?.screen
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: root.open
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: popupScreen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: root.dismissed()
            }
            Loader {
                active: root.open && overlay.popupScreen
                width: Math.min(root.popupWidth, parent.width - 24)
                x: Math.max(12, Math.min(parent.width - width - 12,
                    overlay.anchorWindow
                        ? root.anchorItem.mapToItem(overlay.anchorWindow.contentItem, root.anchorItem.width / 2, 0).x - width / 2 : 12))
                y: Theme.height + 4
                focus: active
                Keys.onEscapePressed: root.dismissed()
                sourceComponent: root.content
            }
        }
    }
}
