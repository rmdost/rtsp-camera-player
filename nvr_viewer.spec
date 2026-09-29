# -*- mode: python ; coding: utf-8 -*-
"""
NVR Stream Viewer – PyInstaller spec file.

Build with:
    pyinstaller nvr_viewer.spec

Output: dist/NVRStreamViewer/NVRStreamViewer.exe  (one-folder bundle)
Or:     dist/NVRStreamViewer.exe                  (one-file bundle, slower startup)
"""

import sys
import os
from pathlib import Path
import glob

# ── Locate VLC DLLs ──────────────────────────────────────────────────────────
# python-vlc ships the VLC binaries together with the wheel on Windows.
# We need to bundle libvlc.dll, libvlccore.dll and the plugins/ folder.

def find_vlc_dir() -> Path:
    """Return the directory that contains libvlc.dll."""
    import vlc
    vlc_py = Path(vlc.__file__).parent
    # Check if DLLs are co-located with the vlc.py file (typical wheel layout)
    if (vlc_py / "libvlc.dll").exists():
        return vlc_py
    # Fall back to a system VLC install
    program_files = Path(os.environ.get("ProgramFiles", r"C:\Program Files"))
    vlc_system = program_files / "VideoLAN" / "VLC"
    if vlc_system.exists():
        return vlc_system
    raise RuntimeError(
        "Cannot locate libvlc.dll. "
        "Install python-vlc wheel or VLC from https://www.videolan.org"
    )


vlc_dir = find_vlc_dir()

# Collect VLC DLLs and plugins
vlc_binaries = []
vlc_datas    = []

for dll in vlc_dir.glob("*.dll"):
    vlc_binaries.append((str(dll), "."))

plugins_dir = vlc_dir / "plugins"
if plugins_dir.exists():
    for f in plugins_dir.rglob("*"):
        if f.is_file():
            rel = str(f.relative_to(vlc_dir))
            vlc_datas.append((str(f), str(Path(rel).parent)))


# ── Analysis ──────────────────────────────────────────────────────────────────
a = Analysis(
    ["main.py"],
    pathex=[],
    binaries=vlc_binaries,
    datas=vlc_datas,
    hiddenimports=[
        "vlc",
        "PyQt6.QtCore",
        "PyQt6.QtGui",
        "PyQt6.QtWidgets",
        "nvr_viewer",
        "nvr_viewer.models",
        "nvr_viewer.parser",
        "nvr_viewer.player",
        "nvr_viewer.grid",
        "nvr_viewer.main_window",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=["tkinter", "unittest", "email", "xmlrpc", "pydoc"],
    noarchive=False,
    optimize=1,
)

pyz = PYZ(a.pure)

# ── Standalone Portable Single-File EXE ──────────────────────────────────────
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="NVRStreamViewer",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,          # no console window (clean GUI)
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
