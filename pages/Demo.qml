import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Dialogs

Rectangle {
    id: demoPage
    width: parent.width
    height: parent.height
    color: "#29292B"
    radius: 20
    opacity: 0.95

    // HEADER
    Text {
        text: "Focused Ultrasound Demo"
        font.pixelSize: 18
        font.weight: Font.Bold
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 10
        }
    }

    // LAYOUT
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Left Column (Input Panel)
        Rectangle {
            id: inputContainer
            width: 500
            height: 620
            color: "#1E1E20"
            radius: 10
            border.color: "#3E4E6F"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                GroupBox {
                    title: "Beam Focus"
                    Layout.fillWidth: true

                    GridLayout {
                        columns: 2
                        width: parent.width

                        Text { text: "Left (X):"; color: "white" }
                        TextField { id: xInput; text: "0" }

                        Text { text: "Front (Y):"; color: "white" }
                        TextField { id: yInput; text: "0" }

                        Text { text: "Down (Z):"; color: "white" }
                        TextField { id: zInput; text: "25" }
                    }
                }

                GroupBox {
                    title: "High Voltage"
                    Layout.fillWidth: true

                    GridLayout {
                        columns: 2
                        width: parent.width

                        Text { text: "Voltage (+/-):"; color: "white" }
                        TextField { id: voltage; text: "12.0" }
                    }
                }

                GroupBox {
                    title: "Pulse Profile"
                    Layout.fillWidth: true

                    GridLayout {
                        columns: 2
                        width: parent.width

                        Text { text: "Frequency (Hz):"; color: "white" }
                        TextField { id: frequencyInput; text: "400e3" }

                        Text { text: "Trigger (Hz):"; color: "white" }
                        TextField { id: triggerInput; text: "10" }
                    }
                }

                // BUTTONS
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "Configure"
                        Layout.fillWidth: true
                        enabled: LIFUConnector.state === 1  // TX_CONNECTED
                        onClicked: {
                            console.log("Configuring transmitter...");
                            LIFUConnector.configure_transmitter(xInput.text, yInput.text, 
                                zInput.text,  frequencyInput.text, voltage.text, triggerInput.text);
                            LIFUConnector.generate_plot(
                                 xInput.text, yInput.text, zInput.text,
                                 frequencyInput.text, "100", triggerInput.text,
                                 "buffer"
                            );
                        }
                    }

                    Button {
                        text: "Start"
                        Layout.fillWidth: true
                        enabled: LIFUConnector.state === 3  // READY
                        onClicked: {
                            console.log("Starting Sonication...");
                            LIFUConnector.start_sonication();
                        }
                    }

                    Button {
                        text: "Stop"
                        Layout.fillWidth: true
                        enabled: LIFUConnector.state === 4  // RUNNING
                        onClicked: {
                            console.log("Stopping Sonication...");
                            LIFUConnector.stop_sonication();
                        }
                    }

                    Button {
                        text: "Reset"
                        Layout.fillWidth: true
                        enabled: (LIFUConnector.state > 1 && LIFUConnector.state != 4)  // CONFIGURED
                        onClicked: {
                            console.log("Resetting parameters...");
                            xInput.text = "0";
                            yInput.text = "0";
                            zInput.text = "25";
                            frequencyInput.text = "400e3";
                            voltage.text = "12.0";
                            triggerInput.text = "10";
                            LIFUConnector.reset_configuration();
                        }
                    }
                }
            }
        }

        // RIGHT COLUMN (Status Panel + Graph)
        ColumnLayout {
            spacing: 20
			
            Rectangle {
                id: graphContainer
                width: 500
                height: 300
                color: "#1E1E20"
                radius: 10
                border.color: "#3E4E6F"
                border.width: 2

                Image {
                    id: ultrasoundGraph
                    anchors.fill: parent
                    anchors.margins: 10
                    fillMode: Image.PreserveAspectFit
                    source: "../assets/images/empty_graph.png"


                    function updateImage(base64data) {
                        if (base64data.startsWith("data:image/png;base64,")) {
                            source = base64data;
                        } else {
                            source = base64data;
                        }
                    }
                }
            }
            
            Rectangle {
                id: messagePanel
                width: 500
                height: 150
                color: "#252525"
                radius: 10
                border.color: "#3E4E6F"
                border.width: 2

            }
			// Status Panel (Connection Indicators)
            Rectangle {
                id: statusPanel
                width: 500
                height: 130
                color: "#252525"
                radius: 10
                border.color: "#3E4E6F"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    // Connection status text
                    Text {
                        id: statusText
                        text: "System State: " + (LIFUConnector.state === 0 ? "Disconnected"
                                        : LIFUConnector.state === 1 ? "TX Connected"
                                        : LIFUConnector.state === 2 ? "Configured"
                                        : LIFUConnector.state === 3 ? "Ready"
                                        : "Running")
                        font.pixelSize: 16
                        color: "#BDC3C7"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Connection Indicators (TX, HV)
                    RowLayout {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        // TX LED
                        RowLayout {
                            spacing: 5
                            // LED circle
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: LIFUConnector.txConnected ? "green" : "red"
                                border.color: "black"
                                border.width: 1
                            }
                            // Label for TX
                            Text {
                                text: "TX"
                                font.pixelSize: 16
                                color: "#BDC3C7"
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // HV LED
                        RowLayout {
                            spacing: 5
                            // LED circle
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: LIFUConnector.hvConnected ? "green" : "red"
                                border.color: "black"
                                border.width: 1
                            }
                            // Label for HV
                            Text {
                                text: "HV"
                                font.pixelSize: 16
                                color: "#BDC3C7"
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
    // **Connections for LIFUConnector signals**
    Connections {
        target: LIFUConnector

        function onSignalConnected(descriptor, port) {
            console.log(descriptor + " connected on " + port);
            statusText.text = "Connected: " + descriptor + " on " + port;
        }

        function onSignalDisconnected(descriptor, port) {
            console.log(descriptor + " disconnected from " + port);
            statusText.text = "Disconnected: " + descriptor + " from " + port;
        }

        function onSignalDataReceived(descriptor, message) {
            console.log("Data from " + descriptor + ": " + message);
        }

        function onPlotGenerated(imageData) {
            console.log("Received image data for display.");
            ultrasoundGraph.updateImage("data:image/png;base64," + imageData);
            statusText.text = "Status: Plot updated!";
        }
    }

    Component.onDestruction: {
        console.log("Closing UI, clearing LIFUConnector...");
        LIFUConnector.stop_monitoring();
        LIFUConnector = null;  // Ensure QML does not access it
    }
}
