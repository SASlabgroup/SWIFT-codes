#!/usr/bin/env bash
# ============================================================
# pullSWIFT Launcher for macOS / Linux
# Stashes changes, checks out master, fast-forwards, launches
# pullSWIFTtelemetryGUI in MATLAB.
#
# Repo path is derived from this script's location (launchers/ lives
# inside the SWIFT-codes repo, so the parent is the repo root).
# MATLAB: auto-detected from standard install locations.
# Config (.pullswift_config) only stores the master-branch behavior.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_PATH="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$SCRIPT_DIR/.pullswift_config"

# When launched from the desktop icon, the .app bundle / .desktop file
# passes --from-icon so we know to pause before closing the terminal
# (so the user can read any notes). When run directly from a shell we
# skip the pause.
FROM_ICON="false"
if [ "$1" = "--from-icon" ]; then
    FROM_ICON="true"
fi

# Ensure reads come from the terminal, not piped stdin
exec < /dev/tty

# --- Validate repo path ---
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "ERROR: '$REPO_PATH' is not a git repository."
    echo "This launcher must live inside SWIFT-codes/launchers/."
    echo "Press Enter to close."
    read -r
    exit 1
fi

# --- Load config (optional) ---
# Config format: a single line, master_behavior=always|never
ALWAYS_PULL_MASTER="false"
NEVER_SWITCH_MASTER="false"
if [ -f "$CONFIG" ]; then
    LINE="$(sed -n '1p' "$CONFIG")"
    # Also accept 2-line legacy format (old repo path on line 1)
    if [ "$LINE" = "master_behavior=always" ] || [ "$LINE" = "always_pull_master=true" ]; then
        ALWAYS_PULL_MASTER="true"
    elif [ "$LINE" = "master_behavior=never" ]; then
        NEVER_SWITCH_MASTER="true"
    else
        LINE2="$(sed -n '2p' "$CONFIG")"
        if [ "$LINE2" = "master_behavior=always" ] || [ "$LINE2" = "always_pull_master=true" ]; then
            ALWAYS_PULL_MASTER="true"
        elif [ "$LINE2" = "master_behavior=never" ]; then
            NEVER_SWITCH_MASTER="true"
        fi
    fi
fi

# --- Find MATLAB (picks newest version via alphabetical glob order) ---
MATLAB_EXE=""

if [ "$(uname)" = "Darwin" ]; then
    for app in /Applications/MATLAB_R*.app; do
        if [ -x "$app/bin/matlab" ]; then
            MATLAB_EXE="$app/bin/matlab"
        fi
    done
else
    for dir in /usr/local/MATLAB/R*; do
        if [ -x "$dir/bin/matlab" ]; then
            MATLAB_EXE="$dir/bin/matlab"
        fi
    done
fi

# Fallback: check PATH
if [ -z "$MATLAB_EXE" ]; then
    MATLAB_EXE="$(command -v matlab 2>/dev/null || true)"
fi

if [ -z "$MATLAB_EXE" ]; then
    echo "ERROR: Could not find MATLAB. Install it or add 'matlab' to your PATH."
    echo "Press Enter to close."
    read -r
    exit 1
fi

echo "Found MATLAB: $MATLAB_EXE"

# --- Git operations ---
echo ""
cd "$REPO_PATH"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

switch_to_master() {
    echo "[1/3] Stashing local changes..."
    git stash || true
    echo "[2/3] Checking out master..."
    git checkout master
    echo "[3/3] Fast-forwarding..."
    git pull --ff-only
}

if [ "$CURRENT_BRANCH" = "master" ]; then
    echo "Already on master. Pulling latest..."
    echo "[1/2] Stashing local changes..."
    git stash || true
    echo "[2/2] Fast-forwarding..."
    git pull --ff-only
elif [ "$ALWAYS_PULL_MASTER" = "true" ]; then
    echo "Currently on branch: $CURRENT_BRANCH"
    echo "Always-pull-master is enabled (config). Switching to master..."
    switch_to_master
elif [ "$NEVER_SWITCH_MASTER" = "true" ]; then
    echo "Currently on branch: $CURRENT_BRANCH"
    echo "Never-switch-master is enabled (config). Staying on $CURRENT_BRANCH."
else
    echo "Currently on branch: $CURRENT_BRANCH"
    echo ""
    echo "Switch to master and pull latest?"
    echo "  Y      = yes, switch this time"
    echo "  n      = no, stay on $CURRENT_BRANCH this time"
    echo "  always = always switch to master (saves to config)"
    echo "  never  = never switch to master (saves to config)"
    echo ""
    printf "Choice [Y/n/always/never]: "
    read -r REPLY
    REPLY="${REPLY:-Y}"
    # lower-case for comparison
    REPLY_LC="$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')"
    if [ "$REPLY_LC" = "always" ]; then
        echo ""
        echo "WARNING: This will save 'always pull master' to your config."
        echo "Each launch will stash your changes and switch to master."
        echo "To undo, delete $CONFIG"
        echo ""
        printf "Confirm? [y/N]: "
        read -r CONFIRM
        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
            echo "master_behavior=always" > "$CONFIG"
            echo "Saved. You can undo this by deleting $CONFIG"
            switch_to_master
        else
            echo "Not saved. Staying on branch: $CURRENT_BRANCH"
        fi
    elif [ "$REPLY_LC" = "never" ]; then
        echo ""
        echo "WARNING: This will save 'never switch to master' to your config."
        echo "You will no longer be prompted at launch; the GUI will open"
        echo "from whatever branch you're currently on."
        echo "To undo, delete $CONFIG"
        echo ""
        printf "Confirm? [y/N]: "
        read -r CONFIRM
        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
            echo "master_behavior=never" > "$CONFIG"
            echo "Saved. You can undo this by deleting $CONFIG"
            echo "Staying on branch: $CURRENT_BRANCH"
        else
            echo "Not saved. Staying on branch: $CURRENT_BRANCH"
        fi
    elif [ "$REPLY_LC" = "y" ]; then
        switch_to_master
    else
        echo "Staying on branch: $CURRENT_BRANCH"
    fi
fi

# --- Launch MATLAB ---
echo ""
MATLAB_CMD="cd('$REPO_PATH/GeneralTools'); pullSWIFTtelemetryGUI"
echo "Launching pullSWIFTtelemetryGUI..."

if [ "$(uname)" = "Darwin" ]; then
    # macOS: use 'open' to launch MATLAB as a proper GUI app.
    # -n forces a new instance: without it, if MATLAB is already running,
    # 'open' just raises the existing window and silently drops --args,
    # so the GUI never launches. With -n, a second MATLAB instance is
    # started (user will have two MATLABs open, which is acceptable).
    MATLAB_APP="$(echo "$MATLAB_EXE" | sed 's|/bin/matlab$||')"
    if pgrep -x MATLAB > /dev/null 2>&1; then
        echo "Note: MATLAB is already running. Starting a second instance for the GUI."
        echo "      (Or you can cancel this and type 'pullSWIFTtelemetryGUI' in the existing MATLAB.)"
    fi
    open -n "$MATLAB_APP" --args -r "$MATLAB_CMD"
else
    # Linux: launch directly in background
    nohup "$MATLAB_EXE" -r "$MATLAB_CMD" > /dev/null 2>&1 &
    disown
fi

echo "Done. MATLAB is starting."

if [ "$FROM_ICON" = "true" ]; then
    echo ""
    echo "This window will automatically close in 10 seconds.
    sleep 10
fi
