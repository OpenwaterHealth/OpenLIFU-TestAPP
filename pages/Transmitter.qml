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

    // Run refresh logic immediately on page load if TX is already connected
    Component.onCompleted: {
        if (LIFUConnector.txConnected) {
            console.log("Page Loaded - TX Already Connected. Fetching Info...")
            LIFUConnector.queryTxInfo()
            LIFUConnector.queryTxTemperature()
        }
    }

    Timer {
        id: infoTimer
        interval: 500   // Delay to ensure TX is stable before fetching info
        running: false
        onTriggered: {
            console.log("Fetching Firmware Version and Device ID...")
            LIFUConnector.queryTxInfo()
            LIFUConnector.queryTxTemperature()
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

                // Grid Section (2 Columns)
                GridLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.65
                    columns: 2
                    rowSpacing: 5
                    columnSpacing: 10

                    Repeater {
                        model: 20 // 2 columns x 10 rows

                        Rectangle {
                            width: page1.width / 4
                            height: 50
                            radius: 8
                            color: index % 2 === 0 ? "#2C3E50" : "#34495E"

                            Text {
                                text: "Cell " + (index + 1)
                                anchors.centerIn: parent
                                color: "#BDC3C7"
                                font.pixelSize: 18
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#16A085"
                                onExited: parent.color = index % 2 === 0 ? "#2C3E50" : "#34495E"
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
                                        LIFUConnector.queryTxInfo()
                                        LIFUConnector.queryTxTemperature()
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
                            anchors.centerIn: parent
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
                                    LIFUConnector.softResetTX()
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
