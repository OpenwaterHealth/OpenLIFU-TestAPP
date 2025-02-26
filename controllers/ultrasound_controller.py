from PyQt6.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
import logging
from scripts.generate_ultrasound_plot import generate_ultrasound_plot  # Import the function directly

logger = logging.getLogger(__name__)

class UltrasoundController(QObject):
    plotGenerated = pyqtSignal(str)  # Signal to notify QML when a new plot is ready
    connectionStatusChanged = pyqtSignal()  # Signal when connection changes
    solutionConfigured = pyqtSignal(str)  # Signal for solution configuration feedback

    def __init__(self, parent=None):
        super().__init__(parent)
        self._hv_connected = False
        self._tx_connected = False

    # Getter for txConnected property
    @pyqtProperty(bool, notify=connectionStatusChanged)
    def txConnected(self):
        return self._tx_connected

    # Getter for hvConnected property
    @pyqtProperty(bool, notify=connectionStatusChanged)
    def hvConnected(self):
        return self._hv_connected

    @pyqtSlot(bool)
    def set_tx_connected(self, status):
        """Updates TX connection status and notifies QML."""
        if self._tx_connected != status:
            self._tx_connected = status
            logger.info(f"TX Connection updated: {status}")
            self.connectionStatusChanged.emit()

    @pyqtSlot(bool)
    def set_hv_connected(self, status):
        """Updates HV connection status and notifies QML."""
        if self._hv_connected != status:
            self._hv_connected = status
            logger.info(f"HV Connection updated: {status}")
            self.connectionStatusChanged.emit()

    @pyqtSlot()
    def updateConnectionStatus(self):
        """Checks connection status and updates accordingly."""
        self._tx_connected, self._hv_connected = self.interface.is_device_connected()
        self.connectionStatusChanged.emit()

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
