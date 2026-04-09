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
                model: captureItem.availableAppIds
                delegate: Button {
                    text: modelData
                    highlighted: modelData === captureItem.appId
                    onClicked: captureItem.appId = modelData
                }
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
        active: true

        layer.enabled: true
        layer.smooth: true
    }
}
