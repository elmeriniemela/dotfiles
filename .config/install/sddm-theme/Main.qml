import QtQuick 2.15

Rectangle {
    id: root

    width: 1920
    height: 1080
    color: "#0c1220"

    property color ink: "#f3f5f9"
    property color muted: "#9aa9bd"
    property color accent: "#8ce7d0"
    property bool busy: false
    property string message: ""

    function login() {
        if (busy) return
        if (!username.text.trim()) {
            message = qsTr("Enter your username")
            username.forceActiveFocus()
            return
        }
        message = qsTr("Touch the reader. Password fallback takes up to 10 seconds.")
        busy = true
        sddm.login(username.text.trim(), password.text, sessions.currentIndex)
    }

    Connections {
        target: sddm
        function onInformationMessage(message) {
            if (root.busy) root.message = message
        }
        function onLoginFailed() {
            root.busy = false
            password.text = ""
            root.message = qsTr("Sign-in failed. Try again with your fingerprint or password.")
            password.forceActiveFocus()
        }
    }

    // Soft light, drawn by Qt so the theme needs no image files.
    Rectangle {
        width: Math.max(root.width * 0.62, 650)
        height: width
        x: -width * 0.35
        y: -height * 0.48
        radius: width / 2
        opacity: 0.45
        gradient: Gradient {
            GradientStop { position: 0; color: "#275b66" }
            GradientStop { position: 1; color: "#0c1220" }
        }
    }

    Rectangle {
        width: Math.max(root.width * 0.48, 530)
        height: width
        x: root.width - width * 0.53
        y: root.height - height * 0.55
        radius: width / 2
        opacity: 0.34
        gradient: Gradient {
            GradientStop { position: 0; color: "#304b82" }
            GradientStop { position: 1; color: "#0c1220" }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#253347"
        border.width: 1
    }

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 48
        text: "NOCTURNE"
        color: root.muted
        font.family: "Inter"
        font.pixelSize: 14
        font.letterSpacing: 3
    }

    Column {
        id: clockBlock
        width: Math.min(root.width - 48, 620)
        anchors.left: parent.left
        anchors.leftMargin: Math.max(48, root.width * 0.09)
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -12
        spacing: 12
        visible: root.width >= 1000

        Text {
            id: clock
            color: root.ink
            font.family: "Inter"
            font.weight: Font.Light
            font.pixelSize: Math.min(116, root.width * 0.07)
            text: Qt.formatTime(new Date(), "HH:mm")
        }

        Rectangle { width: 56; height: 3; radius: 2; color: root.accent }

        Text {
            id: date
            color: root.muted
            font.family: "Inter"
            font.pixelSize: 20
            text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
        }

        Timer {
            interval: 1000
            repeat: true
            running: true
            onTriggered: {
                clock.text = Qt.formatTime(new Date(), "HH:mm")
                date.text = Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
            }
        }
    }

    Rectangle {
        id: card
        width: Math.min(420, root.width - 40)
        height: 454
        x: root.width >= 1000 ? root.width - width - Math.max(64, root.width * 0.11) : (root.width - width) / 2
        y: (root.height - height) / 2
        radius: 22
        color: "#e60f192b"
        border.color: "#3b4d61"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 36
            spacing: 0

            Text {
                text: qsTr("WELCOME BACK")
                color: root.accent
                font.family: "Inter"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                font.letterSpacing: 2.5
            }

            Item { width: 1; height: 12 }

            Text {
                text: qsTr("Sign in")
                color: root.ink
                font.family: "Inter"
                font.pixelSize: 32
                font.weight: Font.DemiBold
            }

            Item { width: 1; height: 28 }

            Text {
                text: qsTr("USERNAME")
                color: root.muted
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Item { width: 1; height: 9 }

            Rectangle {
                width: parent.width
                height: 52
                radius: 10
                color: "#152238"
                border.color: username.activeFocus ? root.accent : "#34465a"

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.margins: 15
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.ink
                    selectionColor: "#37796f"
                    font.family: "Inter"
                    font.pixelSize: 16
                    text: userModel.lastUser || ""
                    selectByMouse: true
                    readOnly: root.busy
                    KeyNavigation.tab: password
                    Keys.onReturnPressed: password.forceActiveFocus()
                    Keys.onEnterPressed: password.forceActiveFocus()
                    onTextChanged: root.message = ""
                }
            }

            Item { width: 1; height: 20 }

            Text {
                text: qsTr("PASSWORD")
                color: root.muted
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Item { width: 1; height: 9 }

            Rectangle {
                width: parent.width
                height: 52
                radius: 10
                color: "#152238"
                border.color: password.activeFocus ? root.accent : "#34465a"

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.margins: 15
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.ink
                    selectionColor: "#37796f"
                    font.family: "Inter"
                    font.pixelSize: 16
                    echoMode: TextInput.Password
                    selectByMouse: true
                    readOnly: root.busy
                    KeyNavigation.tab: signIn
                    Keys.onReturnPressed: root.login()
                    Keys.onEnterPressed: root.login()
                    onTextChanged: root.message = ""
                }
            }

            Item { width: 1; height: 12 }

            Text {
                width: parent.width
                height: 44
                color: root.busy || !root.message ? root.muted : "#ffb7ba"
                text: root.message || qsTr("Leave password empty and sign in to use your fingerprint.")
                font.family: "Inter"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                id: signIn
                width: parent.width
                height: 50
                radius: 10
                color: root.busy ? "#5a9187" : "#8ce7d0"

                Text {
                    anchors.centerIn: parent
                    text: root.busy ? qsTr("Signing in…") : qsTr("Sign in  →")
                    color: "#0c2427"
                    font.family: "Inter"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                MouseArea { anchors.fill: parent; onClicked: root.login() }
                Keys.onReturnPressed: root.login()
                Keys.onEnterPressed: root.login()
                KeyNavigation.tab: username
            }
        }

        Component.onCompleted: {
            if (username.text) password.forceActiveFocus()
            else username.forceActiveFocus()
        }
    }

    Row {
        id: actions
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 46
        spacing: 28

        Text {
            text: qsTr("Suspend")
            color: root.muted
            visible: sddm.canSuspend
            font.family: "Inter"
            font.pixelSize: 14
            MouseArea { anchors.fill: parent; onClicked: sddm.suspend() }
        }
        Text {
            text: qsTr("Restart")
            color: root.muted
            visible: sddm.canReboot
            font.family: "Inter"
            font.pixelSize: 14
            MouseArea { anchors.fill: parent; onClicked: sddm.reboot() }
        }
        Text {
            text: qsTr("Shut down")
            color: root.muted
            visible: sddm.canPowerOff
            font.family: "Inter"
            font.pixelSize: 14
            MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() }
        }
    }

    Item {
        id: sessionPicker
        width: 240
        height: 36
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 38

        ListView {
            id: sessions
            anchors.fill: parent
            model: sessionModel
            currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
            visible: false
            delegate: Item { property string sessionName: name; width: 1; height: 1 }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Session: ") + (sessions.currentItem ? sessions.currentItem.sessionName : qsTr("Desktop")) + "  ⌄"
            color: root.muted
            font.family: "Inter"
            font.pixelSize: 14
            MouseArea { anchors.fill: parent; onClicked: sessionMenu.visible = !sessionMenu.visible }
        }

        Rectangle {
            id: sessionMenu
            width: 240
            height: Math.min(sessionModel.count * 40 + 12, 172)
            anchors.left: parent.left
            anchors.bottom: parent.top
            anchors.bottomMargin: 8
            radius: 10
            color: "#19283a"
            border.color: "#405469"
            visible: false

            ListView {
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                model: sessionModel
                delegate: Item {
                    width: ListView.view.width
                    height: 40
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                        color: index === sessions.currentIndex ? root.accent : root.ink
                        font.family: "Inter"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            sessions.currentIndex = index
                            sessionMenu.visible = false
                        }
                    }
                }
            }
        }
    }
}
