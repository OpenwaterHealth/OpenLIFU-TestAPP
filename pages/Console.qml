import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

import "../components"

Rectangle {
    id: page1
    width: parent.width
    height: parent.height
    color: "#29292B"
    radius: 20
    opacity: 0.95

    // Properties for dynamic data
    property string firmwareVersion: "N/A"
    property string deviceId: "N/A"
    property real temperature1: 0.0
    property real temperature2: 0.0

    // Run refresh logic immediately on page load if HV is already connected
    Component.onCompleted: {
        if (LIFUConnector.hvConnected) {
            console.log("Page Loaded - HV Already Connected. Fetching Info...")
            LIFUConnector.queryHvInfo()
            LIFUConnector.queryHvTemperature()
        }
    }

    Timer {
        id: infoTimer
        interval: 500   // Delay to ensure HV is stable before fetching info
        running: false
        onTriggered: {
            console.log("Fetching Firmware Version and Device ID...")
            LIFUConnector.queryHvInfo()
            LIFUConnector.queryHvTemperature()
        }
    }

    Connections {
        target: LIFUConnector

        // Handle HV Connected state
        function onHvConnectedChanged() {
            if (LIFUConnector.hvConnected) {
                infoTimer.start()          // One-time info fetch
            } else {
                console.log("HV Disconnected - Clearing Data...")
                firmwareVersion = "N/A"
                deviceId = "N/A"
                temperature1 = 0.0
                temperature2 = 0.0
            }
        }

        // Handle device info response
        function onHvDeviceInfoReceived(fwVersion, devId) {
            firmwareVersion = fwVersion
            deviceId = devId
        }

        // Handle temperature updates
        function onTemperatureHvUpdated(temp1, temp2) {
            temperature1 = temp1
            temperature2 = temp2
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Title
        Text {
            text: "LIFU Console Unit Tests"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1E1E20"
            radius: 10
            border.color: "#3E4E6F"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                // Vertical Stack Section
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.65
                    spacing: 10
                    
                    // Communication Tests Box
                    Rectangle {
                        width: 650
                        height: 195
                        radius: 6
                        color: "#1E1E20"
                        border.color: "#3E4E6F"
                        border.width: 2

                        // Title at Top-Center with 5px Spacing
                        Text {
                            text: "Communication Tests"
                            color: "#BDC3C7"
                            font.pixelSize: 18
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 5  // 5px spacing from the top
                        }

                        // Content for comms tests
                        GridLayout {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 20   
                            anchors.topMargin: 60    
                            columns: 5
                            rowSpacing: 10
                            columnSpacing: 10

                            // Row 1
                            // Ping Button and Result
                            Button {
                                id: pingButton
                                text: "Ping"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 50
                                hoverEnabled: true  // Enable hover detection

                                contentItem: Text {
                                    text: parent.text
                                    color: "#BDC3C7"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: pingButtonBackground
                                    color: pingButton.hovered ? "#4A90E2" : "#3A3F4B"  // Blue on hover
                                    radius: 4
                                    border.color: pingButton.hovered ? "#FFFFFF" : "#BDC3C7"  // White border on hover
                                }

                                onClicked: pingResult.text = "Ping Successful"
                            }
                            Text {
                                id: pingResult
                                Layout.preferredWidth: 80
                                text: ""
                                color: "#BDC3C7"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item {
                                Layout.preferredWidth: 200 
                            }

                            Button {
                                id: ledButton
                                text: "Toggle LED"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 50
                                hoverEnabled: true  // Enable hover detection

                                contentItem: Text {
                                    text: parent.text
                                    color: "#BDC3C7"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: ledButtonBackground
                                    color: ledButton.hovered ? "#4A90E2" : "#3A3F4B"  // Blue on hover
                                    radius: 4
                                    border.color: ledButton.hovered ? "#FFFFFF" : "#BDC3C7"  // White border on hover
                                }

                                onClicked: toggleLedResult.text = "LED Toggled"
                            }
                            Text {
                                id: toggleLedResult
                                Layout.preferredWidth: 80
                                color: "#BDC3C7"
                                text: ""
                            }

                            // Row 2
                            // Echo Button and Result
                            Button {
                                id: echoButton
                                text: "Echo"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 50
                                hoverEnabled: true  // Enable hover detection

                                contentItem: Text {
                                    text: parent.text
                                    color: "#BDC3C7"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: echoButtonBackground
                                    color: echoButton.hovered ? "#4A90E2" : "#3A3F4B"  // Blue on hover
                                    radius: 4
                                    border.color: echoButton.hovered ? "#FFFFFF" : "#BDC3C7"  // White border on hover
                                }

                                onClicked: echoResult.text = "Echo Successful"
                            }
                            Text {
                                id: echoResult
                                Layout.preferredWidth: 80
                                text: ""
                                color: "#BDC3C7"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item {
                                Layout.preferredWidth: 200 
                            }

                            ComboBox {
                                id: rgbLedDropdown
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                model: ["Off", "Red", "Green", "Blue"]
                                onActivated: rgbLedResult.text = rgbLedDropdown.currentText
                            }
                            Text {
                                id: rgbLedResult
                                Layout.preferredWidth: 80
                                color: "#BDC3C7"
                                text: "Off"
                            }
                        }
                    }

                    // Power Tests Box
                    Rectangle {
                        width: 650
                        height: 195
                        radius: 8
                        color: "#1E1E20"
                        border.color: "#3E4E6F"
                        border.width: 2

                        // Title at Top-Center with 5px Spacing
                        Text {
                            text: "Power Tests"
                            color: "#BDC3C7"
                            font.pixelSize: 18
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 5  // 5px spacing from the top
                        }
                        

                        // Content for comms tests
                        GridLayout {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 20
                            anchors.topMargin: 60
                            columns: 5
                            rowSpacing: 10
                            columnSpacing: 10


                            Text { text: "Voltage (+/-):"; color: "white" }
                            TextField { id: voltage; text: "12.0" }

                            Item {
                                Layout.preferredWidth: 200
                            }


                            Button {
                                id: v12Enable
                                text: "12V Enable"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 50
                                hoverEnabled: true  // Enable hover detection

                                contentItem: Text {
                                    text: parent.text
                                    color: "#BDC3C7"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: v12EnableButtonBackground
                                    color: v12Enable.hovered ? "#4A90E2" : "#3A3F4B"  // Blue on hover
                                    radius: 4
                                    border.color: v12Enable.hovered ? "#FFFFFF" : "#BDC3C7"  // White border on hover
                                }

                            }
                        }
                    }

                    // Fan Tests Box
                    Rectangle {
                        width: 650
                        height: 190
                        radius: 8
                        color: "#1E1E20"
                        border.color: "#3E4E6F"
                        border.width: 2

                        // Title at Top-Center with 5px Spacing
                        Text {
                            text: "Fan Tests"
                            color: "#BDC3C7"
                            font.pixelSize: 18
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 5  // 5px spacing from the top
                        }

                        // Slider for Top Fan
                        Column {
                            anchors.top: parent.top
                            anchors.topMargin: 40  // Adjust spacing as needed
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5

                            Text {
                                text: "Top Fan: " + (topFanSlider.value === 0 ? "OFF" : topFanSlider.value.toFixed(0) + "%")
                                color: "#BDC3C7"
                                font.pixelSize: 14
                            }

                            Slider {
                                id: topFanSlider
                                width: 600  // Adjust width as needed
                                from: 0
                                to: 100
                                stepSize: 10   // Snap to increments of 10
                                value: 0  // Default value is 0 (OFF)

                                property bool userIsSliding: false

                                onPressedChanged: {
                                    if (pressed) {
                                        userIsSliding = true
                                    } else if (!pressed && userIsSliding) {
                                        // User has finished sliding
                                        let snappedValue = Math.round(value / 10) * 10
                                        value = snappedValue
                                        console.log("Slider released at:", snappedValue)
                                        userIsSliding = false
                                    }
                                }
                            }
                        }

                        // Slider for Bottom Fan
                        Column {
                            anchors.top: parent.top
                            anchors.topMargin: 110  // Adjust spacing as needed
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5

                            Text {
                                text: "Bottom Fan: " + (bottomFanSlider.value === 0 ? "OFF" : bottomFanSlider.value.toFixed(0) + "%")
                                color: "#BDC3C7"
                                font.pixelSize: 14
                            }

                            Slider {
                                id: bottomFanSlider
                                width: 600  // Adjust width as needed
                                from: 0
                                to: 100
                                stepSize: 10   // Snap to increments of 10
                                value: 0  // Default value is 0 (OFF)


                                property bool userIsSliding: false

                                onPressedChanged: {
                                    if (pressed) {
                                        userIsSliding = true
                                    } else if (!pressed && userIsSliding) {
                                        // User has finished sliding
                                        let snappedValue = Math.round(value / 10) * 10
                                        value = snappedValue
                                        console.log("Slider released at:", snappedValue)
                                        userIsSliding = false
                                    }
                                }
                            }
                        }
                    }
                }

                // Large Third Column
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "#1E1E20"
                    radius: 10
                    border.color: "#3E4E6F"
                    border.width: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        // HV Status Indicator
                        RowLayout {
                            spacing: 8

                            Text { text: "HV"; font.pixelSize: 16; color: "#BDC3C7" }
                        
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: LIFUConnector.hvConnected ? "green" : "red"
                                border.color: "black"
                                border.width: 1
                            }

                            Text {
                                text: LIFUConnector.hvConnected ? "Connected" : "Not Connected"
                                font.pixelSize: 16
                                color: "#BDC3C7"
                            }
                        
                        // Spacer to push the Refresh Button to the right
                            Item {
                                Layout.fillWidth: true
                            }

                            // Refresh Button
                            Rectangle {
                                width: 30
                                height: 30
                                radius: 15
                                color: "#2C3E50"
                                Layout.alignment: Qt.AlignRight  // ✅ Correct way to anchor it to the right

                                // Icon Text
                                Text {
                                    text: "\u21BB"  // Unicode for the refresh icon
                                    anchors.centerIn: parent
                                    font.pixelSize: 20
                                    font.family: iconFont.name  // Use the loaded custom font
                                    color: "white"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("Manual Refresh Triggered")
                                        LIFUConnector.queryHvInfo()
                                        LIFUConnector.queryHvTemperature()
                                    }

                                    onEntered: parent.color = "#34495E"
                                    onExited: parent.color = "#2C3E50"
                                }
                            }
                        }
                        // Divider Line
                        Rectangle {
                            Layout.fillWidth: true
                            height: 2
                            color: "#3E4E6F"
                        }

                        // Display Device ID (Smaller Text)
                        RowLayout {
                            spacing: 8
                            Text { text: "Device ID:"; color: "#BDC3C7"; font.pixelSize: 14 }
                            Text { text: deviceId; color: "#3498DB"; font.pixelSize: 14 }
                        }

                        // Display Firmware Version (Smaller Text)
                        RowLayout {
                            spacing: 8
                            Text { text: "Firmware Version:"; color: "#BDC3C7"; font.pixelSize: 14 }
                            Text { text: firmwareVersion; color: "#2ECC71"; font.pixelSize: 14 }
                        }


                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter 
                            spacing: 25  

                            // TEMP #1 Widget
                            TemperatureWidget {
                                id: tempWidget1
                                temperature: temperature1
                                tempName: "Temperature #1"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // TEMP #2 Widget
                            TemperatureWidget {
                                id: tempWidget2
                                temperature: temperature2
                                tempName: "Temperature #2"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Soft Reset Button
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 10
                            color: "#E74C3C"

                            Text {
                                text: "Soft Reset"
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Soft Reset Triggered")
                                    LIFUConnector.softResetHV()
                                }

                                onEntered: parent.color = "#C0392B"
                                onExited: parent.color = "#E74C3C"
                            }

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }
        }
    }

    FontLoader {
        id: iconFont
        source: "../assets/fonts/keenicons-outline.ttf"
    }
}
