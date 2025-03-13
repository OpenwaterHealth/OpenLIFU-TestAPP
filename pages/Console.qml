import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

Rectangle {
    id: page1
    width: parent.width
    height: parent.height
    color: "#29292B"
    radius: 20
    opacity: 0.95

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Title
        Text {
            text: "LIFU Console Unit Tests"
            font.pixelSize: 24
            font.weight: Font.Bold
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        // Content Section
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
                        spacing: 15

                        // HV Status Indicator
                        RowLayout {
                            spacing: 8

                            Text {
                                text: "HV"
                                font.pixelSize: 16
                                color: "#BDC3C7"
                                verticalAlignment: Text.AlignVCenter
                            }
                        
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: LIFUConnector.hvConnected ? "green" : "red"
                                border.color: "black"
                                border.width: 1
                            }

                            Text {
                                text: "Not Connected"
                                font.pixelSize: 16
                                color: "#BDC3C7"
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Divider Line for Separation
                        Rectangle {
                            Layout.fillWidth: true
                            height: 2
                            color: "#3E4E6F"
                        }

                        // Device ID Field
                        RowLayout {
                            spacing: 8
                            Text {
                                text: "Device ID:"
                                font.pixelSize: 18
                                color: "#BDC3C7"
                            }
                            Text {
                                text: LIFUConnector.deviceId
                                font.pixelSize: 18
                                color: "#3498DB"  // Blue for distinctiveness
                                font.bold: true
                            }
                        }

                        // Temperature Readings
                        ColumnLayout {
                            spacing: 10

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "TEMP #1:"
                                    font.pixelSize: 18
                                    color: "#BDC3C7"
                                }
                                Text {
                                    text: LIFUConnector.temp1.toFixed(1) + " °C"
                                    font.pixelSize: 18
                                    color: "#F1C40F" // Yellow for visibility
                                }
                            }

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "TEMP #2:"
                                    font.pixelSize: 18
                                    color: "#BDC3C7"
                                }
                                Text {
                                    text: LIFUConnector.temp2.toFixed(1) + " °C"
                                    font.pixelSize: 18
                                    color: "#F1C40F" // Yellow for visibility
                                }
                            }
                        }

                        // Optional Extra Space for Future Content
                        Item {
                            Layout.fillHeight: true
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
                                    LIFUConnector.softReset()
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
}
