import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

import "components"
import "pages"

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    flags: Qt.FramelessWindowHint | Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint // Ensure it appears in the taskbar
    color: "transparent" // Make the window background transparent to apply rounded corners
    //icon: "assets/images/favicon.png" // Set the application icon

    Rectangle {
        anchors.fill: parent
        color: "#1C1C1E" // Main background color
        radius: 20 // Rounded corners
        border.color: "transparent"

        // Properties
        property int activeButtonIndex: 0 // Define activeButtonIndex here

        // Header Section (with drag functionality)
        WindowMenu {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            // Set title and logo dynamically
            titleText: "Open-LIFU Engineering App"
            logoSource: "../assets/images/OpenwaterLogo.png" // Correct relative path
        }

        // Layout for Sidebar and Main Content
        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 65
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
