; ─────────────────────────────────────────────────────────────────────────────
; NVR Stream Viewer – Inno Setup 6 installer script
;
; Prerequisites:
;   1. Build with PyInstaller first:  pyinstaller nvr_viewer.spec
;   2. Install Inno Setup 6 from https://jrsoftware.org/isinfo.php
;   3. Compile this script:  iscc installer.iss
;
; Output: Output\NVRStreamViewerSetup.exe
; ─────────────────────────────────────────────────────────────────────────────

#define AppName      "NVR Stream Viewer"
#define AppVersion   "1.0.0"
#define AppPublisher "NVRViewer"
#define AppURL       "https://github.com/yourname/nvr-stream-viewer"
#define AppExeName   "NVRStreamViewer.exe"
#define BuildDir     "dist\NVRStreamViewer"

[Setup]
AppId={{A7C3D9F2-4B81-4E8A-9D06-2F1E3C8B5A74}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
; Output installer to the Output subfolder
OutputDir=Output
OutputBaseFilename=NVRStreamViewerSetup
; Compress everything with LZMA2
Compression=lzma2/ultra64
SolidCompression=yes
; Require Windows 10 or later (for HEVC support)
MinVersion=10.0
; 64-bit only
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern
; Uninstall support
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
; Main application bundle (produced by PyInstaller)
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";        DestPath: "{app}\{#AppExeName}"
Name: "{group}\Uninstall {#AppName}"; DestPath: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";  DestPath: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Optional: detect and warn if VLC is not present (belt-and-suspenders check)
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
