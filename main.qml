import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

import "components"
import "pages"

Window {
    id: window
    visible: true
    width: 1200
    height: 800
    flags: Qt.FramelessWindowHint | Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint // Ensure it appears in the taskbar
    color: "transparent" // Make the window background transparent to apply rounded corners

    Rectangle {
        anchors.fill: parent
        color: "#1C1C1E" // Main background color
        radius: 20 // Rounded corners
        border.color: "transparent"

        // Properties
        property int activeButtonIndex: 0 // Define activeButtonIndex here

        // Header Section (with drag functionality)
        Rectangle {
            height: 60 // Increased header size
            color: "#1E1E20"
            radius: 20
            Layout.fillWidth: true
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            MouseArea {
                id: headerMouseArea
                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor
                onPressed: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        // Start the system move to allow dragging
                        window.startSystemMove(); 
                    }
                }
            }

            // Left side: Logo and Title
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                anchors.topMargin: 10
                anchors.rightMargin: 15
                anchors.bottomMargin: 10
                anchors.leftMargin: 15

                // Logo placeholder
                Rectangle {
                    width: 32
                    height: 32
                    color: "#3E4E6F"
                    radius: 6
                    Text {
                        text: "L" // Placeholder for logo text
                        color: "white"
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }
                }

                // Application title
                Text {
                    text: "OpenLIFU Engineering App"
                    color: "white"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
            }

            // Minimize, Maximize, Exit Buttons
            RowLayout {
                anchors.top: parent.top
                anchors.right: parent.right
                spacing: 10
                anchors.topMargin: 10
                anchors.rightMargin: 15
                anchors.bottomMargin: 10
                anchors.leftMargin: 15


                // Minimize Button
                IconWindowButton {
                    buttonIcon: "\ue9e4" // Minimize icon
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        window.showMinimized()
                    }
                }

                // Maximize Button
                IconWindowButton {
                    buttonIcon: "\ueb18" // Maximize icon
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        if (Window.visibility == Window.Maximized) {
                            window.showNormal(); // Restore to normal size
                        } else {
                            console.log("max")
                            window.showMaximized(); // Maximize the window
                        }                     
                    }
                }

                // Exit Button
                IconWindowButton {
                    buttonIcon: "\ue9b3" // Exit (close) icon
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        Qt.quit(); // Close the application
                    }
                }
            }
        }

        // Layout for Sidebar and Main Content
        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 60
            anchors.rightMargin: 15
            anchors.bottomMargin: 15
            anchors.leftMargin: 15
            spacing: 20
            Layout.fillHeight: true

            // Sidebar
            Rectangle {
                width: 80
                color: "#2C2C2E"
                radius: 10
                Layout.fillHeight: true

                // Sidebar
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 10

                    // Demo Button
                    IconButton {
                        buttonIcon: "\ueb34" // Demo icon
                        buttonText: "Demo"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            console.log("Demo clicked");
                        }
                    }

                }
            }

            // Main Content
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20

                    // Left Panel (Navigation/Map)
                    Rectangle {
                        color: "#29292B"
                        radius: 20
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        opacity: 0.9
                    }
                }
            }
        }
    }
}
