import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Row {
    spacing: 2
    Repeater {
        model: SystemTray.items
        StatusButton {
            id: item
            required property var modelData
            visible: modelData.status !== Status.Passive
            icon: modelData.icon
            tooltip: modelData.tooltipTitle + (modelData.tooltipDescription ? "\n" + modelData.tooltipDescription : "")
            onClicked: event => {
                // nm-applet exports a menu but neither Activate nor the menu-only flag.
                const menuOnly = modelData.onlyMenu || modelData.id === "nm-applet";
                if (event.button === Qt.RightButton || (event.button === Qt.LeftButton && menuOnly)) {
                    if (modelData.hasMenu) menu.open();
                } else if (event.button === Qt.MiddleButton) modelData.secondaryActivate();
                else if (event.button === Qt.LeftButton) modelData.activate();
            }
            onScrolled: event => modelData.scroll(event.angleDelta.y || event.angleDelta.x, event.angleDelta.y === 0)
            QsMenuAnchor {
                id: menu
                menu: item.modelData.menu
                anchor.item: item
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
        }
    }
}
