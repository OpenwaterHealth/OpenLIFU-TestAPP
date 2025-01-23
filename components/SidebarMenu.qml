import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

Rectangle {
    id: sidebarMenu
    width: 60
    height: parent.height
    radius: 0
    color: "#2C3E50" // Dark sidebar background

    // Current active button index
    property int activeButtonIndex: 0

    signal buttonClicked(int index)

    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        Layout.alignment: Qt.AlignVCenter

        // Demo Button
        IconButton {
            buttonIcon: "\ueb34"
            buttonText: "Demo"
            Layout.alignment: Qt.AlignHCenter
            backgroundColor: sidebarMenu.activeButtonIndex === 0 ? "white" : "transparent"
            iconColor: sidebarMenu.activeButtonIndex === 0 ? "#2C3E50" : "#BDC3C7"
            onClicked: {
                sidebarMenu.activeButtonIndex = 0
                sidebarMenu.buttonClicked(0)
            }
        }

        // Test Button
        IconButton {
            buttonIcon: "\ueab9"
            buttonText: "Test"
            Layout.alignment: Qt.AlignHCenter
            backgroundColor: sidebarMenu.activeButtonIndex === 1 ? "white" : "transparent"
            iconColor: sidebarMenu.activeButtonIndex === 1 ? "#2C3E50" : "#BDC3C7"
            onClicked: {
                sidebarMenu.activeButtonIndex = 1
                sidebarMenu.buttonClicked(1)
            }
        }

        // Console Button
        IconButton {
            buttonIcon: "\uea51"
            buttonText: "Console"
            Layout.alignment: Qt.AlignHCenter
            backgroundColor: sidebarMenu.activeButtonIndex === 2 ? "white" : "transparent"
            iconColor: sidebarMenu.activeButtonIndex === 2 ? "#2C3E50" : "#BDC3C7"
            onClicked: {
                sidebarMenu.activeButtonIndex = 2
                sidebarMenu.buttonClicked(2)
            }
        }

        // Settings Button
        IconButton {
            buttonIcon: "\ueabf"
            buttonText: "Settings"
            Layout.alignment: Qt.AlignHCenter
            backgroundColor: sidebarMenu.activeButtonIndex === 3 ? "white" : "transparent"
            iconColor: sidebarMenu.activeButtonIndex === 3 ? "#2C3E50" : "#BDC3C7"
            onClicked: {
                sidebarMenu.activeButtonIndex = 3
                sidebarMenu.buttonClicked(3)
            }
        }
    }
}
