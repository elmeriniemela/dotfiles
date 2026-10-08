import Quickshell
import Quickshell.Services.UPower
import QtQuick

Row {
    id: root
    required property var services
    spacing: 4
    StatusButton {
        text: "Super + K"
        tooltip: "Show keyboard shortcuts"
        textColor: Theme.muted
        onClicked: event => {
            if (event.button === Qt.LeftButton)
                Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/hypr/keybindings.py"]);
        }
    }
    StatusButton {
        visible: root.services.hasBattery
        icon: "assets/battery-full-charged-symbolic.svg"
        text: root.services.batteryPercent + "%" + (root.services.plugged ? " plug" : "")
        textColor: !root.services.plugged && root.services.batteryPercent <= 15 ? Theme.urgent : Theme.foreground
        tooltip: UPowerDeviceState.toString(root.services.battery.state)
    }
    StatusButton {
        visible: root.services.brightness >= 0
        icon: "assets/display-brightness-symbolic.svg"
        text: root.services.brightness + "%"
        tooltip: "Laptop brightness · scroll to adjust by 1%"
        property real wheelRemainder: 0
        onScrolled: event => {
            wheelRemainder += event.angleDelta.y / 120;
            const steps = Math.trunc(wheelRemainder);
            if (steps) {
                wheelRemainder -= steps;
                root.services.adjustBrightness(steps);
            }
        }
    }
    StatusButton {
        readonly property var node: root.services.source
        available: !!node?.ready && !!node?.audio
        icon: available && node.audio.muted ? "assets/microphone-sensitivity-muted-symbolic.svg" : "assets/microphone-sensitivity-high-symbolic.svg"
        text: available ? Math.round(node.audio.volume * 100) + "%" : "—"
        tooltip: available ? (node.audio.muted ? "Microphone muted" : "Microphone") + " · click for input devices" : "No default microphone available"
        onClicked: event => { if (event.button === Qt.LeftButton) Quickshell.execDetached(["pwvucontrol", "--tab=3"]); }
    }
    StatusButton {
        readonly property var node: root.services.sink
        available: !!node?.ready && !!node?.audio
        icon: available && node.audio.muted ? "assets/audio-volume-muted-symbolic.svg" : "assets/audio-volume-medium-symbolic.svg"
        text: available ? Math.round(node.audio.volume * 100) + "%" : "—"
        tooltip: available ? (node.audio.muted ? "Output muted" : "Output volume") + " · click for output devices" : "No default audio output available"
        onClicked: event => { if (event.button === Qt.LeftButton) Quickshell.execDetached(["pwvucontrol", "--tab=4"]); }
    }
    StatusButton {
        available: root.services.paused !== null && !root.services.notificationBusy
        icon: root.services.paused ? "assets/notification-disabled-symbolic.svg" : "assets/notification-inactive-symbolic.svg"
        tooltip: root.services.paused === null ? root.services.notificationError
            : root.services.paused ? "Notifications muted · click to discard backlog and resume" : "Notifications enabled · click to mute"
        onClicked: event => { if (event.button === Qt.LeftButton) root.services.toggleNotifications(); }
    }
    Tray {}
}
