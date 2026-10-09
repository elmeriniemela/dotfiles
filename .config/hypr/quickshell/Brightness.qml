pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

StatusButton {
    id: root
    required property var services
    property bool popupOpen: false
    property real wheelRemainder: 0
    visible: services.brightness >= 0 || services.temperature >= 0
    icon: "assets/display-brightness-symbolic.svg"
    text: services.brightness >= 0 ? services.brightness + "%" : "Display"
    tooltip: "Display brightness and color temperature · scroll to adjust brightness"
    onClicked: event => {
        if (event.button === Qt.LeftButton) popupOpen = !popupOpen;
    }
    onScrolled: event => {
        if (services.brightness < 0) return;
        wheelRemainder += event.angleDelta.y / 120;
        const steps = Math.trunc(wheelRemainder);
        if (steps) {
            wheelRemainder -= steps;
            services.adjustBrightness(steps);
        }
    }

    component DisplaySlider: Slider {
        id: control
        Layout.fillWidth: true
        implicitHeight: 28
        opacity: enabled ? 1 : 0.4
        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.availableWidth
            height: 4
            radius: 2
            color: Theme.surface
            Rectangle {
                width: parent.width * control.visualPosition
                height: parent.height
                radius: parent.radius
                color: Theme.accent
            }
        }
        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: 16; height: 16; radius: 8
            color: control.pressed ? Theme.accent : Theme.foreground
        }
    }

    BarPopup {
        anchorItem: root
        open: root.popupOpen
        popupWidth: 320
        onDismissed: root.popupOpen = false
        content: Rectangle {
            implicitHeight: controls.implicitHeight + 32
            color: Theme.background
            radius: 8
            border.color: Theme.surface
            // Consume clicks inside the panel without dismissing it.
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
            ColumnLayout {
                id: controls
                anchors { fill: parent; margins: 16 }
                spacing: 8
                focus: true
                Keys.onEscapePressed: root.popupOpen = false
                Text {
                    text: "Display"
                    color: Theme.foreground
                    font { family: Theme.font; pixelSize: 14; bold: true }
                }
                Text {
                    text: brightnessSlider.enabled ? "Brightness · " + Math.round(brightnessSlider.value) + "%" : "Backlight unavailable"
                    color: Theme.foreground
                    font { family: Theme.font; pixelSize: 13 }
                }
                DisplaySlider {
                    id: brightnessSlider
                    objectName: "brightnessSlider"
                    from: 1; to: 100; stepSize: 1
                    enabled: root.services.brightness >= 0
                    Accessible.name: "Brightness"
                    Binding on value {
                        value: Math.max(1, root.services.brightness)
                        when: !brightnessSlider.pressed
                        restoreMode: Binding.RestoreNone
                    }
                    onMoved: root.services.setBrightness(value)
                }
                Text {
                    text: temperatureSlider.enabled
                        ? "Color temperature · " + Math.round(temperatureSlider.value) + " K" : "Color temperature unavailable"
                    color: Theme.foreground
                    font { family: Theme.font; pixelSize: 13 }
                }
                DisplaySlider {
                    id: temperatureSlider
                    objectName: "temperatureSlider"
                    from: 1000; to: 6500; stepSize: 100
                    enabled: root.services.temperature >= 0
                    Accessible.name: "Color temperature"
                    Binding on value {
                        value: Math.max(1000, root.services.temperature)
                        when: !temperatureSlider.pressed
                        restoreMode: Binding.RestoreNone
                    }
                    onMoved: root.services.setTemperature(value)
                }
                RowLayout {
                    Text { text: "Warm"; color: Theme.muted; font { family: Theme.font; pixelSize: 11 } }
                    Item { Layout.fillWidth: true }
                    Text { text: "Neutral"; color: Theme.muted; font { family: Theme.font; pixelSize: 11 } }
                }
            }
        }
    }
}
