@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: pullSWIFT Launcher for Windows
:: Stashes changes, checks out master, fast-forwards, launches
:: pullSWIFTtelemetryGUI in MATLAB.
::
:: First run: prompts for repo path and saves to config file.
:: MATLAB: auto-detected from Program Files.
:: ============================================================

set "CONFIG=%~dp0.pullswift_config"

:: --- Load or create config ---
if exist "%CONFIG%" (
    for /f "usebackq delims=" %%A in ("%CONFIG%") do set "REPO_PATH=%%A"
) else (
    echo First-time setup: enter the full path to your SWIFT-codes repo.
    echo Example: C:\Users\you\Dropbox\phd\code\SWIFT-codes
    set /p "REPO_PATH=Repo path: "
    echo !REPO_PATH!> "%CONFIG%"
    echo Saved to %CONFIG%.
)

:: --- Validate repo path ---
if not exist "!REPO_PATH!\.git" (
    echo ERROR: "!REPO_PATH!" is not a git repository.
    echo Delete %CONFIG% and re-run to reconfigure.
    pause
    exit /b 1
)

:: --- Find MATLAB (picks newest version via alphabetical glob order) ---
set "MATLAB_EXE="
for /d %%D in ("C:\Program Files\MATLAB\R*") do (
    if exist "%%D\bin\matlab.exe" set "MATLAB_EXE=%%D\bin\matlab.exe"
)
if not defined MATLAB_EXE (
    for /d %%D in ("C:\Program Files (x86)\MATLAB\R*") do (
        if exist "%%D\bin\matlab.exe" set "MATLAB_EXE=%%D\bin\matlab.exe"
    )
)
if not defined MATLAB_EXE (
    echo ERROR: Could not find MATLAB. Install it or add matlab.exe to your PATH.
    pause
    exit /b 1
)
echo Found MATLAB: !MATLAB_EXE!

:: --- Git operations ---
echo.
cd /d "!REPO_PATH!"

for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD') do set "CURRENT_BRANCH=%%B"

if "!CURRENT_BRANCH!"=="master" (
    echo Already on master. Pulling latest...
    echo [1/2] Stashing local changes...
    git stash
    echo [2/2] Fast-forwarding...
    git pull --ff-only
    if errorlevel 1 (
        echo WARNING: Fast-forward failed. You may need to pull/merge manually.
        pause
        exit /b 1
    )
) else (
    echo Currently on branch: !CURRENT_BRANCH!
    set /p "REPLY=Switch to master and pull latest? [Y/n]: "
    if not defined REPLY set "REPLY=Y"
    if /i "!REPLY!"=="Y" (
        echo [1/3] Stashing local changes...
        git stash
        echo [2/3] Checking out master...
        git checkout master
        if errorlevel 1 (
            echo ERROR: Could not checkout master. Resolve manually.
            pause
            exit /b 1
        )
        echo [3/3] Fast-forwarding...
        git pull --ff-only
        if errorlevel 1 (
            echo WARNING: Fast-forward failed. You may need to pull/merge manually.
            pause
            exit /b 1
        )
    ) else (
        echo Staying on branch: !CURRENT_BRANCH!
    )
)

:: --- Launch MATLAB ---
echo.
echo Launching pullSWIFTtelemetryGUI...
start "" "!MATLAB_EXE!" -r "cd('!REPO_PATH!\GeneralTools'); pullSWIFTtelemetryGUI"

echo Done. MATLAB is starting.
exit /b 0
