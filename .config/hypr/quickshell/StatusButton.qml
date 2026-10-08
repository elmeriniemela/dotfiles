import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    property string tooltip: ""
    property bool available: true
    property color textColor: Theme.foreground
    property color baseColor: "transparent"
    property int minimumWidth: 0
    property int tooltipDelay: 600
    signal clicked(var mouse)
    signal scrolled(var wheel)
    implicitWidth: Math.max(minimumWidth, content.implicitWidth + 10)
    implicitHeight: 26
    radius: 4
    color: mouse.pressed ? Qt.darker(baseColor.a ? baseColor : Theme.hover, 1.2)
        : mouse.containsMouse ? (baseColor.a ? Qt.lighter(baseColor, 1.12) : Theme.hover) : baseColor
    opacity: available ? 1 : 0.5
    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 4
        Image {
            visible: root.icon !== ""
            source: root.icon
            sourceSize.width: 16
            sourceSize.height: 16
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }
        Text {
            visible: root.text !== ""
            text: root.text
            color: root.textColor
            font.family: Theme.font
            font.pixelSize: 13
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: event => { if (root.available) root.clicked(event); }
        onWheel: event => { if (root.available) root.scrolled(event); }
    }
    ToolTip.visible: mouse.containsMouse && root.tooltip !== ""
    ToolTip.delay: root.tooltipDelay
    ToolTip.text: root.tooltip
}
