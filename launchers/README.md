# SWIFT Telemetry Launchers

Desktop launchers that update the SWIFT-codes repo and open
`pullSWIFTtelemetryGUI` in MATLAB with one double-click.

Each launcher:

1. Checks current branch — if not on `master`, asks whether to switch
2. `git stash` — shelves any local changes
3. `git checkout master` + `git pull --ff-only` — fast-forwards to latest
4. Launches MATLAB and runs `pullSWIFTtelemetryGUI`

If multiple MATLAB versions are installed, the **newest** version is used
automatically (e.g. R2025b over R2024a). The GUI reads the live git branch
and commit hash via MATLAB's built-in `gitrepo()` API (R2023b+) and shows
them in the log at startup.

## Prerequisites

- **Git** installed and on your PATH
- **MATLAB R2023b or newer** (earlier versions work but skip the in-GUI
  git info line)
- MATLAB installed in a standard location (see per-OS notes below)
- The SWIFT-codes repo already cloned somewhere on your machine

---

## Quick install

Open a terminal / command prompt in the `launchers/` directory of your
SWIFT-codes checkout and run the installer for your OS:

### macOS

```bash
cd /path/to/SWIFT-codes/launchers
./install.sh
```

Creates **SWIFT Telemetry.app** on your Desktop with the SWIFT logo icon.
Double-click to launch.

- MATLAB must be at `/Applications/MATLAB_R20XXx.app/`
- Git must be available (install via `xcode-select --install` if needed)

### Linux

```bash
cd /path/to/SWIFT-codes/launchers
./install.sh
```

Creates **swift-telemetry-gui.desktop** on your Desktop with the SWIFT
logo icon. Double-click to launch.

- MATLAB must be at `/usr/local/MATLAB/R20XXx/` or `matlab` on your PATH
- Git on your PATH

### Windows

Double-click `install.bat`, or from a command prompt:

```
cd C:\path\to\SWIFT-codes\launchers
install.bat
```

Creates **SWIFT Telemetry.lnk** on your Desktop. Double-click to launch.

- MATLAB must be at `C:\Program Files\MATLAB\R20XXx\`
- Git for Windows installed and on your PATH
- For the SWIFT icon on the shortcut: convert
  `Documents/SWIFTlogo_icon.png` to `.ico`, save as
  `Documents/SWIFTlogo_icon.ico`, then re-run `install.bat`

---

## Files

| File | Platform | Description |
|---|---|---|
| `install.sh` | macOS / Linux | Installer — creates desktop shortcut |
| `install.bat` | Windows | Installer — creates desktop shortcut |
| `uninstall.sh` | macOS / Linux | Removes desktop shortcut and saved config |
| `uninstall.bat` | Windows | Removes desktop shortcut and saved config |
| `pullSWIFTtelemetryGUI.sh` | macOS / Linux | Shell launcher (called by the shortcut) |
| `pullSWIFTtelemetryGUI.bat` | Windows | Batch launcher (called by the shortcut) |
| `../Documents/SWIFTlogo_icon.png` | All | Icon source (png used on macOS/Linux, .ico for Windows) |

---

## First run

Double-click the desktop shortcut. The launcher derives the repo path
from its own location (it lives in `SWIFT-codes/launchers/`), so there is
no path prompt.

If you're not on `master` when the launcher runs, you'll see:

```
Switch to master and pull latest?
  Y      = yes, switch this time
  n      = no, stay on this branch this time
  always = always switch to master (saves to config)
  never  = never switch to master (saves to config)
```

Choosing `always` or `never` writes `master_behavior=always|never` to
`.pullswift_config` next to the launcher scripts. Delete that file to be
prompted again.

After MATLAB is launched the terminal window pauses for 10 seconds so you
can read any notes (e.g. "MATLAB was already running, second instance
started") before it closes. This 10-second pause **only** happens when
the launcher is invoked via the desktop icon — running the `.sh` / `.bat`
directly from a shell exits immediately. This is controlled by a
`--from-icon` argument that the `.app`, `.desktop` file, and `.lnk`
shortcut pass automatically.

---

## Running directly (without the desktop icon)

You can also run the launcher scripts straight from a terminal:

```bash
# macOS / Linux
./pullSWIFTtelemetryGUI.sh

# Windows
pullSWIFTtelemetryGUI.bat
```

No 10-second wait in this mode.

Or skip the launcher entirely and open MATLAB normally, then from the
Command Window:

```matlab
cd /path/to/SWIFT-codes/GeneralTools
pullSWIFTtelemetryGUI
```

This is the right approach if you already have MATLAB open — the desktop
launcher spawns a **second** MATLAB instance in that case (a limitation
of how macOS `open -n` works and how Windows `start` launches matlab.exe).

---

## Uninstall

### macOS / Linux

```bash
cd /path/to/SWIFT-codes/launchers
./uninstall.sh
```

### Windows

```
cd C:\path\to\SWIFT-codes\launchers
uninstall.bat
```

Removes the desktop shortcut and `.pullswift_config`.

---

## Reconfiguring

To reset the master-branch prompt behavior, delete `.pullswift_config` in
the `launchers/` directory. You'll be re-prompted the next time you
launch from a non-master branch.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Not a git repository" | The `launchers/` folder must live inside `SWIFT-codes/`. |
| "Could not find MATLAB" | MATLAB not in a standard location — add `matlab` to PATH. |
| Fast-forward failed | Master diverged or was force-pushed. Resolve with `git pull --rebase` manually. |
| macOS "unidentified developer" | Right-click the `.app` → Open, then click Open in the dialog. |
| macOS icon not showing | Clear the icon cache: `sudo killall Dock` (or reboot). |
| GUI opens then a second MATLAB appears | Expected if MATLAB was already running — the launcher forces a fresh instance so the `-r` command isn't dropped. Close whichever one you don't need, or in future just run `pullSWIFTtelemetryGUI` from your existing MATLAB. |
| Git info line in log shows "Git info unavailable" | MATLAB older than R2023b — `gitrepo()` isn't available. Everything else still works. |
| `git stash` says "No local changes to save" | Fine — that's a no-op, not an error. |
