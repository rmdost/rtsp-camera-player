@echo off
setlocal EnableDelayedExpansion

:: ─────────────────────────────────────────────────────────────────────────────
:: build.bat  –  Full build pipeline for NVR Stream Viewer
::
:: Steps:
::   1. (Optional) Create / activate virtual environment
::   2. Install Python dependencies
::   3. Run PyInstaller to produce dist\NVRStreamViewer\
::   4. (Optional) Run Inno Setup to produce a single-file Windows installer
::
:: Usage:
::   build.bat              – build EXE only
::   build.bat --installer  – build EXE + Inno Setup installer
:: ─────────────────────────────────────────────────────────────────────────────

set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%venv"
set "BUILD_INSTALLER=0"

if "%~1"=="--installer" set "BUILD_INSTALLER=1"

echo.
echo  ███╗   ██╗██╗   ██╗██████╗     ██╗   ██╗██╗███████╗██╗    ██╗███████╗██████╗
echo  ████╗  ██║██║   ██║██╔══██╗    ██║   ██║██║██╔════╝██║    ██║██╔════╝██╔══██╗
echo  ██╔██╗ ██║██║   ██║██████╔╝    ██║   ██║██║█████╗  ██║ █╗ ██║█████╗  ██████╔╝
echo  ██║╚██╗██║╚██╗ ██╔╝██╔══██╗    ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║██╔══╝  ██╔══██╗
echo  ██║ ╚████║ ╚████╔╝ ██║  ██║     ╚████╔╝ ██║███████╗╚███╔███╔╝███████╗██║  ██║
echo  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝  ╚═╝      ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝
echo.
echo  Build Script v1.0  ^|  NVR Stream Viewer
echo  ─────────────────────────────────────────
echo.

:: ── Step 1: Virtual environment ───────────────────────────────────────────────
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo [1/4] Creating virtual environment …
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo  ERROR: Failed to create virtual environment. Ensure Python 3.10+ is installed.
        exit /b 1
    )
) else (
    echo [1/4] Virtual environment found.
)

call "%VENV_DIR%\Scripts\activate.bat"

:: ── Step 2: Install dependencies ──────────────────────────────────────────────
echo [2/4] Installing / upgrading dependencies …
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt
pip install --quiet pyinstaller

if errorlevel 1 (
    echo  ERROR: pip install failed.
    exit /b 1
)
echo  Dependencies OK.
echo.

:: ── Step 3: PyInstaller ───────────────────────────────────────────────────────
echo [3/4] Running PyInstaller …
if exist "%SCRIPT_DIR%dist\NVRStreamViewer" (
    echo  Cleaning previous build …
    rmdir /s /q "%SCRIPT_DIR%dist\NVRStreamViewer"
)
if exist "%SCRIPT_DIR%build" (
    rmdir /s /q "%SCRIPT_DIR%build"
)

pyinstaller nvr_viewer.spec --noconfirm

if errorlevel 1 (
    echo  ERROR: PyInstaller build failed.
    exit /b 1
)
echo  PyInstaller build complete: dist\NVRStreamViewer\NVRStreamViewer.exe
echo.

:: ── Step 4: (Optional) Inno Setup ─────────────────────────────────────────────
if "%BUILD_INSTALLER%"=="1" (
    echo [4/4] Building Inno Setup installer …

    set "ISCC="
    for %%P in (
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
        "C:\Program Files\Inno Setup 6\ISCC.exe"
    ) do (
        if exist %%P set "ISCC=%%P"
    )

    if "!ISCC!"=="" (
        echo  WARNING: Inno Setup not found. Skipping installer build.
        echo  Download from https://jrsoftware.org/isinfo.php
    ) else (
        if not exist "%SCRIPT_DIR%Output" mkdir "%SCRIPT_DIR%Output"
        !ISCC! installer.iss
        if errorlevel 1 (
            echo  ERROR: Inno Setup build failed.
            exit /b 1
        )
        echo  Installer ready: Output\NVRStreamViewerSetup.exe
    )
) else (
    echo [4/4] Skipping installer build (pass --installer flag to enable).
)

echo.
echo  ✓ Build complete!
echo  Run:  dist\NVRStreamViewer\NVRStreamViewer.exe
echo.
pause
