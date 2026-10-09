pragma ComponentBehavior: Bound
import QtQuick

StatusButton {
    id: root
    required property var services
    property bool popupOpen: false
    visible: services.hasBattery
    icon: services.plugged ? "assets/battery-full-charged-symbolic.svg" : "assets/battery-symbolic.svg"
    text: services.batteryPercent + "%"
    tooltip: (services.plugged ? "Connected to power" : "On battery") + " · click for battery details"
    onClicked: event => {
        if (event.button === Qt.LeftButton) popupOpen = !popupOpen;
    }
    onVisibleChanged: if (!visible) popupOpen = false

    BarPopup {
        anchorItem: root
        open: root.popupOpen
        onDismissed: root.popupOpen = false
        content: BatteryInfo { services: root.services; batteryIcon: root.icon }
    }
}
