pragma ComponentBehavior: Bound
import QtQuick

StatusButton {
    id: root
    required property var date
    property bool calendarOpen: false
    text: Qt.formatDateTime(date, "ddd d MMM  HH:mm")
    onClicked: event => {
        if (event.button === Qt.LeftButton) calendarOpen = !calendarOpen;
    }

    BarPopup {
        anchorItem: root
        open: root.calendarOpen
        popupWidth: 350
        onDismissed: root.calendarOpen = false
        content: Calendar {
            date: root.date
            onDismissed: root.calendarOpen = false
        }
    }
}
