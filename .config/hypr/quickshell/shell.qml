import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    SystemClock { id: clock; precision: SystemClock.Minutes }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            color: "#20242c"

            Row {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                spacing: 4

                Repeater {
                    model: Hyprland.workspaces

                    Rectangle {
                        id: workspaceButton
                        required property var modelData
                        visible: modelData.id > 0 && modelData.monitor?.name === bar.screen.name
                        width: visible ? 30 : 0
                        height: 24
                        radius: 4
                        color: modelData.active ? "#89b4fa" : (mouse.containsMouse ? "#454b59" : "#303541")

                        Text {
                            anchors.centerIn: parent
                            text: workspaceButton.modelData.name
                            color: workspaceButton.modelData.active ? "#20242c" : "#e6e9ef"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            // Hyprland 0.55+ uses Lua dispatch commands.
                            onClicked: Quickshell.execDetached([
                                "hyprctl", "dispatch",
                                "hl.dsp.focus({ workspace = " + workspaceButton.modelData.id + " })"
                            ])
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                color: "#e6e9ef"
                font.pixelSize: 13
            }

            Text {
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                text: "Super + K  ·  Shortcuts"
                color: "#a6adbb"
                font.pixelSize: 12
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached([
                        "python3", Quickshell.env("HOME") + "/.config/hypr/keybindings.py"
                    ])
                }
            }
        }
    }
}
