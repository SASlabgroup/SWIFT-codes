@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: pullSWIFT Installer for Windows
:: Creates a desktop shortcut that launches pullSWIFTtelemetryGUI.bat
:: with the SWIFT logo icon.
:: ============================================================

echo ======================================
echo   SWIFT Telemetry Installer
echo ======================================
echo.

set "SCRIPT_DIR=%~dp0"
set "LAUNCHER=%SCRIPT_DIR%pullSWIFTtelemetryGUI.bat"
:: Icon lives in Documents/ one level up from launchers/
set "REPO_ROOT=%SCRIPT_DIR%.."
set "ICON=%REPO_ROOT%\Documents\SWIFTlogo_icon.png"
set "DESKTOP=%USERPROFILE%\Desktop"

:: --- Validate files exist ---
if not exist "!LAUNCHER!" (
    echo ERROR: pullSWIFTtelemetryGUI.bat not found in %SCRIPT_DIR%
    pause
    exit /b 1
)

:: --- Create shortcut via VBScript ---
echo Creating desktop shortcut...

set "VBS=%TEMP%\create_pullswift_shortcut.vbs"

> "!VBS!" echo Set oWS = WScript.CreateObject("WScript.Shell")
>> "!VBS!" echo sLinkFile = oWS.ExpandEnvironmentStrings("!DESKTOP!\SWIFT Telemetry.lnk")
>> "!VBS!" echo Set oLink = oWS.CreateShortcut(sLinkFile)
>> "!VBS!" echo oLink.TargetPath = "!LAUNCHER!"
>> "!VBS!" echo oLink.Arguments = "--from-icon"
>> "!VBS!" echo oLink.WorkingDirectory = "!SCRIPT_DIR!"
>> "!VBS!" echo oLink.Description = "SWIFT Telemetry - Update SWIFT-codes and launch pullSWIFTtelemetryGUI"
>> "!VBS!" echo oLink.WindowStyle = 1
:: Note: Windows shortcuts require .ico for icons. If an .ico exists, use it.
if exist "!REPO_ROOT!\Documents\SWIFTlogo_icon.ico" (
    >> "!VBS!" echo oLink.IconLocation = "!REPO_ROOT!\Documents\SWIFTlogo_icon.ico"
)
>> "!VBS!" echo oLink.Save

cscript //nologo "!VBS!"
del "!VBS!"

if exist "!DESKTOP!\SWIFT Telemetry.lnk" (
    echo.
    echo ======================================
    echo   Installation complete!
    echo ======================================
    echo   Shortcut created: !DESKTOP!\SWIFT Telemetry.lnk
    echo   Double-click it to launch.
    echo.
    if not exist "!REPO_ROOT!\Documents\SWIFTlogo_icon.ico" (
        echo   NOTE: To use the SWIFT icon, convert Documents\SWIFTlogo_icon.png to .ico
        echo   format and place it in Documents\ as SWIFTlogo_icon.ico, then re-run
        echo   this installer.
        echo.
    )
) else (
    echo.
    echo ERROR: Failed to create shortcut.
    echo.
)

pause
exit /b 0
