import Quickshell
import Quickshell.Services.UPower
import QtQuick
import "AlertLogic.js" as Logic

Scope {
    id: root
    required property var battery
    required property bool available
    required property bool plugged
    PersistentProperties {
        id: remembered
        reloadableId: "battery-alerts"
        property bool low: false
        property bool critical: false
        property bool full: false
    }
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            const result = Logic.next(remembered, root.available, root.plugged,
                Math.round(root.battery.percentage * 100), root.battery.state === UPowerDeviceState.FullyCharged);
            remembered.low = result.state.low;
            remembered.critical = result.state.critical;
            remembered.full = result.state.full;
            for (const alert of result.alerts) {
                const full = alert === "full";
                const critical = alert === "critical";
                Quickshell.execDetached(["notify-send", "--app-name=Quickshell",
                    "--hint=string:x-dunst-stack-tag:quickshell-battery",
                    "--urgency=" + (full ? "normal" : "critical"),
                    "--expire-time=" + (full ? "15000" : "0"),
                    full ? "Battery full" : critical ? "Battery exhausted" : "Battery low",
                    full ? "You can unplug the cable" : critical ? "Shutdown imminent" : "Plug the cable!"]);
            }
        }
    }
}
