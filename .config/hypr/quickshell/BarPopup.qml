pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root
    required property Item anchorItem
    readonly property var anchorWindow: anchorItem.QsWindow.window
    property bool open: false
    property int popupWidth: 360
    property Component content
    signal dismissed()

    PopupWindow {
        id: popup
        anchor.window: root.anchorWindow
        anchor.rect.x: root.anchorWindow
            ? Math.max(12, Math.min(root.anchorWindow.width - width - 12,
                root.anchorItem.mapToItem(root.anchorWindow.contentItem, root.anchorItem.width / 2, 0).x - width / 2)) : 12
        anchor.rect.y: Theme.height + 4
        implicitWidth: root.anchorWindow ? Math.min(root.popupWidth, root.anchorWindow.width - 24) : root.popupWidth
        implicitHeight: (loader.item as Item)?.implicitHeight ?? 1
        color: "transparent"
        visible: root.open
        onVisibleChanged: if (!visible && root.open) root.dismissed()

        Loader {
            id: loader
            anchors.fill: parent
            active: root.open
            focus: active
            Keys.onEscapePressed: root.dismissed()
            sourceComponent: root.content
        }
    }

    // Hyprland watches outside clicks globally, including other monitors and the bar.
    HyprlandFocusGrab {
        windows: [popup]
        active: root.open && popup.visible
        onCleared: if (root.open) root.dismissed()
    }
}
