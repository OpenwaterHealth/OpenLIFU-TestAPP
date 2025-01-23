import sys
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

def main():
    app = QGuiApplication(sys.argv)
    # Set the global application icon
    app.setWindowIcon(QIcon("assets/images/favicon.png"))
    engine = QQmlApplicationEngine()

    # Load the QML file
    engine.load("main.qml")

    # Exit the application if QML fails to load
    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
