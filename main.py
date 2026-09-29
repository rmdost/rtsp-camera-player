"""
main.py – Application entry point.

Usage:
    python main.py [stream_file.txt]
"""

import sys
import os
import logging
import argparse
from pathlib import Path

# ── LibVLC bundled path resolution (for PyInstaller portable EXE) ─────────────
if getattr(sys, "frozen", False):
    base_dir = Path(getattr(sys, "_MEIPASS", Path(sys.executable).parent))
    vlc_dll = base_dir / "libvlc.dll"
    plugins_dir = base_dir / "plugins"
    if vlc_dll.exists():
        os.environ["PYTHON_VLC_LIB_PATH"] = str(vlc_dll)
    if plugins_dir.exists():
        os.environ["PYTHON_VLC_MODULE_PATH"] = str(plugins_dir)
        os.environ["VLC_PLUGIN_PATH"] = str(plugins_dir)
    if hasattr(os, "add_dll_directory") and base_dir.exists():
        try:
            os.add_dll_directory(str(base_dir))
        except Exception:
            pass

from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import Qt

from nvr_viewer.main_window import MainWindow

# ── Logging ────────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s  %(message)s",
    datefmt="%H:%M:%S",
)


def main():
    # High-DPI support
    QApplication.setHighDpiScaleFactorRoundingPolicy(
        Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
    )

    app = QApplication(sys.argv)
    app.setApplicationName("NVR Stream Viewer")
    app.setApplicationVersion("1.0.0")
    app.setOrganizationName("NVRViewer")

    # ── CLI argument: optional stream file ─────────────────────────────────────
    parser = argparse.ArgumentParser(description="RTSP NVR Stream Viewer")
    parser.add_argument(
        "stream_file",
        nargs="?",
        help="Path to stream definitions .txt file to load on startup",
    )
    args, _unknown = parser.parse_known_args()

    window = MainWindow()
    window.show()

    # Auto-load if file provided via CLI
    if args.stream_file:
        path = Path(args.stream_file)
        if path.is_file():
            from nvr_viewer.parser import parse_stream_file
            try:
                streams = parse_stream_file(path)
                window._load_streams(streams)
            except Exception as exc:
                logging.error("Failed to load %s: %s", path, exc)
        else:
            logging.warning("Stream file not found: %s", path)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
