import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

StatusButton {
    id: root
    required property var date
    property bool calendarOpen: false
    onCalendarOpenChanged: { if (calendarOpen) calendar.today(); }
    text: Qt.formatDateTime(date, "ddd d MMM  HH:mm")
    tooltip: calendarOpen ? "" : Qt.formatDateTime(date, "dddd, d MMMM yyyy")
    onClicked: event => {
        if (event.button !== Qt.LeftButton) return;
        calendarOpen = !calendarOpen;
    }

    PanelWindow {
        id: popup
        objectName: "calendarPopup"
        screen: root.QsWindow.window?.screen ?? null
        anchors { top: true; left: true }
        margins.top: Theme.height + 4
        margins.left: Math.max(0, (screen?.width ?? 350) / 2 - implicitWidth / 2)
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 350
        implicitHeight: calendar.implicitHeight + 24
        visible: root.calendarOpen
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: Theme.background
        // A focus grab dismisses the popup when another surface is clicked.
        HyprlandFocusGrab {
            active: root.calendarOpen
            windows: [popup]
            onCleared: root.calendarOpen = false
        }
        ColumnLayout {
            id: calendar
            anchors { fill: parent; margins: 12 }
            spacing: 10
            focus: root.calendarOpen
            Keys.onEscapePressed: root.calendarOpen = false
            property date selectedMonth: new Date()
            function today() { selectedMonth = new Date(root.date.getFullYear(), root.date.getMonth(), 1); }
            function shift(amount) { selectedMonth = new Date(selectedMonth.getFullYear(), selectedMonth.getMonth() + amount, 1); }
            RowLayout {
                Layout.fillWidth: true
                StatusButton { text: "‹"; tooltip: "Previous month"; onClicked: calendar.shift(-1) }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDateTime(calendar.selectedMonth, "MMMM yyyy")
                    color: Theme.foreground
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.bold: true
                }
                StatusButton { text: "›"; tooltip: "Next month"; onClicked: calendar.shift(1) }
            }
            GridLayout {
                columns: 2
                columnSpacing: 8
                rowSpacing: 8
                Item { Layout.preferredWidth: 24; Layout.preferredHeight: 22 }
                DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    locale: Qt.locale("fi_FI")
                    delegate: Text {
                        required property int index
                        text: Qt.locale().dayName(index + 1, Locale.ShortFormat)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 12
                    }
                }
                WeekNumberColumn {
                    month: calendar.selectedMonth.getMonth()
                    year: calendar.selectedMonth.getFullYear()
                    locale: Qt.locale("fi_FI")
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 180
                    delegate: Text {
                        required property var model
                        text: model.weekNumber
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MonthGrid {
                    id: monthGrid
                    month: calendar.selectedMonth.getMonth()
                    year: calendar.selectedMonth.getFullYear()
                    locale: Qt.locale("fi_FI")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    spacing: 4
                    delegate: Rectangle {
                        required property var model
                        radius: 4
                        color: model.today ? Theme.accent : "transparent"
                        opacity: model.month === monthGrid.month ? 1 : 0.3
                        Text {
                            anchors.centerIn: parent
                            text: parent.model.day
                            color: parent.model.today ? Theme.background : Theme.foreground
                            font.family: Theme.font
                            font.pixelSize: 13
                        }
                    }
                }
            }
            StatusButton { Layout.alignment: Qt.AlignHCenter; text: "Today"; onClicked: calendar.today() }
        }
    }
}
