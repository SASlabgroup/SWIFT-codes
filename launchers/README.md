# SWIFT Telemetry Launchers

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

This creates a **SWIFT Telemetry.app** (macOS) or **swift-telemetry-gui.desktop** (Linux)
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

This creates a **SWIFT Telemetry.lnk** shortcut on your Desktop.

**Requirements:**
- Git for Windows (Git Bash, Git GUI, or WSL)
- MATLAB in `C:\Program Files\MATLAB\R20XXx\`
- For the SWIFT icon: convert `Documents/SWIFTlogo_icon.png` to `.ico` and
  place it in `Documents/` as `SWIFTlogo_icon.ico`, then re-run `install.bat`.

---

## First run

Double-click the desktop shortcut. The launcher derives the repo path from
its own location (it lives in `SWIFT-codes/launchers/`), so no path prompt
is needed.

If you're not on the `master` branch when the launcher runs, you'll see:

```
Switch to master and pull latest?
  Y      = yes, switch this time
  n      = no, stay on this branch this time
  always = always switch to master (saves to config)
  never  = never switch to master (saves to config)
```

Choosing `always` or `never` writes `master_behavior=always|never` to
`.pullswift_config` next to the launcher scripts. Delete that file to be
prompted again on next launch.

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

To reset the master-branch behavior, delete `.pullswift_config` in the
`launchers/` directory. You'll be re-prompted the next time you launch
from a non-master branch.

## Troubleshooting

| Problem | Fix |
|---|---|
| "Not a git repository" | The `launchers/` folder must live inside `SWIFT-codes/`. |
| "Could not find MATLAB" | MATLAB is not in a standard location. Add `matlab` to your PATH. |
| Fast-forward failed | Someone force-pushed or your master diverged. Run `git pull --rebase` manually. |
| macOS "unidentified developer" | Right-click the app > Open, then click Open in the dialog. |
| Git stash didn't stash anything | That's fine — `git stash` with no changes is a no-op. |
