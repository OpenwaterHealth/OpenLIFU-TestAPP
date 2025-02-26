import asyncio
import logging
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from openlifu.io.LIFUInterface import LIFUInterface

logger = logging.getLogger(__name__)

class LIFUConnector(QObject):
    signal_connected = pyqtSignal(str)  # Emitted when device connects
    signal_disconnected = pyqtSignal()  # Emitted when device disconnects
    signal_data_received = pyqtSignal(str)  # Emitted when data is received

    def __init__(self, ultrasound_controller):
        super().__init__()
        self.interface = LIFUInterface(run_async=True)
        self.treatment_running = False
        self.connected_status = False  
        self.ultrasound_controller = ultrasound_controller  # Store reference to update UI

        self.connect_signals()

    def connect_signals(self):
        """Connect LIFU signals to QML bridge and UltrasoundController."""
        if hasattr(self.interface.txdevice, 'uart'):
            self.interface.txdevice.uart.signal_connect.connect(self.on_connected)
            self.interface.txdevice.uart.signal_disconnect.connect(self.on_disconnected)
            self.interface.txdevice.uart.signal_data_received.connect(self.on_data_received)
        else:
            logger.warning("UART interface not found in LIFUInterface.")

    async def start_monitoring(self):
        """Start monitoring for USB device connections asynchronously."""
        await self.interface.start_monitoring()

    @pyqtSlot(str)
    def on_connected(self, port):
        """Handle LIFU device connection."""
        self.connected_status = True
        self.signal_connected.emit(f"Connected to {port}")
        self.ultrasound_controller.set_tx_connected(True)  # Update UI

    @pyqtSlot()
    def on_disconnected(self):
        """Handle LIFU device disconnection."""
        self.connected_status = False
        self.signal_disconnected.emit()
        self.ultrasound_controller.set_tx_connected(False)  # Update UI

    @pyqtSlot(str)
    def on_data_received(self, data):
        """Handle data received from LIFU device and emit to QML."""
        logger.info(f"Data received: {data}")
        self.signal_data_received.emit(data)  # Send data to QML

    async def cleanup_tasks(self):
        """Stop monitoring and cancel running asyncio tasks."""
        self.interface.stop_monitoring()
        loop = asyncio.get_running_loop()
        tasks = [t for t in asyncio.all_tasks(loop) if t is not asyncio.current_task()]
        for task in tasks:
            task.cancel()
        await asyncio.gather(*tasks, return_exceptions=True)
