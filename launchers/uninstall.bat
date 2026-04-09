@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: pullSWIFT Uninstaller for Windows
:: Removes the desktop shortcut and saved config.
:: ============================================================

echo ======================================
echo   SWIFT Telemetry GUI Uninstaller
echo ======================================
echo.

set "SCRIPT_DIR=%~dp0"
set "CONFIG=%SCRIPT_DIR%.pullswift_config"
set "SHORTCUT=%USERPROFILE%\Desktop\SWIFT Telemetry GUI.lnk"
set "REMOVED=0"

:: --- Remove desktop shortcut ---
if exist "!SHORTCUT!" (
    del "!SHORTCUT!"
    echo Removed: !SHORTCUT!
    set /a REMOVED+=1
) else (
    echo No shortcut found at !SHORTCUT!
)

:: --- Remove config ---
if exist "!CONFIG!" (
    del "!CONFIG!"
    echo Removed: !CONFIG!
    set /a REMOVED+=1
) else (
    echo No config file found.
)

echo.
if !REMOVED! GTR 0 (
    echo Uninstall complete.
) else (
    echo Nothing to remove.
)

pause
exit /b 0
