pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    required property Item anchorItem
    readonly property var anchorWindow: anchorItem.QsWindow.window
    property bool open: false
    property int popupWidth: 360
    property Component content
    signal dismissed()

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: overlay
            required property var modelData
            readonly property bool popupScreen: modelData === root.anchorWindow?.screen
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            visible: root.open
            WlrLayershell.layer: WlrLayer.Overlay
            // All monitors must participate: Hyprland routes pointer input through
            // exclusive layers before considering other windows or layers.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            Item {
                anchors.fill: parent
                focus: root.open
                Keys.onEscapePressed: root.dismissed()

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons
                    onPressed: root.dismissed()
                }
                Loader {
                    active: root.open && overlay.popupScreen
                    width: Math.min(root.popupWidth, parent.width - 24)
                    height: (item as Item)?.implicitHeight ?? 0
                    x: Math.max(12, Math.min(parent.width - width - 12,
                        root.anchorWindow
                            ? root.anchorItem.mapToItem(root.anchorWindow.contentItem, root.anchorItem.width / 2, 0).x - width / 2 : 12))
                    y: Theme.height + 4
                    sourceComponent: root.content
                }
            }
        }
    }
}
