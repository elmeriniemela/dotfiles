import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick

Scope {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery.ready && battery.isPresent && battery.isLaptopBattery
    readonly property bool plugged: !UPower.onBattery
    readonly property int batteryPercent: Math.round(battery.percentage * 100)
    property int brightness: -1
    property string brightnessError: "Backlight unavailable"
    property int brightnessSteps: 0
    property int brightnessTarget: -1
    property int temperature: -1
    property int temperatureTarget: -1
    property var paused: null
    property string notificationError: "Dunst unavailable"
    readonly property bool notificationBusy: notificationAction.running
    property bool recording: false

    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property date date: clock.date
    PwObjectTracker { objects: [root.sink, root.source] }
    LedSync { device: "platform::mute"; muted: root.sink?.ready ? root.sink.audio?.muted ?? null : null }
    LedSync { device: "platform::micmute"; muted: root.source?.ready ? root.source.audio?.muted ?? null : null }

    function adjustBrightness(steps) {
        if (brightnessTarget >= 0) {
            setBrightness(brightnessTarget + steps);
            return;
        }
        brightnessSteps += steps;
        flushBrightness();
    }
    function setBrightness(value) {
        brightnessTarget = Math.max(1, Math.min(100, Math.round(value)));
        brightness = brightnessTarget;
        brightnessSteps = 0;
        if (!brightnessThrottle.running) brightnessThrottle.start();
    }
    Timer { id: brightnessThrottle; interval: 50; onTriggered: root.flushBrightness() }
    function flushBrightness() {
        if (brightnessWrite.running) return;
        if (brightnessTarget >= 0) {
            const target = brightnessTarget;
            brightnessTarget = -1;
            brightnessWrite.exec(["timeout", "3", "brightnessctl", "--device=intel_backlight", "set", target + "%"]);
            return;
        }
        if (brightnessSteps === 0) return;
        const steps = brightnessSteps;
        brightnessSteps = 0;
        brightnessWrite.exec(["timeout", "3", "brightnessctl", "--device=intel_backlight", "set",
            String(Math.abs(steps)) + (steps > 0 ? "%+" : "%-")]);
    }
    Process {
        id: brightnessRead
        command: ["timeout", "3", "brightnessctl", "--device=intel_backlight", "-m"]
        stdout: StdioCollector { id: brightnessOutput }
        stderr: StdioCollector { id: brightnessStderr }
        onExited: (code, status) => {
            if (brightnessWrite.running || root.brightnessTarget >= 0 || root.brightnessSteps !== 0) return;
            const match = brightnessOutput.text.match(/,(\d+)%,/);
            root.brightness = code === 0 && match ? Number(match[1]) : -1;
            root.brightnessError = brightnessStderr.text.trim() || "Backlight unavailable";
        }
    }
    Process {
        id: brightnessWrite
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (code, status) => {
            if (code !== 0) root.brightnessError = "Could not adjust backlight";
            Qt.callLater(() => {
                root.flushBrightness();
                if (!brightnessWrite.running && !brightnessRead.running) brightnessRead.running = true;
            });
        }
    }
    function setTemperature(value) {
        temperatureTarget = Math.max(1000, Math.min(6500, Math.round(value / 100) * 100));
        temperature = temperatureTarget;
        if (!temperatureThrottle.running) temperatureThrottle.start();
    }
    Timer { id: temperatureThrottle; interval: 50; onTriggered: root.flushTemperature() }
    function flushTemperature() {
        if (temperatureWrite.running || temperatureTarget < 0) return;
        const target = temperatureTarget;
        temperatureTarget = -1;
        temperatureWrite.exec(target === 6500
            ? ["timeout", "3", "hyprctl", "hyprsunset", "identity"]
            : ["timeout", "3", "hyprctl", "hyprsunset", "temperature", String(target)]);
    }
    Process {
        id: temperatureRead
        command: ["sh", "-c", "timeout 3 hyprctl hyprsunset temperature && timeout 3 hyprctl hyprsunset identity get"]
        stdout: StdioCollector { id: temperatureOutput }
        stderr: StdioCollector {}
        onExited: (code, status) => {
            if (temperatureWrite.running || root.temperatureTarget >= 0) return;
            const values = temperatureOutput.text.trim().split(/\s+/);
            const kelvin = Number(values[0]);
            root.temperature = code === 0 && values.length === 2 && kelvin >= 1000 && kelvin <= 20000
                && (values[1] === "true" || values[1] === "false")
                ? (values[1] === "true" ? 6500 : kelvin) : -1;
        }
    }
    Process {
        id: temperatureWrite
        stdout: StdioCollector { id: temperatureResult }
        stderr: StdioCollector {}
        onExited: (code, status) => {
            if (code !== 0 || temperatureResult.text.trim() !== "ok") root.temperature = -1;
            Qt.callLater(() => {
                root.flushTemperature();
                if (!temperatureWrite.running && !temperatureRead.running) temperatureRead.running = true;
            });
        }
    }
    Process {
        id: notificationRead
        command: ["timeout", "3", "dunstctl", "is-paused"]
        stdout: StdioCollector { id: notificationOutput }
        stderr: StdioCollector { id: notificationStderr }
        onExited: (code, status) => {
            const value = notificationOutput.text.trim();
            root.paused = code === 0 && (value === "true" || value === "false") ? value === "true" : null;
            root.notificationError = notificationStderr.text.trim() || "Dunst unavailable";
        }
    }
    function toggleNotifications() {
        if (paused === null || notificationAction.running || notificationRead.running) return;
        notificationAction.exec(paused
            ? ["sh", "-c", "timeout 3 dunstctl close-all && timeout 3 dunstctl set-paused false"]
            : ["timeout", "3", "dunstctl", "set-paused", "true"]);
    }
    Process {
        id: notificationAction
        stdout: StdioCollector {}
        stderr: StdioCollector { id: notificationActionError }
        onExited: (code, status) => {
            if (code !== 0) root.notificationError = notificationActionError.text.trim() || "Notification toggle failed";
            Qt.callLater(() => { if (!notificationRead.running) notificationRead.running = true; });
        }
    }
    Process {
        id: recordingRead
        command: ["pgrep", "-x", "wf-recorder"]
        stdout: StdioCollector {}
        onExited: (code, status) => root.recording = code === 0
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!brightnessRead.running && !brightnessWrite.running) brightnessRead.running = true;
            if (!temperatureRead.running && !temperatureWrite.running) temperatureRead.running = true;
            if (!notificationRead.running && !notificationAction.running) notificationRead.running = true;
            if (!recordingRead.running) recordingRead.running = true;
        }
    }
    BatteryAlerts { battery: root.battery; available: root.hasBattery; plugged: root.plugged }
}
