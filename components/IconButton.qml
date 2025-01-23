import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

Item {
    id: iconButton
    width: 50
    height: 50

    // IconButton properties
    property string buttonIcon: "\ue900"    // Icon Unicode
    property string buttonText: "Menu"      // Tooltip text
    property color iconColor: "#BDC3C7"     // Default icon color
    property color hoverBackground: "white" // Background color on hover
    property color hoverIconColor: "#2C3E50" // Icon color on hover
    property color backgroundColor: "transparent" // Default background color
    property bool isActive: false           // Whether the button is active
    property color activeBackground: "#3E4E6F" // Background color when active
    property color activeIconColor: "#FFFFFF"  // Icon color when active

    // Signal for click handling
    signal clicked()

    // Shadow Effect for active state
    Rectangle {
        id: shadow
        width: parent.width
        height: parent.height
        radius: background.radius
        color: "black"
        opacity: isActive ? 0.2 : 0.0
        anchors.centerIn: parent
        z: -1
    }

    // Background
    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: isActive ? activeBackground : (mouseArea.containsMouse ? hoverBackground : backgroundColor)
        radius: 8
        border.color: isActive ? "#5A6B8C" : (mouseArea.containsMouse ? "#E0E0E0" : "transparent")
        border.width: isActive ? 2 : 1
    }

    // Icon
    Text {
        id: icon
        text: buttonIcon
        font.family: iconFont.name
        font.pixelSize: 32
        color: isActive ? activeIconColor : (mouseArea.containsMouse ? hoverIconColor : iconColor)
        anchors.centerIn: parent
    }

    // Tooltip
    Rectangle {
        id: tooltip
        width: 120
        height: 30
        color: "white"
        radius: 4
        border.color: "#E0E0E0"
        opacity: mouseArea.containsMouse ? 1.0 : 0.0
        visible: mouseArea.containsMouse
        z: 10

        Text {
            text: buttonText
            font.pixelSize: 14
            color: "#2C3E50"
            anchors.centerIn: parent
        }

        // Position the tooltip to the right of the button
        anchors {
            left: background.right
            leftMargin: 10
            verticalCenter: background.verticalCenter
        }
    }

    // Mouse Area for hover and click
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            iconButton.clicked() // Emit the clicked signal
        }
    }

    FontLoader {
        id: iconFont
        source: "../assets/fonts/keenicons-outline.ttf"
    }
}
