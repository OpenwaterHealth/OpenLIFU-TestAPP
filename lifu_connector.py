from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot
import logging
import numpy as np
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

    stateChanged = pyqtSignal()  # Notifies QML when state changes
    connectionStatusChanged = pyqtSignal()  # 🔹 New signal for connection updates

    def __init__(self, hv_test_mode=False):
        super().__init__()
        self.interface = LIFUInterface(HV_test_mode=hv_test_mode, run_async=True)
        self._txConnected = False
        self._hvConnected = False
        self._configured = False
        self._state = DISCONNECTED

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

    @pyqtSlot(str, str, str, str, str, str )
    def configure_transmitter(self, xInput, yInput, zInput, freq, voltage, triggerHZ):
        """Simulate configuring the transmitter."""
        if self._txConnected:
            pulse = Pulse(frequency=float(freq), amplitude=float(voltage), duration=2e-5)
            pt = Point(position=(int(xInput),int(yInput),int(zInput)), units="mm")
            sequence = Sequence(
                pulse_interval=0.1,
                pulse_count=10,
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
    