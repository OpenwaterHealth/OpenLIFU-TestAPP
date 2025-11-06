# rthooks/qt_paths.py
import os, sys

# In a frozen app, use the folder that contains the EXE as base.
base = os.path.dirname(sys.executable) if getattr(sys, "frozen", False) else os.path.dirname(__file__)
qt_root = os.path.join(base, "PyQt6", "Qt6")
plugins = os.path.join(qt_root, "plugins")
qml_dir = os.path.join(qt_root, "qml")

# Make sure Qt finds its stuff
def _prepend_env(name, value):
    if os.path.isdir(value):
        os.environ[name] = value + os.pathsep + os.environ.get(name, "")

_prepend_env("QT_PLUGIN_PATH", plugins)
_prepend_env("QT_QPA_PLATFORM_PLUGIN_PATH", os.path.join(plugins, "platforms"))
_prepend_env("QML2_IMPORT_PATH", qml_dir)

# Helpful while diagnosing
os.environ.setdefault("QT_DEBUG_PLUGINS", "1")
