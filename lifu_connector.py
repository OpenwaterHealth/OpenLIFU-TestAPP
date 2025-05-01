from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot
import logging
import numpy as np
import base58
import json
from scripts.generate_ultrasound_plot import generate_ultrasound_plot  # Import the function directly
from openlifu.io.LIFUInterface import LIFUInterface
from openlifu.bf.pulse import Pulse
from openlifu.bf.sequence import Sequence
from openlifu.geo import Point
from openlifu.plan.solution import Solution

logger = logging.getLogger(__name__)

# Define system states
DISCONNECTED = 0
TX_CONNECTED = 1
CONFIGURED = 2
READY = 3
RUNNING = 4

class LIFUConnector(QObject):
    # Ensure signals are correctly defined
    signalConnected = pyqtSignal(str, str)  # (descriptor, port)
    signalDisconnected = pyqtSignal(str, str)  # (descriptor, port)
    signalDataReceived = pyqtSignal(str, str)  # (descriptor, data)
    plotGenerated = pyqtSignal(str)  # Signal to notify QML when a new plot is ready
    solutionConfigured = pyqtSignal(str)  # Signal for solution configuration feedback

    powerStatusReceived = pyqtSignal(bool, bool)  # Signal for power status updates
    rgbStateReceived = pyqtSignal(int, str)  # Emit both integer value and text

    # New Signals for data updates
    hvDeviceInfoReceived = pyqtSignal(str, str)  # (firmwareVersion, deviceId)
    txDeviceInfoReceived = pyqtSignal(str, str)  # (firmwareVersion, deviceId)
    temperatureHvUpdated = pyqtSignal(float, float)  # (temp1, temp2)
    temperatureTxUpdated = pyqtSignal(float, float)  # (tx_temp, amb_temp)

    stateChanged = pyqtSignal()  # Notifies QML when state changes
    connectionStatusChanged = pyqtSignal()  # 🔹 New signal for connection updates
    triggerStateChanged = pyqtSignal(bool)  # 🔹 New signal for trigger state change
    txConfigStateChanged = pyqtSignal(bool)  # 🔹 New signal for tx configured state change

    def __init__(self, hv_test_mode=False):
        super().__init__()
        self.interface = LIFUInterface(HV_test_mode=hv_test_mode, run_async=True)
        self._txConnected = False
        self._hvConnected = False
        self._configured = False
        self._state = DISCONNECTED
        self._trigger_state = False  # Internal state to track trigger status
        self._txconfigured_state = False  # Internal state to track trigger status

        self.connect_signals()

    def connect_signals(self):
        """Connect LIFUInterface signals to QML."""
        self.interface.signal_connect.connect(self.on_connected)
        self.interface.signal_disconnect.connect(self.on_disconnected)
        self.interface.signal_data_received.connect(self.on_data_received)

    def update_state(self):
        """Update system state based on connection and configuration."""
        if not self._txConnected and not self._hvConnected:
            self._state = DISCONNECTED
        elif self._txConnected and not self._configured:
            self._state = TX_CONNECTED
        elif self._txConnected and self._hvConnected and self._configured:
            self._state = READY
        elif self._txConnected and self._configured:
            self._state = CONFIGURED
        self.stateChanged.emit()  # Notify QML of state update
        logger.info(f"Updated state: {self._state}")

    def _update_trigger_state(self, trigger_data):
        """Helper method to update trigger state and emit signal."""
        try:
            trigger_status = trigger_data.get("TriggerStatus", "STOPPED")
            new_trigger_state = trigger_status == "RUNNING"

            if new_trigger_state != self._trigger_state:
                self._trigger_state = new_trigger_state
                self.triggerStateChanged.emit(self._trigger_state)

        except Exception as e:
            logger.error(f"Error updating trigger state: {e}")


    @pyqtSlot()
    async def start_monitoring(self):
        """Start monitoring for device connection asynchronously."""
        try:
            logger.info("Starting device monitoring...")
            await self.interface.start_monitoring()
        except Exception as e:
            logger.error(f"Error in start_monitoring: {e}", exc_info=True)

    @pyqtSlot()
    def stop_monitoring(self):
        """Stop monitoring device connection."""
        try:
            logger.info("Stopping device monitoring...")
            self.interface.stop_monitoring()
        except Exception as e:
            logger.error(f"Error while stopping monitoring: {e}", exc_info=True)

    @pyqtSlot(str, str)
    def on_connected(self, descriptor, port):
        """Handle device connection."""
        if descriptor == "TX":
            self._txConnected = True
        elif descriptor == "HV":
            self._hvConnected = True
        self.signalConnected.emit(descriptor, port)
        self.connectionStatusChanged.emit() 
        self.update_state()

    @pyqtSlot(str, str)
    def on_disconnected(self, descriptor, port):
        """Handle device disconnection."""
        if descriptor == "TX":
            self._txConnected = False
        elif descriptor == "HV":
            self._hvConnected = False
        self.signalDisconnected.emit(descriptor, port)
        self.connectionStatusChanged.emit() 
        self.update_state()

    @pyqtSlot(str, str)
    def on_data_received(self, descriptor, message):
        """Handle incoming data from the LIFU device."""
        logger.info(f"Data received from {descriptor}: {message}")
        self.signalDataReceived.emit(descriptor, message)

    @pyqtSlot(str, float)
    def configureSolution(self, solutionName, amplitude):
        """Configures the solution and emits status to QML."""
        try:
            logger.debug("Configuring solution: %s with amplitude: %s", solutionName, amplitude)
            solution = None  # Replace with actual configuration logic
            if self.interface.set_solution(solution):
                logger.info("Solution '%s' configured successfully.", solutionName)
                self.solutionConfigured.emit(f"Solution '{solutionName}' configured.")
            else:
                logger.error("Failed to configure solution '%s'.", solutionName)
                self.solutionConfigured.emit("Configuration failed.")
        except Exception as e:
            logger.error("Error configuring solution: %s", e)
            self.solutionConfigured.emit("Configuration error.")

    @pyqtSlot(str, str, str, str, str, str, str)
    def generate_plot(self, x, y, z, freq, cycles, trigger, mode):
        """Generates an ultrasound plot and emits data to QML."""
        try:
            logger.info(f"Generating plot: X={x}, Y={y}, Z={z}, Frequency={freq}, Cycles={cycles}, Trigger={trigger}, Mode={mode}")
            image_data = generate_ultrasound_plot(x, y, z, freq, cycles, trigger, mode)

            if image_data == "ERROR":
                logger.error("Plot generation failed")
            else:
                logger.info("Plot generated successfully")
                self.plotGenerated.emit(image_data)  # Send image data to QML

        except Exception as e:
            logger.error(f"Error generating plot: {e}")

    @pyqtSlot(str, str, str, str, str, str, str)
    def configure_transmitter(self, xInput, yInput, zInput, freq, voltage, triggerHZ, durationS):
        """Simulate configuring the transmitter."""
        if self._txConnected:
            pulse = Pulse(frequency=float(freq), amplitude=float(voltage), duration=float(durationS))
            pt = Point(position=(float(xInput),float(yInput),float(zInput)), units="mm")
            sequence = Sequence(
                pulse_interval=1.0/float(triggerHZ),
                pulse_count=1,
                pulse_train_interval=1,
                pulse_train_count=1
            )

            solution = Solution(
                id="solution",
                name="Solution",
                protocol_id="example_protocol",
                transducer_id="example_transducer",
                delays = np.zeros((1,64)),
                apodizations = np.ones((1,64)),
                pulse = pulse,
                sequence = sequence,
                target=pt,
                foci=[pt],
                approved=True
            )
            
            self.interface.set_solution(solution)

            self._configured = True
            self.update_state()
            logger.info("Transmitter configured")

        
    @pyqtSlot(int, int, result=bool)
    def setSimpleTxConfig(self, freq: float, pulses: int):
        pulse = Pulse(frequency=freq, amplitude=10.0, duration=2e-4)
        pt = Point(position=(0, 0, 50), units="mm")
        sequence = Sequence(
            pulse_interval=0.01,
            pulse_count=pulses,
            pulse_train_interval=1,
            pulse_train_count=1
        )

        solution = Solution(
            id="solution",
            name="Solution",
            protocol_id="example_protocol",
            transducer_id="example_transducer",
            delays = np.zeros((1,64)),
            apodizations = np.ones((1,64)),
            pulse = pulse,
            sequence = sequence,
            target=pt,
            foci=[pt],
            approved=True
        )

        sol_dict = solution.to_dict()
        profile_index = 1
        profile_increment = True
        logger.error(f">>>>>>>>>>>>>>>>>>> Set Solution {solution}")
        ret_status = self.interface.set_solution(solution = solution)

        self._txconfigured_state = True
        self.txConfigStateChanged.emit(self._txconfigured_state)
        return True

    @pyqtSlot()
    def reset_configuration(self):
        """Reset system configuration to defaults."""
        self._configured = False
        self.update_state()
        logger.info("Configuration reset")

    @pyqtSlot()
    def start_sonication(self):
        """Start the beam, transitioning to RUNNING state."""
        if self._state == READY:
            if self.interface.start_sonication():
                self._state = RUNNING
            else:
                logger.info("Failed to start trigger")
            self.stateChanged.emit()
            logger.info("Sonication started")

    @pyqtSlot()
    def stop_sonication(self):
        """Stop the beam and return to READY state."""
        if self._state == RUNNING:
            if self.interface.stop_sonication():
                self._state = READY
            else:
                logger.info("Failed to stop trigger")
            self.stateChanged.emit()
            logger.info("Sonication stopped")

    @pyqtProperty(bool, notify=connectionStatusChanged)
    def txConnected(self):
        """Expose TX connection status to QML."""
        return self._txConnected

    @pyqtProperty(bool, notify=connectionStatusChanged)
    def hvConnected(self):
        """Expose HV connection status to QML."""
        return self._hvConnected

    @pyqtProperty(int, notify=stateChanged)
    def state(self):
        """Expose state as a QML property."""
        return self._state
    
    @pyqtProperty(bool, notify=connectionStatusChanged)
    def txConnected(self):
        """Expose TX connection status to QML."""
        return self._txConnected

    @pyqtProperty(bool, notify=connectionStatusChanged)
    def hvConnected(self):
        """Expose HV connection status to QML."""
        return self._hvConnected
    
    @pyqtProperty(int, notify=stateChanged)
    def state(self):
        """Expose state as a QML property."""
        return self._state
    
    @pyqtProperty(bool, notify=triggerStateChanged)
    def triggerEnabled(self):
        """Expose trigger enabled status to QML."""
        return self._trigger_state
    
    @pyqtSlot()
    def queryHvInfo(self):
        """Fetch and emit device information."""
        try:
            fw_version = self.interface.hvcontroller.get_version()
            logger.info(f"Version: {fw_version}")
            hw_id = self.interface.hvcontroller.get_hardware_id()
            device_id = base58.b58encode(bytes.fromhex(hw_id)).decode()
            self.hvDeviceInfoReceived.emit(fw_version, device_id)
            logger.info(f"Device Info - Firmware: {fw_version}, Device ID: {device_id}")
        except Exception as e:
            logger.error(f"Error querying device info: {e}")

    @pyqtSlot()
    def queryTxInfo(self):
        """Fetch and emit device information."""
        try:
            fw_version = self.interface.txdevice.get_version()
            logger.info(f"Version: {fw_version}")
            hw_id = self.interface.txdevice.get_hardware_id()
            device_id = base58.b58encode(bytes.fromhex(hw_id)).decode()
            self.txDeviceInfoReceived.emit(fw_version, device_id)
            logger.info(f"Device Info - Firmware: {fw_version}, Device ID: {device_id}")
        except Exception as e:
            logger.error(f"Error querying device info: {e}")

    @pyqtSlot()
    def queryHvTemperature(self):
        """Fetch and emit temperature data."""
        try:
            temp1 = self.interface.hvcontroller.get_temperature1()  
            temp2 = self.interface.hvcontroller.get_temperature2()  

            self.temperatureHvUpdated.emit(temp1, temp2)
            logger.info(f"Temperature Data - Temp1: {temp1}, Temp2: {temp2}")
        except Exception as e:
            logger.error(f"Error querying temperature data: {e}")


    @pyqtSlot()
    def queryTxTemperature(self):
        """Fetch and emit temperature data."""
        try:
            tx_temp = self.interface.txdevice.get_temperature()  
            amb_temp = self.interface.txdevice.get_ambient_temperature()  

            self.temperatureTxUpdated.emit(tx_temp, amb_temp)
            logger.info(f"Temperature Data - Temp1: {tx_temp}, Temp2: {amb_temp}")
        except Exception as e:
            logger.error(f"Error querying temperature data: {e}")

    @pyqtSlot(int)
    def setRGBState(self, state):
        """Set the RGB state using integer values."""
        try:
            valid_states = [0, 1, 2, 3]
            if state not in valid_states:
                logger.error(f"Invalid RGB state value: {state}")
                return

            if self.interface.hvcontroller.set_rgb_led(state) == state:
                logger.info(f"RGB state set to: {state}")
            else:
                logger.error(f"Failed to set RGB state to: {state}")
        except Exception as e:
            logger.error(f"Error setting RGB state: {e}")
            
    @pyqtSlot()
    def queryRGBState(self):
        """Fetch and emit RGB state."""
        try:
            state = self.interface.hvcontroller.get_rgb_led()
            state_text = {0: "Off", 1: "Red", 2: "Green", 3: "Blue"}.get(state, "Unknown")

            logger.info(f"RGB State: {state_text}")
            self.rgbStateReceived.emit(state, state_text)  # Emit both values
        except Exception as e:
            logger.error(f"Error querying RGB state: {e}")

    @pyqtSlot()
    def queryPowerStatus(self):
        """Fetch and emit HV state."""
        try:
            hv_state = self.interface.hvcontroller.get_hv_status()            
            v12_state = self.interface.hvcontroller.get_12v_status()
            logger.info(f"HV State: {hv_state} - 12V State: {v12_state}")
            self.powerStatusReceived.emit(v12_state, hv_state)
        except Exception as e:
            logger.error(f"Error querying Power status: {e}")
    
    @pyqtSlot(str, result=bool)
    def sendPingCommand(self, target: str):
        """Send a ping command to HV device."""
        try:
            if target == "HV":
                if self.interface.hvcontroller.ping():
                    logger.info(f"Ping command sent successfully")
                    return True
                else:
                    logger.error(f"Failed to send ping command")
                    return False
            elif target == "TX":
                if self.interface.txdevice.ping():
                    logger.info(f"Ping command sent successfully")
                    return True
                else:
                    logger.error(f"Failed to send ping command")
                    return False
            else:
                logger.error(f"Invalid target for ping command")
                return False
        except Exception as e:
            logger.error(f"Error sending ping command: {e}")
            return False
        
    @pyqtSlot(str, result=bool)
    def sendLedToggleCommand(self, target: str):
        """Send a LED Toggle command to device."""
        try:
            if target == "HV":
                if self.interface.hvcontroller.toggle_led():
                    logger.info(f"Toggle command sent successfully")
                    return True
                else:
                    logger.error(f"Failed to Toggle command")
                    return False
            elif target == "TX":
                if self.interface.txdevice.toggle_led():
                    logger.info(f"Toggle command sent successfully")
                    return True
                else:
                    logger.error(f"Failed to send Toggle command")
                    return False
            else:
                logger.error(f"Invalid target for Toggle command")
                return False
        except Exception as e:
            logger.error(f"Error sending Toggle command: {e}")
            return False
        
    @pyqtSlot(str, result=bool)
    def sendEchoCommand(self, target: str):
        """Send Echo command to device."""
        try:
            expected_data = b"Hello FROM Test Application!"
            if target == "HV":
                echoed_data, data_len = self.interface.hvcontroller.echo(echo_data=expected_data)
            elif target == "TX":
                echoed_data, data_len = self.interface.txdevice.echo(echo_data=expected_data)
            else:
                logger.error(f"Invalid target for Echo command")
                return False

            if echoed_data == expected_data and data_len == len(expected_data):
                logger.info(f"Echo command successful - Data matched")
                return True
            else:
                logger.error(f"Echo command failed - Data mismatch")
                return False
            
        except Exception as e:
            logger.error(f"Error sending Echo command: {e}")
            return False
    
    @pyqtSlot(str, result=bool)
    def setHVCommand(self, strval: str):
        """Set High voltage command to device."""
        try:
            voltage = float(strval)
            if self.interface.hvcontroller.set_voltage(voltage=voltage):
                logger.info(f"Voltage set successfully")
                return True
            else:   
                logger.error(f"Failed to set voltage")
                return False    
                        
        except Exception as e:
            logger.error(f"Error setting High Voltage: {e}")
            return False
    
    @pyqtSlot(int, int, result=bool)
    def setFanLevel(self, fid: int, speed: int):
        """Set Fan Level to device."""
        try:
            
            if self.interface.hvcontroller.set_fan_speed(fan_id=fid, fan_speed=speed) == speed:
                logger.info(f"Fan set successfully")
                return True
            else:   
                logger.error(f"Failed to set Fan Speed")
                return False    
                        
        except Exception as e:
            logger.error(f"Error setting Fan Speed: {e}")
            return False
    
    @pyqtSlot(str, result=bool)
    def setTrigger(self, triggerjson: str):
        """Set trigger settings on the device using JSON data."""
        try:
            json_trigger_data = json.loads(triggerjson)
            
            trigger_setting = self.interface.txdevice.set_trigger_json(data=json_trigger_data)

            if trigger_setting:
                self._update_trigger_state(trigger_setting)  # Update trigger state dynamically
                logger.info(f"Trigger Setting: {trigger_setting}")
                return True
            else:
                logger.error("Failed to set trigger setting.")
                return False

        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON data: {e}")
            return False

        except AttributeError as e:
            logger.error(f"Invalid interface or method: {e}")
            return False

        except Exception as e:
            logger.error(f"Unexpected error while setting trigger: {e}")
            return False

    @pyqtSlot(result=bool)
    def toggleTrigger(self):
        """Toggle the trigger state (start or stop)."""
        try:
            if self._trigger_state:
                # Stop the trigger
                success = self.interface.txdevice.stop_trigger()
                if success:
                    logger.info("Trigger stopped successfully.")
                    self._trigger_state = False
                else:
                    logger.error("Failed to stop trigger.")
            else:
                # Start the trigger
                success = self.interface.txdevice.start_trigger()
                if success:
                    logger.info("Trigger started successfully.")
                    self._trigger_state = True
                else:
                    logger.error("Failed to start trigger.")

            # Emit the updated trigger state
            self.triggerStateChanged.emit(self._trigger_state)
            return success

        except AttributeError as e:
            logger.error(f"Invalid interface or method: {e}")
            return False

        except Exception as e:
            logger.error(f"Unexpected error while toggling trigger: {e}")
            return False

    @pyqtSlot(result=bool)
    def queryTriggerInfo(self):
        """Query the trigger status and update the state accordingly.

        Returns:
            bool: True if the query was successful, False otherwise.
        """
        try:
            trigger_data = self.interface.txdevice.get_trigger_json()

            if isinstance(trigger_data, str):
                trigger_data = json.loads(trigger_data)

            self._update_trigger_state(trigger_data)
            return True

        except json.JSONDecodeError:
            logger.error("Failed to decode trigger status JSON.")
            return False

        except AttributeError as e:
            logger.error(f"Invalid interface or method: {e}")
            return False

        except Exception as e:
            logger.error(f"Unexpected error while querying trigger info: {e}")
            return False
        
    @pyqtSlot()
    def softResetHV(self):
        """reset hardware HV device."""
        try:
            if self.interface.hvcontroller.soft_reset():
                logger.info(f"Software Reset Sent")
            else:
                logger.error(f"Failed to send Software Reset")
        except Exception as e:
            logger.error(f"Error Sending Software Reset: {e}")

    @pyqtSlot()
    def toggleHV(self):
        """Toggle HV on console."""
        try:
            # Check the current state of HV
            if self.interface.hvcontroller.get_hv_status():
                # If HV is on, turn it off
                if self.interface.hvcontroller.turn_hv_off():
                    logger.info("HV turned off successfully")
                else:
                    logger.error("Failed to turn off HV")
            else:
                # If HV is off, turn it on
                if self.interface.hvcontroller.turn_hv_on():
                    logger.info("HV turned on successfully")
                else:
                    logger.error("Failed to turn on HV")
            hv_state = self.interface.hvcontroller.get_hv_status()            
            v12_state = self.interface.hvcontroller.get_12v_status()
            logger.info(f"HV State: {hv_state} - 12V State: {v12_state}")
            self.powerStatusReceived.emit(v12_state, hv_state)
        except Exception as e:
            logger.error(f"Error toggling HV: {e}")

    @pyqtSlot()
    def toggleV12(self):
        """Toggle V12 on console."""
        try:
            # Check the current state of HV
            if self.interface.hvcontroller.get_12v_status():
                # If HV is on, turn it off
                if self.interface.hvcontroller.turn_12v_off():
                    logger.info("V12 turned off successfully")
                else:
                    logger.error("Failed to turn off HV")
            else:
                # If HV is off, turn it on
                if self.interface.hvcontroller.turn_12v_on():
                    logger.info("V12 turned on successfully")
                else:
                    logger.error("Failed to turn on V12")
            hv_state = self.interface.hvcontroller.get_hv_status()            
            v12_state = self.interface.hvcontroller.get_12v_status()
            logger.info(f"HV State: {hv_state} - 12V State: {v12_state}")
            self.powerStatusReceived.emit(v12_state, hv_state)
        except Exception as e:
            logger.error(f"Error toggling HV: {e}")

    @pyqtSlot()
    def softResetTX(self):
        """reset hardware TX device."""
        try:
            if self.interface.txdevice.soft_reset():
                logger.info(f"Software Reset Sent")
            else:
                logger.error(f"Failed to send Software Reset")
        except Exception as e:
            logger.error(f"Error Sending Software Reset: {e}")
