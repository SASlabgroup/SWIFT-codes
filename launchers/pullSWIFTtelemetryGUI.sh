#!/usr/bin/env bash
# ============================================================
# pullSWIFT Launcher for macOS / Linux
# Stashes changes, checks out master, fast-forwards, launches
# pullSWIFTtelemetryGUI in MATLAB.
#
# First run: prompts for repo path and saves to config file.
# MATLAB: auto-detected from standard install locations.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/.pullswift_config"

# Ensure reads come from the terminal, not piped stdin
exec < /dev/tty

# --- Load or create config ---
if [ -f "$CONFIG" ]; then
    REPO_PATH="$(cat "$CONFIG")"
else
    echo "First-time setup: enter the full path to your SWIFT-codes repo."
    if [ "$(uname)" = "Darwin" ]; then
        echo "Example: /Users/you/Dropbox/phd/code/SWIFT-codes"
    else
        echo "Example: /home/you/Dropbox/phd/code/SWIFT-codes"
    fi
    printf "Repo path: "
    read -r REPO_PATH
    # Expand ~ if present
    REPO_PATH="${REPO_PATH/#\~/$HOME}"
    echo "$REPO_PATH" > "$CONFIG"
    echo "Saved to $CONFIG."
fi

# --- Validate repo path ---
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "ERROR: '$REPO_PATH' is not a git repository."
    echo "Delete $CONFIG and re-run to reconfigure."
    echo "Press Enter to close."
    read -r
    exit 1
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

if [ "$CURRENT_BRANCH" = "master" ]; then
    echo "Already on master. Pulling latest..."
    echo "[1/2] Stashing local changes..."
    git stash || true
    echo "[2/2] Fast-forwarding..."
    git pull --ff-only
else
    echo "Currently on branch: $CURRENT_BRANCH"
    printf "Switch to master and pull latest? [Y/n]: "
    read -r REPLY
    REPLY="${REPLY:-Y}"
    if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ]; then
        echo "[1/3] Stashing local changes..."
        git stash || true
        echo "[2/3] Checking out master..."
        git checkout master
        echo "[3/3] Fast-forwarding..."
        git pull --ff-only
    else
        echo "Staying on branch: $CURRENT_BRANCH"
    fi
fi

# --- Launch MATLAB ---
echo ""
MATLAB_CMD="cd('$REPO_PATH/GeneralTools'); pullSWIFTtelemetryGUI"
echo "Launching pullSWIFTtelemetryGUI..."

if [ "$(uname)" = "Darwin" ]; then
    # macOS: use 'open' to launch MATLAB as a proper GUI app
    MATLAB_APP="$(echo "$MATLAB_EXE" | sed 's|/bin/matlab$||')"
    open "$MATLAB_APP" --args -r "$MATLAB_CMD"
else
    # Linux: launch directly in background
    nohup "$MATLAB_EXE" -r "$MATLAB_CMD" > /dev/null 2>&1 &
    disown
fi

echo "Done. MATLAB is starting."
