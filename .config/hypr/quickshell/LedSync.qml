import Quickshell
import Quickshell.Io

Scope {
    id: root
    required property string device
    property var muted: null
    property int pending: -1
    onMutedChanged: {
        if (muted !== null) {
            pending = muted ? 1 : 0;
            flush();
        }
    }
    function flush() {
        if (writer.running || pending < 0) return;
        const value = pending;
        pending = -1;
        writer.exec(["timeout", "3", "brightnessctl", "--device=" + device, "set", String(value)]);
    }
    Process {
        id: writer
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: Qt.callLater(root.flush)
    }
}
