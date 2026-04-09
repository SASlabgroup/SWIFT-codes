#!/usr/bin/env bash
# ============================================================
# pullSWIFT Uninstaller for macOS / Linux
# Removes the desktop shortcut and saved config.
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/.pullswift_config"
DESKTOP="$HOME/Desktop"
OS="$(uname -s)"

echo -e "${YELLOW}======================================${NC}"
echo -e "${YELLOW}  SWIFT Telemetry GUI Uninstaller${NC}"
echo -e "${YELLOW}======================================${NC}"
echo ""

REMOVED=0

# --- Remove desktop shortcut ---
if [ "$OS" = "Darwin" ]; then
    APP="$DESKTOP/SWIFT Telemetry GUI.app"
    if [ -d "$APP" ]; then
        rm -rf "$APP"
        echo -e "${GREEN}Removed: $APP${NC}"
        REMOVED=$((REMOVED + 1))
    else
        echo "No app bundle found at $APP"
    fi
elif [ "$OS" = "Linux" ]; then
    DESKTOP_FILE="$DESKTOP/swift-telemetry-gui.desktop"
    if [ -f "$DESKTOP_FILE" ]; then
        rm -f "$DESKTOP_FILE"
        echo -e "${GREEN}Removed: $DESKTOP_FILE${NC}"
        REMOVED=$((REMOVED + 1))
    else
        echo "No desktop file found at $DESKTOP_FILE"
    fi
fi

# --- Remove config ---
if [ -f "$CONFIG" ]; then
    rm -f "$CONFIG"
    echo -e "${GREEN}Removed: $CONFIG${NC}"
    REMOVED=$((REMOVED + 1))
else
    echo "No config file found."
fi

echo ""
if [ "$REMOVED" -gt 0 ]; then
    echo -e "${GREEN}Uninstall complete.${NC}"
else
    echo "Nothing to remove."
fi
