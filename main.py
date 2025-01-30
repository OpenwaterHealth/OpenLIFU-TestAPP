import sys
import os
import warnings
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal
from scripts.generate_ultrasound_plot import generate_ultrasound_plot  # Import the function directly

# Suppress PyQt6 DeprecationWarnings related to SIP
warnings.simplefilter("ignore", DeprecationWarning)

class UltrasoundController(QObject):
    plotGenerated = pyqtSignal(str)  # Signal to notify QML when a new plot is ready

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

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    os.environ["QT_QUICK_CONTROLS_MATERIAL_THEME"] = "Dark"

    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon("assets/images/favicon.png"))

    engine = QQmlApplicationEngine()

    controller = UltrasoundController()
    engine.rootContext().setContextProperty("UltrasoundController", controller)

    engine.load("main.qml")

    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
