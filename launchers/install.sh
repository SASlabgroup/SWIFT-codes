#!/usr/bin/env bash
# ============================================================
# SWIFT Telemetry Installer for macOS / Linux
# Creates a desktop shortcut that launches pullSWIFTtelemetryGUI.sh
# with the SWIFT logo icon.
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCHER="$SCRIPT_DIR/pullSWIFTtelemetryGUI.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ICON="$REPO_ROOT/Documents/SWIFTlogo_icon.png"
DESKTOP="$HOME/Desktop"
OS="$(uname -s)"
APP_DISPLAY_NAME="SWIFT Telemetry"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  ${APP_DISPLAY_NAME} Installer${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# --- Validate files exist ---
if [ ! -f "$LAUNCHER" ]; then
    echo -e "${RED}ERROR: pullSWIFTtelemetryGUI.sh not found in $SCRIPT_DIR${NC}"
    exit 1
fi

if [ ! -f "$ICON" ]; then
    echo -e "${YELLOW}WARNING: SWIFTlogo_icon.png not found — shortcut will have no custom icon.${NC}"
fi

chmod +x "$LAUNCHER"

# --- macOS ---
if [ "$OS" = "Darwin" ]; then
    echo -e "${YELLOW}Detected macOS${NC}"
    APP_DIR="$DESKTOP/${APP_DISPLAY_NAME}.app"

    echo "Creating application bundle at $APP_DIR ..."

    # Build a minimal .app bundle
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"

    # Info.plist — use a simple executable name without spaces
    cat > "$APP_DIR/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_DISPLAY_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_DISPLAY_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>edu.uw.apl.swift-telemetry-gui</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
</dict>
</plist>
PLIST

    # Launcher script inside the .app (no spaces in filename)
    # --from-icon tells the launcher to pause before closing the terminal
    cat > "$APP_DIR/Contents/MacOS/launcher" << WRAPPER
#!/usr/bin/env bash
# Open a terminal, run the launcher, then close the terminal tab
osascript -e 'tell application "Terminal"
    activate
    do script "\"$LAUNCHER\" --from-icon; exit"
end tell'
WRAPPER
    chmod +x "$APP_DIR/Contents/MacOS/launcher"

    # Convert PNG to icns for the icon
    if [ -f "$ICON" ]; then
        ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
        mkdir -p "$ICONSET_DIR"
        # Generate required sizes
        for size in 16 32 128 256 512; do
            sips -z $size $size "$ICON" --out "$ICONSET_DIR/icon_${size}x${size}.png" > /dev/null 2>&1
            double=$((size * 2))
            sips -z $double $double "$ICON" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" > /dev/null 2>&1
        done
        iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/AppIcon.icns" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Icon set successfully.${NC}"
        else
            echo -e "${YELLOW}Could not convert icon to icns — app will use default icon.${NC}"
        fi
        rm -rf "$(dirname "$ICONSET_DIR")"
    fi

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  Installation complete!${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "  App created: $APP_DIR"
    echo -e "  Double-click it to launch."
    echo ""

# --- Linux ---
elif [ "$OS" = "Linux" ]; then
    echo -e "${YELLOW}Detected Linux${NC}"
    DESKTOP_FILE="$DESKTOP/swift-telemetry-gui.desktop"

    echo "Creating desktop entry at $DESKTOP_FILE ..."

    cat > "$DESKTOP_FILE" << ENTRY
[Desktop Entry]
Name=${APP_DISPLAY_NAME}
Comment=Update SWIFT-codes and launch pullSWIFTtelemetryGUI
Exec=$LAUNCHER --from-icon
Icon=$ICON
Terminal=true
Type=Application
Categories=Science;
ENTRY
    chmod +x "$DESKTOP_FILE"

    # Some desktop environments need this to trust the launcher
    if command -v gio > /dev/null 2>&1; then
        gio set "$DESKTOP_FILE" metadata::trusted true 2>/dev/null
    fi

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  Installation complete!${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "  Shortcut created: ${DESKTOP_FILE}"
    echo -e "  Double-click it to launch."
    echo ""

else
    echo -e "${RED}Unsupported OS: $OS${NC}"
    echo "Use install.bat for Windows."
    exit 1
fi
