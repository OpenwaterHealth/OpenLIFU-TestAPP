from PyQt6.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
import logging

from scripts.generate_ultrasound_plot import generate_ultrasound_plot  # Import the function directly
from openlifu.io.LIFUInterface import LIFUInterface

logger = logging.getLogger(__name__)

class UltrasoundController(QObject):
    plotGenerated = pyqtSignal(str)  # Signal to notify QML when a new plot is ready
    connectionStatusChanged = pyqtSignal()  # Signal to notify QML when connection status changes
    solutionConfigured = pyqtSignal(str)  # Optional signal for solution configuration feedback

    def __init__(self, parent = ...):
        super().__init__()
                
        print("Starting LIFU Test Script...")
        self.interface = LIFUInterface(test_mode=False)
        self._tx_connected, self._hv_connected = self.interface.is_device_connected()
        if self._tx_connected and self._hv_connected:
            logger.debug("LIFU Device Fully connected.")
        else:
            logger.debug(f'LIFU Device NOT Fully Connected. TX: {self._tx_connected}, HV: {self._hv_connected}')


    # Getter for txConnected property
    @pyqtProperty(bool, notify=connectionStatusChanged)
    def txConnected(self):
        return self._tx_connected

    # Getter for hvConnected property
    @pyqtProperty(bool, notify=connectionStatusChanged)
    def hvConnected(self):
        return self._hv_connected

    # Optional: A slot to refresh/update the connection status
    @pyqtSlot()
    def updateConnectionStatus(self):
        self._tx_connected, self._hv_connected = self.interface.is_device_connected()
        self.connectionStatusChanged.emit()

    @pyqtSlot(str, float)
    def configureSolution(self, solutionName, amplitude):
        """
        Slot to configure the solution.
        
        Args:
            solutionName (str): The name of the solution.
            amplitude (float): The amplitude value to use.
        """
        try:
            logger.debug("Configuring solution: %s with amplitude: %s", solutionName, amplitude)
            # Create a fake solution using the provided parameters
            solution = None
            # Call set_solution on your interface
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
        try:
            print(f"Generating plot with mode={mode}: X={x}, Y={y}, Z={z}, Frequency={freq}, Cycles={cycles}, Trigger={trigger}")

            # Directly call the function instead of using subprocess
            image_data = generate_ultrasound_plot(x, y, z, freq, cycles, trigger, mode)

            if image_data == "ERROR":
                print("Error: Plot generation failed")
            else:
                print("Plot generated successfully")
                self.plotGenerated.emit(image_data)  # Send the image path or Base64 data to QML

        except Exception as e:
            print(f"Error generating plot: {e}")
