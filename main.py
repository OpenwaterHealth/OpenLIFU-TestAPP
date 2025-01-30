import sys
import os
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"  # Forces Material Design
    os.environ["QT_QUICK_CONTROLS_MATERIAL_THEME"] = "Dark"

    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon("assets/images/favicon.png"))

    engine = QQmlApplicationEngine()
    engine.load("main.qml")

    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
