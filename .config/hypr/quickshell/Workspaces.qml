import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root
    required property string monitorName
    spacing: 4
    Repeater {
        model: Hyprland.workspaces.values.filter(w => w.id > 0 && w.monitor?.name === root.monitorName)
            .sort((a, b) => a.id - b.id)
        StatusButton {
            required property var modelData
            minimumWidth: 30
            text: modelData.name
            textColor: modelData.active ? Theme.background : modelData.urgent ? Theme.urgent : Theme.foreground
            baseColor: modelData.active ? Theme.accent : modelData.urgent ? Theme.surface : "transparent"
            tooltip: "Workspace " + modelData.name + "\nClick to switch · Super + click to send window"
            onClicked: event => {
                if (event.button !== Qt.LeftButton) return;
                const action = event.modifiers & Qt.MetaModifier
                    ? "hl.dsp.window.move({ workspace = " + modelData.id + ", follow = false })"
                    : "hl.dsp.focus({ workspace = " + modelData.id + " })";
                Quickshell.execDetached(["hyprctl", "dispatch", action]);
            }
        }
    }
}
