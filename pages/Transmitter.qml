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
    property real tx_temperature: 0.0
    property real amb_temperature: 0.0

    function updateStates() {
        console.log("Updating all states...")
        LIFUConnector.queryTxInfo()
        LIFUConnector.queryTxTemperature()
        LIFUConnector.queryTriggerInfo()
    }

    // Run refresh logic immediately on page load if TX is already connected
    Component.onCompleted: {
        if (LIFUConnector.txConnected) {
            console.log("Page Loaded - TX Already Connected. Fetching Info...")
            updateStates()
        }
    }

    Timer {
        id: infoTimer
        interval: 1500   // Delay to ensure TX is stable before fetching info
        running: false
        onTriggered: {
            console.log("Fetching Firmware Version and Device ID...")
            updateStates()
        }
    }

    Connections {
        target: LIFUConnector

        // Handle TX Connected state
        onTxConnectedChanged: {
            if (LIFUConnector.txConnected) {
                infoTimer.start()          // One-time info fetch
            } else {
                console.log("TX Disconnected - Clearing Data...")
                firmwareVersion = "N/A"
                deviceId = "N/A"
                tx_temperature = 0.0
                amb_temperature = 0.0
                
                pingResult.text = ""
                echoResult.text = ""
                toggleLedResult.text = ""
            }
        }

        // Handle device info response
        onTxDeviceInfoReceived: (fwVersion, devId) => {
            firmwareVersion = fwVersion
            deviceId = devId
        }

        // Handle temperature updates
        onTemperatureTxUpdated: (tx_temp, amb_temp) => {
            tx_temperature = tx_temp
            amb_temperature = amb_temp
        }

        onTriggerStateChanged: (state) => {
            triggerStatus.text = state ? "On" : "Off";
            triggerStatus.color = state ? "green" : "red";
        }

        onTxConfigStateChanged: (state) => {
            txconfigStatus.text = state ? "Configured" : "NOT Configured";
            txconfigStatus.color = state ? "green" : "red";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Title
        Text {
            text: "LIFU Transmitter Unit Tests"
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
                                enabled: LIFUConnector.txConnected 

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "#BDC3C7" : "#7F8C8D"  // Gray out text when disabled
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: pingButtonBackground
                                    color: {
                                        if (!parent.enabled) {
                                            return "#3A3F4B";  // Disabled color
                                        }
                                        return parent.hovered ? "#4A90E2" : "#3A3F4B";  // Blue on hover, default otherwise
                                    }
                                    radius: 4
                                    border.color: {
                                        if (!parent.enabled) {
                                            return "#7F8C8D";  // Disabled border color
                                        }
                                        return parent.hovered ? "#FFFFFF" : "#BDC3C7";  // White border on hover, default otherwise
                                    }
                                }

                                onClicked: {
                                    if(LIFUConnector.sendPingCommand("TX")){                                        
                                        pingResult.text = "Ping SUCCESS"
                                        pingResult.color = "green"
                                    }else{
                                        pingResult.text = "Ping FAILED"
                                        pingResult.color = "red"
                                    }
                                }
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
                                enabled: LIFUConnector.txConnected 

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "#BDC3C7" : "#7F8C8D"  // Gray out text when disabled
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: ledButtonBackground
                                    color: {
                                        if (!parent.enabled) {
                                            return "#3A3F4B";  // Disabled color
                                        }
                                        return parent.hovered ? "#4A90E2" : "#3A3F4B";  // Blue on hover, default otherwise
                                    }
                                    radius: 4
                                    border.color: {
                                        if (!parent.enabled) {
                                            return "#7F8C8D";  // Disabled border color
                                        }
                                        return parent.hovered ? "#FFFFFF" : "#BDC3C7";  // White border on hover, default otherwise
                                    }
                                }

                                onClicked: {
                                    if(LIFUConnector.sendLedToggleCommand("TX"))
                                    {
                                        toggleLedResult.text = "LED Toggled"
                                        toggleLedResult.color = "green"
                                    }
                                    else{
                                        toggleLedResult.text = "LED Toggle FAILED"
                                        toggleLedResult.color = "red"
                                    }
                                }
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
                                enabled: LIFUConnector.txConnected 

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "#BDC3C7" : "#7F8C8D"  // Gray out text when disabled
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: echoButtonBackground
                                    color: {
                                        if (!parent.enabled) {
                                            return "#3A3F4B";  // Disabled color
                                        }
                                        return parent.hovered ? "#4A90E2" : "#3A3F4B";  // Blue on hover, default otherwise
                                    }
                                    radius: 4
                                    border.color: {
                                        if (!parent.enabled) {
                                            return "#7F8C8D";  // Disabled border color
                                        }
                                        return parent.hovered ? "#FFFFFF" : "#BDC3C7";  // White border on hover, default otherwise
                                    }
                                }

                                onClicked: {

                                    if(LIFUConnector.sendEchoCommand("TX"))
                                    {
                                        echoResult.text = "Echo SUCCESS"
                                        echoResult.color = "green"
                                    }
                                    else{
                                        echoResult.text = "Echo FAILED"
                                        echoResult.color = "red"
                                    }
                                } 
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

                            Item {
                                
                            }
                            

                            Item {
                                
                            }
                        }
                    }
                    
                    // Trigger Tests
                    Rectangle {
                        width: 650
                        height: 390
                        radius: 6
                        color: "#1E1E20"
                        border.color: "#3E4E6F"
                        border.width: 2

                        // Title at Top-Center with 5px Spacing
                        Text {
                            text: "Trigger and TX Output Tests"
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

                            Text {
                                Layout.preferredWidth: 100
                                font.pixelSize: 16
                                text: "Trigger Pulse"
                                color: "#BDC3C7"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ComboBox {
                                id: triggerDropdown
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 40
                                model: ["10Hz 20ms Pulse", "20Hz 10ms Pulse", "40Hz 5ms Pulse"]
                                enabled: LIFUConnector.txConnected

                                onActivated: {
                                    var selectedIndex = triggerDropdown.currentIndex;

                                    // Define the JSON object
                                    var json_trigger_data = {
                                        "TriggerFrequencyHz": 0, // Will be updated based on the index
                                        "TriggerPulseCount": 0,
                                        "TriggerPulseWidthUsec": 0, // Will be updated based on the index
                                        "TriggerPulseTrainInterval": 0,
                                        "TriggerPulseTrainCount": 0,
                                        "TriggerMode": 1,
                                        "ProfileIndex": 0,
                                        "ProfileIncrement": 0
                                    };

                                    // Update frequency and pulse width based on the selected index
                                    switch (selectedIndex) {
                                        case 0: // 10Hz 20ms Pulse
                                            json_trigger_data.TriggerFrequencyHz = 10;
                                            json_trigger_data.TriggerPulseWidthUsec = 20000;
                                            break;
                                        case 1: // 20Hz 10ms Pulse
                                            json_trigger_data.TriggerFrequencyHz = 20;
                                            json_trigger_data.TriggerPulseWidthUsec = 10000;
                                            break;
                                        case 2: // 40Hz 5ms Pulse
                                            json_trigger_data.TriggerFrequencyHz = 40;
                                            json_trigger_data.TriggerPulseWidthUsec = 5000;
                                            break;
                                        default:
                                            console.log("Invalid selection");
                                            return;
                                    }

                                    // Convert the object to a JSON string
                                    var jsonString = JSON.stringify(json_trigger_data);

                                    // Call your function with the selected index
                                    var success = LIFUConnector.setTrigger(jsonString);
                                    if (success) {
                                        console.log("JSON data sent successfully");
                                    } else {
                                        console.log("Failed to send JSON data");
                                    }

                                }
                            }

                            Item {
                                Layout.preferredWidth: 100
                            }


                            Button {
                                id: triggerEnable
                                text: "Toggle Trigger"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 50
                                hoverEnabled: true  // Enable hover detection
                                enabled: LIFUConnector.txConnected 

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "#BDC3C7" : "#7F8C8D"  // Gray out text when disabled
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: triggerButtonBackground
                                    color: {
                                        if (!parent.enabled) {
                                            return "#3A3F4B";  // Disabled color
                                        }
                                        return parent.hovered ? "#4A90E2" : "#3A3F4B";  // Blue on hover, default otherwise
                                    }
                                    radius: 4
                                    border.color: {
                                        if (!parent.enabled) {
                                            return "#7F8C8D";  // Disabled border color
                                        }
                                        return parent.hovered ? "#FFFFFF" : "#BDC3C7";  // White border on hover, default otherwise
                                    }
                                }

                                onClicked: {
                                    // Toggle the trigger state
                                    var success = LIFUConnector.toggleTrigger();
                                    if (success) {
                                        console.log("Trigger toggled successfully.");
                                    } else {
                                        console.log("Failed to toggle trigger.");
                                    }
                                }

                            }

                            Text {
                                id: triggerStatus
                                Layout.preferredWidth: 80
                                text: ""
                                color: "#BDC3C7"
                            }
                            
                            Text {
                                Layout.preferredWidth: 100
                                font.pixelSize: 16
                                text: "TX Config"
                                color: "#BDC3C7"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ComboBox {
                                id: txconfigDropdown
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 40
                                model: ["100KHz", "200KHz", "400KHz"]
                                enabled: LIFUConnector.txConnected

                                onActivated: {
                                    if(LIFUConnector.triggerEnabled){
                                        LIFUConnector.toggleTrigger();
                                        txconfigStatus.text = ""
                                    }
                                }
                            }

                            Item {
                                Layout.preferredWidth: 100
                            }

                            Button {
                                id: setTxConfig
                                text: "Set TX Config"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 50
                                hoverEnabled: true  // Enable hover detection
                                enabled: LIFUConnector.txConnected 

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "#BDC3C7" : "#7F8C8D"  // Gray out text when disabled
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    id: setTxConfigBackground
                                    color: {
                                        if (!parent.enabled) {
                                            return "#3A3F4B";  // Disabled color
                                        }
                                        return parent.hovered ? "#4A90E2" : "#3A3F4B";  // Blue on hover, default otherwise
                                    }
                                    radius: 4
                                    border.color: {
                                        if (!parent.enabled) {
                                            return "#7F8C8D";  // Disabled border color
                                        }
                                        return parent.hovered ? "#FFFFFF" : "#BDC3C7";  // White border on hover, default otherwise
                                    }
                                }

                                onClicked: {
                                    // Set configuration of transmitter
                                    
                                    if(LIFUConnector.triggerEnabled){
                                        LIFUConnector.toggleTrigger();
                                    }
                                    txconfigStatus.text = ""
                                    var selectedIndex = txconfigDropdown.currentIndex;
                                    let frequency = 400000
                                    let pulse_count = 5

                                    // Update frequency and pulse width based on the selected index
                                    switch (selectedIndex) {
                                        case 0: // 100KHz 
                                            frequency = 100000
                                            pulse_count = 10
                                            break;
                                        case 1: // 200KHz 
                                            frequency = 200000
                                            pulse_count = 10
                                            break;
                                        case 2: // 400KHz 
                                            frequency = 400000
                                            pulse_count = 10
                                            break;
                                        default:
                                            console.log("Invalid selection");
                                            return;
                                    }

                                    // Call your function with the selected index
                                    LIFUConnector.setSimpleTxConfig(frequency, pulse_count);
                                }

                            }

                            Text {
                                id: txconfigStatus
                                Layout.preferredWidth: 80
                                text: ""
                                color: "#BDC3C7"
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

                        // TX Status Indicator
                        RowLayout {
                            spacing: 8

                            Text { text: "TX"; font.pixelSize: 16; color: "#BDC3C7" }
                        
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: LIFUConnector.txConnected ? "green" : "red"
                                border.color: "black"
                                border.width: 1
                            }

                            Text {
                                text: LIFUConnector.txConnected ? "Connected" : "Not Connected"
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
                                color: enabled ? "#2C3E50" : "#7F8C8D"  // Dim when disabled
                                Layout.alignment: Qt.AlignRight  
                                enabled: LIFUConnector.txConnected

                                // Icon Text
                                Text {
                                    text: "\u21BB"  // Unicode for the refresh icon
                                    anchors.centerIn: parent
                                    font.pixelSize: 20
                                    font.family: iconFont.name  // Use the loaded custom font
                                    color: enabled ? "white" : "#BDC3C7"  // Dim icon text when disabled
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: parent.enabled  // MouseArea also disabled when button is disabled
                                    onClicked: {
                                        console.log("Manual Refresh Triggered")
                                        updateStates();
                                    }

                                    onEntered: if (parent.enabled) parent.color = "#34495E"  // Highlight only when enabled
                                    onExited: parent.color = enabled ? "#2C3E50" : "#7F8C8D"
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
                                temperature: tx_temperature
                                tempName: "TX Temperature"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // TEMP #2 Widget
                            TemperatureWidget {
                                id: tempWidget2
                                temperature: amb_temperature
                                tempName: "Amb Temperature"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }


                        // Soft Reset Button
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 10
                            color: enabled ? "#E74C3C" : "#7F8C8D"  // Red when enabled, gray when disabled
                            enabled: LIFUConnector.txConnected

                            Text {
                                text: "Soft Reset"
                                anchors.centerIn: parent
                                color: parent.enabled ? "white" : "#BDC3C7"  // White when enabled, light gray when disabled
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.enabled  // Disable MouseArea when the button is disabled
                                onClicked: {
                                    console.log("Soft Reset Triggered")
                                    LIFUConnector.softResetTX()
                                }

                                onEntered: {
                                    if (parent.enabled) {
                                        parent.color = "#C0392B"  // Darker red on hover (only when enabled)
                                    }
                                }
                                onExited: {
                                    if (parent.enabled) {
                                        parent.color = "#E74C3C"  // Restore original color (only when enabled)
                                    }
                                }
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
