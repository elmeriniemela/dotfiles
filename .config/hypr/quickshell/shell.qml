import Quickshell
import QtQuick

ShellRoot {
    Services { id: sharedServices }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.height
            color: Theme.background

            Item {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                width: Math.max(0, Math.min(workspaces.implicitWidth, (bar.width - clock.width) / 2 - 20))
                height: Theme.height
                clip: true
                Workspaces {
                    id: workspaces
                    anchors.verticalCenter: parent.verticalCenter
                    monitorName: bar.screen.name
                }
            }
            Clock {
                id: clock
                anchors.centerIn: parent
                date: sharedServices.date
            }
            Item {
                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                width: Math.max(0, Math.min(indicators.implicitWidth, (bar.width - clock.width) / 2 - 20))
                height: Theme.height
                clip: true
                Indicators {
                    id: indicators
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    services: sharedServices
                }
            }
        }
    }
}
