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
        onClicked: event => {
            if (event.button === Qt.LeftButton)
                Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/hypr/keybindings.py"]);
        }
    }
    StatusButton {
        icon: root.services.recording ? "assets/media-record-active-symbolic.svg" : "assets/media-record-symbolic.svg"
        text: "REC"
        tooltip: root.services.recording ? "Stop screen recording" : "Record a screen region"
        onClicked: event => {
            if (event.button === Qt.LeftButton)
                Quickshell.execDetached(["sh", Quickshell.env("HOME") + "/.config/hypr/screen-record.sh"]);
        }
    }
    StatusButton {
        visible: root.services.hasBattery
        icon: "assets/battery-full-charged-symbolic.svg"
        text: root.services.batteryPercent + "%" + (root.services.plugged ? " plug" : "")
        tooltip: UPowerDeviceState.toString(root.services.battery.state)
    }
    Brightness { services: root.services }
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
    StatusButton {
        icon: "assets/system-shutdown-symbolic.svg"
        tooltip: "Open logout menu"
        onClicked: event => {
            if (event.button === Qt.LeftButton)
                Quickshell.execDetached(["archlinux-logout"]);
        }
    }
}
