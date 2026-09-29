# NVR Stream Viewer

A standalone Windows desktop application for viewing multiple RTSP camera
streams with native HEVC (H.265) and H.264 hardware-accelerated playback.

Built with Python 3.10+, PyQt6, and LibVLC.

---

## Features

- Native HEVC / H.264 playback via LibVLC (no transcoding)
- Dynamic grid: 1x1, 2x2, 3x3, 4x4 auto-layout
- Single-click fullscreen; double-click / ESC to return
- Per-tile MAIN / SUB stream toggle
- Auto-reconnect with exponential back-off
- Open .txt file or paste definitions directly
- CLI: `python main.py streams.txt`

---

## Stream File Format

```
NVR-1 | CH01 MAIN | hevc,2560,1440
rtsp://admin:pass@192.168.0.23:554/Streaming/Channels/101

NVR-1 | CH02 MAIN | h264,1920,1080
rtsp://admin:pass@192.168.0.23:554/Streaming/Channels/201
```

Blank lines and # comments are ignored.

SUB stream URL auto-derivation:
  Hikvision: .../Channels/101 -> .../Channels/102
  Dahua:     ...subtype=0    -> ...subtype=1
  Generic:   appends ?subtype=1

---

## Quick Start

```powershell
pip install -r requirements.txt
python main.py
```

---

## Keyboard Controls

  Single-click tile  -> Fullscreen
  Double-click / ESC -> Back to grid
  Ctrl+O             -> Open stream file
  Ctrl+V             -> Paste definitions
  F11                -> App fullscreen
  Ctrl+Q             -> Quit

---

## Build Standalone EXE

Option A - One-folder bundle (recommended):
  pip install pyinstaller
  pyinstaller nvr_viewer.spec --noconfirm
  -> dist\NVRStreamViewer\NVRStreamViewer.exe

Option B - Full build + Windows installer:
  build.bat --installer
  -> dist\NVRStreamViewer\NVRStreamViewer.exe
  -> Output\NVRStreamViewerSetup.exe
  (requires Inno Setup 6: https://jrsoftware.org/isinfo.php)

---

## Project Structure

  main.py              - Entry point
  requirements.txt     - Dependencies (PyQt6, python-vlc)
  nvr_viewer.spec      - PyInstaller spec
  installer.iss        - Inno Setup 6 script
  build.bat            - One-click build
  streams.txt          - Sample stream file
  nvr_viewer/
    models.py          - StreamInfo dataclass
    parser.py          - File / paste parser
    player.py          - LibVLC tile + auto-reconnect
    grid.py            - Grid layout + fullscreen
    main_window.py     - Main window

---

## Troubleshooting

  Black screen          -> Test URL in VLC directly
  ImportError: vlc      -> pip install python-vlc
  HEVC not decoding     -> Update GPU drivers / VLC 3.x
  High CPU              -> Set --avcodec-hw=d3d11va in player.py
  EXE fails on other PC -> Ship entire dist\NVRStreamViewer\ folder
