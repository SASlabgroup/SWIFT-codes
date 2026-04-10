@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: pullSWIFT Launcher for Windows
:: Stashes changes, checks out master, fast-forwards, launches
:: pullSWIFTtelemetryGUI in MATLAB.
::
:: Repo path is derived from this script's location (launchers/
:: lives inside the SWIFT-codes repo, parent is the repo root).
:: MATLAB: auto-detected from Program Files.
:: Config (.pullswift_config) only stores the master-branch behavior.
:: ============================================================

set "CONFIG=%~dp0.pullswift_config"

:: --- Detect desktop-icon launch ---
:: The .lnk shortcut passes --from-icon so we know to pause before
:: closing the window. Direct shell runs skip the pause.
set "FROM_ICON=false"
if "%~1"=="--from-icon" set "FROM_ICON=true"

:: --- Derive repo path from script location (parent of launchers/) ---
for %%I in ("%~dp0..") do set "REPO_PATH=%%~fI"

:: --- Validate repo path ---
if not exist "!REPO_PATH!\.git" (
    echo ERROR: "!REPO_PATH!" is not a git repository.
    echo This launcher must live inside SWIFT-codes\launchers\.
    pause
    exit /b 1
)

:: --- Load config (optional) ---
:: Config format: a single line, master_behavior=always or master_behavior=never
set "ALWAYS_PULL_MASTER=false"
set "NEVER_SWITCH_MASTER=false"

if exist "%CONFIG%" (
    for /f "usebackq delims=" %%A in ("%CONFIG%") do (
        if "%%A"=="always_pull_master=true" set "ALWAYS_PULL_MASTER=true"
        if "%%A"=="master_behavior=always" set "ALWAYS_PULL_MASTER=true"
        if "%%A"=="master_behavior=never" set "NEVER_SWITCH_MASTER=true"
    )
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
) else if "!ALWAYS_PULL_MASTER!"=="true" (
    echo Currently on branch: !CURRENT_BRANCH!
    echo Always-pull-master is enabled ^(config^). Switching to master...
    call :switch_to_master
) else if "!NEVER_SWITCH_MASTER!"=="true" (
    echo Currently on branch: !CURRENT_BRANCH!
    echo Never-switch-master is enabled ^(config^). Staying on !CURRENT_BRANCH!.
) else (
    echo Currently on branch: !CURRENT_BRANCH!
    echo.
    echo Switch to master and pull latest?
    echo   Y      = yes, switch this time
    echo   n      = no, stay on !CURRENT_BRANCH! this time
    echo   always = always switch to master ^(saves to config^)
    echo   never  = never switch to master ^(saves to config^)
    echo.
    set /p "REPLY=Choice [Y/n/always/never]: "
    if not defined REPLY set "REPLY=Y"
    if /i "!REPLY!"=="always" (
        echo.
        echo WARNING: This will save 'always pull master' to your config.
        echo Each launch will stash your changes and switch to master.
        echo To undo, delete %CONFIG%
        echo.
        set /p "CONFIRM=Confirm? [y/N]: "
        if /i "!CONFIRM!"=="y" (
            echo master_behavior=always> "%CONFIG%"
            echo Saved. You can undo this by deleting %CONFIG%
            call :switch_to_master
        ) else (
            echo Not saved. Staying on branch: !CURRENT_BRANCH!
        )
    ) else if /i "!REPLY!"=="never" (
        echo.
        echo WARNING: This will save 'never switch to master' to your config.
        echo You will no longer be prompted at launch; the GUI will open
        echo from whatever branch you're currently on.
        echo To undo, delete %CONFIG%
        echo.
        set /p "CONFIRM=Confirm? [y/N]: "
        if /i "!CONFIRM!"=="y" (
            echo master_behavior=never> "%CONFIG%"
            echo Saved. You can undo this by deleting %CONFIG%
            echo Staying on branch: !CURRENT_BRANCH!
        ) else (
            echo Not saved. Staying on branch: !CURRENT_BRANCH!
        )
    ) else if /i "!REPLY!"=="Y" (
        call :switch_to_master
    ) else (
        echo Staying on branch: !CURRENT_BRANCH!
    )
)

:: --- Launch MATLAB ---
echo.
echo Launching pullSWIFTtelemetryGUI...
start "" "!MATLAB_EXE!" -r "cd('!REPO_PATH!\GeneralTools'); pullSWIFTtelemetryGUI"

echo Done. MATLAB is starting.
if "!FROM_ICON!"=="true" (
    echo.
    echo This window will automatically close in 10 seconds.
    timeout /t 10 /nobreak > nul
)
exit /b 0

:switch_to_master
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
goto :eof
