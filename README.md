# GlazeWM + Zebar + AHK Configuration

My Windows tiling window manager setup using [GlazeWM](https://github.com/glzr-io/glazewm), [Zebar](https://github.com/glzr-io/zebar) (status bar), and [AutoHotkey](https://www.autohotkey.com/) (mouseless navigation).

## What's Included

| File / Folder | Description |
|---|---|
| `glazewm-config.yaml` | GlazeWM tiling WM config — workspaces, keybindings, window rules, gaps, effects |
| `keyboard-nav.ahk` | AHK v2 script for mouseless navigation (CapsLock as modifier key) |
| `zebar-custom-bar/` | Custom Zebar top bar widget (HTML/CSS status bar for GlazeWM) |
| `zebar-settings.json` | Zebar application settings |

## Prerequisites

Install the following:

1. **GlazeWM** — https://github.com/glzr-io/glazewm/releases
2. **Zebar** — https://github.com/glzr-io/zebar/releases
3. **AutoHotkey v2** — https://www.autohotkey.com/ (v2.0+ required)

## Installation

### GlazeWM Config

Copy the GlazeWM config to its expected location:

```
%USERPROFILE%\.glzr\glazewm\config.yaml
```

```powershell
Copy-Item glazewm-config.yaml "$env:USERPROFILE\.glzr\glazewm\config.yaml"
```

### Zebar Config

Copy the custom bar widget and settings:

```
%USERPROFILE%\.glzr\zebar\custom-bar\    (widget folder)
%USERPROFILE%\.glzr\zebar\settings.json
```

```powershell
Copy-Item -Recurse zebar-custom-bar "$env:USERPROFILE\.glzr\zebar\custom-bar"
Copy-Item zebar-settings.json "$env:USERPROFILE\.glzr\zebar\settings.json"
```

### AutoHotkey Script

Copy the AHK script to the Windows Startup folder so it runs on login:

```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\keyboard-nav.ahk
```

```powershell
Copy-Item keyboard-nav.ahk "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\keyboard-nav.ahk"
```

Or open the Startup folder with `Win+R` → `shell:startup` and drop the file there.

## GlazeWM Keybindings

| Binding | Action |
|---|---|
| `Alt + H/J/K/L` | Focus window left/down/up/right |
| `Alt + Shift + H/J/K/L` | Move window left/down/up/right |
| `Alt + 1-9` | Focus workspace |
| `Alt + Shift + 1-9` | Move window to workspace |
| `Alt + A/S` | Previous/next active workspace |
| `Alt + D` | Recent workspace |
| `Alt + R` | Enter resize mode (then H/J/K/L to resize) |
| `Alt + V` | Toggle tiling direction |
| `Alt + Space` | Cycle focus (tiling → floating → fullscreen) |
| `Alt + Shift + Space` | Toggle floating (centered) |
| `Alt + T` | Toggle tiling |
| `Alt + F` | Toggle fullscreen |
| `Alt + Shift + Q` | Close window |
| `Alt + Enter` | Launch CMD |
| `Alt + Shift + R` | Reload config |

## AHK Keyboard Nav (CapsLock as modifier)

CapsLock is repurposed as a modifier key. Tap it alone to send Escape; hold it + another key for navigation.

| Binding | Action |
|---|---|
| `CapsLock + j/k` | Scroll down/up |
| `CapsLock + d/u` | Half-page scroll down/up |
| `CapsLock + h/l` | Scroll left/right |
| `CapsLock + g / Shift+G` | Home / End |
| `CapsLock + [ / ]` | Page Up / Page Down |
| `CapsLock + Arrows` | Move mouse cursor (fast) |
| `CapsLock + Shift + Arrows` | Move mouse cursor (slow) |
| `CapsLock + 1-9` | Jump cursor to 3×3 screen grid |
| `CapsLock + e` | 3-stage grid hint jump (monitor → zone → fine) |
| `CapsLock + Shift+E` | Grid hint jump + left click |
| `CapsLock + Space` | Left click |
| `CapsLock + Enter` | Right click |
| `CapsLock + Backspace` | Double click |
| `CapsLock + m` | Middle click |
| `CapsLock + Shift+Space` | Toggle mouse drag |
| `Win + CapsLock` | Toggle real CapsLock |
| `Win + F1` | Show/hide cheat sheet |

## Workspace Layout

| Workspace | App |
|---|---|
| 1 | JetBrains Rider |
| 2 | Slack |
| 3 | Chrome |
| 4 | Claude |
| 5 | Perforce (p4v, UGS, UBA) |
| 6 | Firefox |
| 7-9 | Unassigned |

## Notes

- The AHK script requires admin privileges (it auto-elevates on launch).
- The script hides the Windows taskbar on startup (Zebar replaces it). The taskbar is restored when the script exits.
- GlazeWM is configured to auto-launch Zebar on startup and kill it on shutdown.
