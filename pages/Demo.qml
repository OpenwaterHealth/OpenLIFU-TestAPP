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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

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
                        TextField { id: zInput; text: "50" }
                    }
                }

                GroupBox {
                    title: "Pulse Profile"
                    Layout.fillWidth: true

                    GridLayout {
                        columns: 2
                        width: parent.width

                        Text { text: "Frequency (Hz):"; color: "white" }
                        TextField { id: frequencyInput; text: "1000000" }

                        Text { text: "Cycles:"; color: "white" }
                        TextField { id: cyclesInput; text: "5" }

                        Text { text: "Trigger (Hz):"; color: "white" }
                        TextField { id: triggerInput; text: "10" }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "Configure"
                        Layout.fillWidth: true
                        onClicked: {
                            console.log("Configuring beam with parameters:");
                            console.log("X:", xInput.text);
                            console.log("Y:", yInput.text);
                            console.log("Z:", zInput.text);
                            console.log("Frequency:", frequencyInput.text);
                            console.log("Cycles:", cyclesInput.text);
                            console.log("Trigger:", triggerInput.text);
                            UltrasoundController.generate_plot(
                                xInput.text, yInput.text, zInput.text,
                                frequencyInput.text, cyclesInput.text, triggerInput.text,
                                "buffer"
                            );
                        }
                    }

                    Button {
                        text: "Start"
                        Layout.fillWidth: true
                        enabled: false  // This disables the button
                        onClicked: {
                            console.log("Starting beam...");
                        }
                    }

                    Button {
                        text: "Stop"
                        Layout.fillWidth: true
                        enabled: false  // This disables the button
                        onClicked: {
                            console.log("Stopping beam...");
                        }
                    }

                    Button {
                        text: "Reset"
                        Layout.fillWidth: true
                        enabled: false  // This disables the button
                        onClicked: {
                            console.log("Resetting parameters...");
                            xInput.text = "0";
                            yInput.text = "0";
                            zInput.text = "50";
                            frequencyInput.text = "1000000";
                            cyclesInput.text = "5";
                            triggerInput.text = "0";
                        }
                    }
                }
            }
        }

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
                id: solutionPanel
                width: 500
                height: 150
                color: "#252525"
                radius: 10
                border.color: "#3E4E6F"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "Solution File Upload"
                        font.pixelSize: 16
                        color: "#BDC3C7"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    FileDialog {
                        id: fileDialog
                        title: "Select a Solution File"
                        nameFilters: ["Documents (*.pdf *.docx *.txt)"]
                        onAccepted: {
                            console.log("File selected: " + fileDialog.file)
                        }
                    }

                    Button {
                        text: "Upload File"
                        onClicked: fileDialog.open()
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

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
                        text: "Status: Ready"
                        font.pixelSize: 16
                        color: "#BDC3C7"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // LED indicators for TX and HV
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
                                color: UltrasoundController ? (UltrasoundController.txConnected ? "green" : "red") : "red"    
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
                                color: UltrasoundController ? (UltrasoundController.hvConnected ? "green" : "red") : "red"    
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

    Connections {
        target: UltrasoundController
        function onPlotGenerated(imageData) {
            console.log("Received image data for display.");
            ultrasoundGraph.updateImage("data:image/png;base64," + imageData);
            statusText.text = "Status: Plot updated!";
        }
    }
}
