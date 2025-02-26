import sys
import os
import asyncio
import warnings
import logging
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine
from qasync import QEventLoop
from controllers.ultrasound_controller import UltrasoundController
from lifu_connector import LIFUConnector

logger = logging.getLogger(__name__)

# Suppress PyQt6 DeprecationWarnings related to SIP
warnings.simplefilter("ignore", DeprecationWarning)

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    os.environ["QT_QUICK_CONTROLS_MATERIAL_THEME"] = "Dark"

    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon("assets/images/favicon.png"))

    engine = QQmlApplicationEngine()

    # Initialize controllers
    ultrasound_controller = UltrasoundController()
    lifu_connector = LIFUConnector(ultrasound_controller)  # Pass controller to LIFUConnector

    # Expose controllers to QML
    engine.rootContext().setContextProperty("UltrasoundController", ultrasound_controller)
    engine.rootContext().setContextProperty("LIFUConnector", lifu_connector)

    engine.load("main.qml")

    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        sys.exit(-1)

    # Create an asyncio event loop
    loop = QEventLoop(app)
    asyncio.set_event_loop(loop)

    async def main_async():
        """Main async function that starts monitoring and handles exceptions."""
        try:
            await lifu_connector.start_monitoring()
        except asyncio.CancelledError:
            logger.info("Async monitoring task cancelled.")
        except Exception as e:
            logger.error(f"Error in main_async: {e}", exc_info=True)
        finally:
            logger.info("Shutting down event loop gracefully.")

    try:
        with loop:
            loop.run_until_complete(main_async())  # Ensure this completes
            loop.run_forever()  # Keep the app running
    except RuntimeError as e:
        logger.error(f"Runtime error: {e}")
    except KeyboardInterrupt:
        logger.info("Application interrupted.")
    finally:
        loop.close()  # Ensure loop is closed

if __name__ == "__main__":
    main()
