pragma ComponentBehavior: Bound
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var services
    required property string batteryIcon
    readonly property var battery: services.battery
    readonly property var physicalBattery: UPower.devices.values.find(device => device.isLaptopBattery && device.isPresent) ?? battery
    readonly property string batteryPath: physicalBattery.nativePath ? "/sys/class/power_supply/" + physicalBattery.nativePath + "/" : ""
    readonly property bool holding: services.plugged && (
        battery.state === UPowerDeviceState.PendingCharge
        || (battery.state === UPowerDeviceState.FullyCharged && services.batteryPercent < 99)
        || (battery.state === UPowerDeviceState.Charging && endThreshold.value !== ""
            && Number(endThreshold.value) < 99 && services.batteryPercent >= Number(endThreshold.value) && watts <= 0.2))
    readonly property bool full: services.plugged && !holding && battery.state === UPowerDeviceState.FullyCharged
    readonly property string stateText: !services.plugged ? "On battery"
        : holding ? "Holding charge" : full ? "Fully charged"
        : battery.state === UPowerDeviceState.Charging ? "Charging" : "Connected to power"
    readonly property string chargeLimit: endThreshold.value
        ? (startThreshold.value && startThreshold.value !== endThreshold.value ? startThreshold.value + "–" : "") + endThreshold.value + "%" : "—"
    readonly property real watts: powerNow.value !== "" ? Number(powerNow.value) / 1000000 : battery.changeRate

    function duration(seconds) {
        if (!(seconds > 0)) return "—";
        const minutes = Math.max(1, Math.round(seconds / 60));
        const hours = Math.floor(minutes / 60);
        return hours ? hours + "h" + (minutes % 60 ? " " + minutes % 60 + "m" : "") : minutes + "m";
    }

    implicitHeight: details.implicitHeight + 32
    color: Theme.background
    radius: 8
    border.color: Theme.surface
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

    component BatteryValue: FileView {
        required property string field
        property string value: ""
        path: root.batteryPath ? root.batteryPath + field : ""
        preload: true
        printErrors: false
        onLoaded: value = text().trim()
        onLoadFailed: value = ""
    }
    BatteryValue { id: cycles; field: "cycle_count" }
    BatteryValue { id: startThreshold; field: "charge_control_start_threshold" }
    BatteryValue { id: endThreshold; field: "charge_control_end_threshold" }
    BatteryValue { id: powerNow; field: "power_now" }
    FileView {
        id: powerMode
        path: "/sys/firmware/acpi/platform_profile"
        preload: true
        printErrors: false
        property string value: ""
        onLoaded: {
            const mode = text().trim().replace(/-/g, " ");
            value = mode ? mode.charAt(0).toUpperCase() + mode.slice(1) : "";
        }
        onLoadFailed: value = ""
    }
    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: {
            cycles.reload(); startThreshold.reload(); endThreshold.reload(); powerNow.reload(); powerMode.reload();
        }
    }

    component InfoRow: RowLayout {
        required property string label
        required property string value
        Layout.fillWidth: true
        Text {
            text: parent.label
            color: Theme.foreground
            opacity: 0.65
            font { family: Theme.font; pixelSize: 13 }
        }
        Item { Layout.fillWidth: true }
        Text {
            text: parent.value
            color: Theme.foreground
            font { family: Theme.font; pixelSize: 13 }
        }
    }
    ColumnLayout {
        id: details
        anchors { fill: parent; margins: 16 }
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Image { source: root.batteryIcon; sourceSize.width: 32; sourceSize.height: 32 }
            ColumnLayout {
                spacing: 2
                Text { text: "Battery"; color: Theme.foreground; font { family: Theme.font; pixelSize: 16; bold: true } }
                Text { text: root.stateText; color: Theme.foreground; opacity: 0.65; font { family: Theme.font; pixelSize: 12 } }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.services.batteryPercent + "%"
                color: Theme.foreground
                font { family: Theme.font; pixelSize: 28; bold: true }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 6; radius: 3
            color: Theme.surface
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.battery.percentage))
                height: parent.height; radius: parent.radius
                color: root.services.batteryPercent <= 15 ? Theme.urgent : Theme.accent
            }
        }
        InfoRow { label: "Full capacity"; value: root.battery.energyCapacity > 0 ? root.battery.energyCapacity.toFixed(1) + " Wh" : "—" }
        InfoRow { label: "Charge cycles"; value: cycles.value && Number(cycles.value) >= 0 ? cycles.value : "—" }
        InfoRow {
            label: root.services.plugged ? "Time to full" : "Time remaining"
            value: root.holding || root.full ? "—" : root.duration(root.services.plugged ? root.battery.timeToFull : root.battery.timeToEmpty)
        }
        InfoRow { label: root.services.plugged ? "Charging rate" : "Power draw"; value: Number.isFinite(root.watts) ? Math.abs(root.watts).toFixed(1) + " W" : "—" }
        InfoRow { label: "Charge limit"; value: root.chargeLimit }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.surface }
        InfoRow { label: "Power mode"; value: powerMode.value || "—" }
    }
}
