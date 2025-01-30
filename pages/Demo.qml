import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Dialogs

Rectangle {
    id: demoPage
    width: parent.width
    height: parent.height
    color: "#29292B" // Background color
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
            topMargin: 10 // Added 10px more margin from the top
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Left side: User input and controls
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

                // Beam Focus Section
                GroupBox {
                    title: "Beam Focus"
                    Layout.fillWidth: true
                    label: Text {
                        text: "Beam Focus"
                        color: "white"
                        font.bold: true
                    }

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

                // Pulse Profile Section
                GroupBox {
                    title: "Pulse Profile"
                    Layout.fillWidth: true
                    label: Text {
                        text: "Pulse Profile"
                        color: "white"
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        width: parent.width

                        Text { text: "Frequency (Hz):"; color: "white" }
                        TextField { id: frequencyInput; text: "400e3" }

                        Text { text: "Cycles:"; color: "white" }
                        TextField { id: cyclesInput; text: "5" }

                        Text { text: "Trigger(Hz):"; color: "white" }
                        TextField { id: triggerInput; text: "10" }
                    }
                }



                // Control Buttons Section
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
                                frequencyInput.text, cyclesInput.text, triggerInput.text
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

            // Right top: Graph display
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
                    source: "../assets/images/ex_plot.png"
                }

            }

            // Right bottom: Status panel
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

            // Right bottom: Status panel
            Rectangle {
                id: statusPanel
                width: 500
                height: 130
                color: "#252525"
                radius: 10
                border.color: "#3E4E6F"
                border.width: 2

                Text {
                    text: "Status: Ready"
                    font.pixelSize: 16
                    color: "#BDC3C7"
                    anchors.centerIn: parent
                }
            }
        }
    }
}
