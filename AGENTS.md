# dotfiles-niri

Arch Linux + Niri (Wayland) + Waybar + Fish shell dotfiles.  
Single user, single branch (`main`), no CI/CD — personal repo.

## Install

```bash
./sync                    # symlinks .config/* dirs+files → ~/.config/ + .local/share/applications/
```

- `./sync` skips `eww` (hardcoded in `exclude` array). EWW must be linked manually; dashboards are no longer actively used.
- `.config/micro/*` is gitignored except `settings.json` and `colorschemes/`.

## Config layout

| Path | Contents |
|------|----------|
| `.config/niri/config.kdl` | Top-level only + `include "conf/*.kdl"` — do **not** put top-level opts in sub-files |
| `.config/niri/conf/binds.kdl` | All keybindings (`Mod` = Super) |
| `.config/niri/conf/startup.kdl` | Auto-started: waybar, mako, polkit, swayidle (120s→off, 180s→suspend), swaybg, cliphist |
| `.config/niri/scripts/` | Custom scripts: `osd`, `powermenu`, `clipboard`, `emoji`, `toggle-wfr`, `cheatsheet` |
| `.config/waybar/config.jsonc` | Bar layout + custom module wiring |
| `.config/waybar/scripts/` | Waybar custom modules: `tuned-profile.sh`, `status-wfr.sh`, `airplane-mode.sh`, `nmtui.sh` |
| `.config/fish/config.fish` | starship prompt, eza aliases, `$PATH` |
| `.config/fish/conf.d/shortcut.fish` | Fish functions: `snap`/`snap-list`/`snap-del` (btrfs), `fixcpu` (ryzenadj), `share-on`/`share-off` (samba), `clip-wipe` |
| `.config/fish/functions/start-win.fish` | Windows VM launcher (podman-compose → freerdp3 RDP) |
| `.local/share/applications/` | Desktop entries `win-start.desktop`, `win-stop.desktop` |
| `windows11/podman-compose.yml` | Windows 11 VM (dockurr/windows, podman) |
| `docs/` | Setup notes (Node.js on Arch, Pi setup, touch/jump fix) |
| `.config/eww/` | EWW dashboard — excluded from sync, not actively used |

## Key script wiring (non-obvious)

| Script | Language | Calls / Conventions |
|--------|----------|---------------------|
| `niri/scripts/osd` | bash | Sourced from binds with arg `sink`/`source`/`brightness`. Sources `utils` for `notify_replace` (replaces previous OSD notification via ID file) |
| `niri/scripts/toggle-wfr` | bash | Called from niri bind `Mod+S` and waybar screencast module click. Uses fuzzel for mode/audio selection. Output: `~/Videos/ScreenRecord/` |
| `waybar/scripts/status-wfr.sh` | bash | Polled by waybar (`interval: 2`); outputs `{"alt":"recording"}` or `{"alt":"idle"}` |
| `waybar/scripts/tuned-profile.sh` | bash | Waybar custom module: `get` → json for display, `toggle` → cycles powersave/balanced/throughput-performance |
| `waybar/scripts/airplane-mode.sh` | bash | Waybar custom module: `status` → json for display, `toggle` → toggles WiFi + BT |
| `waybar/scripts/nmtui.sh` | bash | Single-use: launches kitty with themed `nmtui` (NEWT_COLORS) |
| `niri/scripts/clipboard` | **fish** | cliphist list → fuzzel → wl-copy → wtype Ctrl+V |
| `niri/scripts/emoji` | **fish** | rofimoji --selector fuzzel --action copy → wtype Ctrl+V |
| `niri/scripts/powermenu` | **fish** | fuzzel menu → systemctl / niri msg |
| `niri/scripts/cheatsheet_parser.py` | python | Parses `binds.kdl` to generate the cheatsheet shown by `Mod+Shift+/` |

## Conventions

- **Mod** = Super/Win. Screenshots → `~/Pictures/Screenshots/`.
- Audio: `pipewire` + `wpctl` + `playerctl`. Brightness: `brightnessctl --class=backlight`.
- Power profiles via `tuned` (D-Bus `busctl` call, falls back to `sudo tuned-adm`).
- XWayland root apps: `xwayland-satellite` + `xhost +si:localuser:root` in startup.
- Clipboard: `cliphist` stored on startup via `wl-paste --watch`, retrieved with `cliphist decode | wl-copy`.
