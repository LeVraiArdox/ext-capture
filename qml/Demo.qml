import QtQuick
import QtQuick.Controls
import Sleex.ExtCapture

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "ExtCapture Demo"
    color: "#111"

    Column {
        id: controls
        anchors { top: parent.top; left: parent.left; margins: 16 }
        spacing: 8
        z: 10

        Text { text: "app_id:"; color: "#fff"; font.pixelSize: 13 }

        Row {
            spacing: 6
            Repeater {
                model: ["firefox", "foot", "kitty", "code", "org.kde.dolphin"]
                delegate: Button {
                    text: modelData
                    highlighted: modelData === captureItem.appId
                    onClicked: captureItem.appId = modelData
                }
            }
        }

        Row {
            spacing: 8
            Switch {
                id: activeSwitch
                text: "Active"
                checked: false
                onCheckedChanged: captureItem.active = checked
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: captureItem.running ? "● live" : "○ idle"
                color: captureItem.running ? "#4f4" : "#888"
                font.pixelSize: 13
            }
        }
    }

    ExtCaptureItem {
        id: captureItem

        anchors {
            top: controls.bottom
            topMargin: 16
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 16
        }

        appId: "firefox" // Default app_id to capture
        active: activeSwitch.checked

        layer.enabled: true
        layer.smooth: true

        // Dim when not running
        opacity: running ? 1.0 : 0.3
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Text {
        anchors.centerIn: captureItem
        visible: !captureItem.running
        text: "Select an app_id and toggle Active"
        color: "#666"
        font.pixelSize: 18
    }
}
