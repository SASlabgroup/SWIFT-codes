# SWIFT Telemetry GUI Launchers

Desktop launchers that update the SWIFT-codes repo and open
pullSWIFTtelemetryGUI in MATLAB with one click.

Each launcher does the following:
1. Checks current branch — if not on master, asks whether to switch
2. `git stash` — shelves any local changes
3. `git checkout master` + `git pull --ff-only` — fast-forwards to latest
4. Launches MATLAB and runs `pullSWIFTtelemetryGUI`

If multiple MATLAB versions are installed, the **newest** version is used
automatically (e.g. R2025b over R2024a).

## Prerequisites

- **Git** installed and on your PATH
- **MATLAB** installed in a standard location (see below)
- The SWIFT-codes repo already cloned somewhere on your machine

## Files

| File                 | Platform      | Description                        |
|----------------------|---------------|------------------------------------|
| `install.sh`         | macOS / Linux | Installer — creates desktop shortcut |
| `install.bat`        | Windows       | Installer — creates desktop shortcut |
| `uninstall.sh`       | macOS / Linux | Uninstaller — removes desktop shortcut and config |
| `uninstall.bat`      | Windows       | Uninstaller — removes desktop shortcut and config |
| `pullSWIFTtelemetryGUI.sh`       | macOS / Linux | Shell script launcher              |
| `pullSWIFTtelemetryGUI.bat`      | Windows       | Batch file launcher                |
| `../Documents/SWIFTlogo_icon.png` | All  | Icon for desktop shortcuts         |

---

## Installation

### macOS / Linux

```bash
cd /path/to/SWIFT-codes/launchers
./install.sh
```

This creates a **SWIFT Telemetry GUI.app** (macOS) or **swift-telemetry-gui.desktop** (Linux)
on your Desktop with the SWIFT logo icon.

**Requirements:**
- **macOS**: Git (via Xcode Command Line Tools: `xcode-select --install`),
  MATLAB in `/Applications/MATLAB_R20XXx.app/`
- **Linux**: Git, MATLAB in `/usr/local/MATLAB/R20XXx/` or on your PATH

### Windows

Double-click `install.bat`, or from a command prompt:

```
cd C:\path\to\SWIFT-codes\launchers
install.bat
```

This creates a **SWIFT Telemetry GUI.lnk** shortcut on your Desktop.

**Requirements:**
- Git for Windows (Git Bash, Git GUI, or WSL)
- MATLAB in `C:\Program Files\MATLAB\R20XXx\`
- For the SWIFT icon: convert `Documents/SWIFTlogo_icon.png` to `.ico` and
  place it in `Documents/` as `SWIFTlogo_icon.ico`, then re-run `install.bat`.

---

## First run

Double-click the desktop shortcut. On first launch you will be prompted for the
full path to your SWIFT-codes repo:

| Platform | Example path |
|----------|-------------|
| Windows  | `C:\Users\yourname\Dropbox\phd\code\SWIFT-codes` |
| macOS    | `/Users/yourname/Dropbox/phd/code/SWIFT-codes` |
| Linux    | `/home/yourname/Dropbox/phd/code/SWIFT-codes` |

This is saved to `.pullswift_config` next to the launcher scripts and reused
on subsequent launches.

---

## Uninstalling

### macOS / Linux

```bash
cd /path/to/SWIFT-codes/launchers
./uninstall.sh
```

### Windows

Double-click `uninstall.bat`, or from a command prompt:

```
cd C:\path\to\SWIFT-codes\launchers
uninstall.bat
```

This removes the desktop shortcut and the saved `.pullswift_config` file.

---

## Reconfiguring

To change the saved repo path, delete the `.pullswift_config` file in the
`launchers/` directory and run the launcher again. You will be re-prompted.

## Troubleshooting

| Problem | Fix |
|---|---|
| "Not a git repository" | The saved path is wrong. Delete `.pullswift_config` and re-run. |
| "Could not find MATLAB" | MATLAB is not in a standard location. Add `matlab` to your PATH. |
| Fast-forward failed | Someone force-pushed or your master diverged. Run `git pull --rebase` manually. |
| macOS "unidentified developer" | Right-click the app > Open, then click Open in the dialog. |
| Git stash didn't stash anything | That's fine — `git stash` with no changes is a no-op. |
