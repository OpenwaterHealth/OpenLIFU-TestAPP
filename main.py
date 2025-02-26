import sys
import os
import warnings
import logging
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal
from controllers.ultrasound_controller import UltrasoundController

from openlifu.io.LIFUInterface import LIFUInterface

logger = logging.getLogger(__name__)

# Suppress PyQt6 DeprecationWarnings related to SIP
warnings.simplefilter("ignore", DeprecationWarning)

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
