# dotfiles-niri

Arch Linux + Niri (Wayland compositor) + Waybar + Fish shell dotfiles.

## Install / sync

```bash
./sync                    # symlinks all .config/* dirs/files → ~/.config/
```

- `./sync` skips `eww` (listed in `exclude` array in the script). EWW config must be manually copied/linked.
- `.config/micro/*` is gitignored except `settings.json` and `colorschemes/`.

## Key layout

| Path | Purpose |
|------|---------|
| `.config/niri/config.kdl` | Compositor entrypoint; includes `conf/*.kdl` |
| `.config/niri/conf/binds.kdl` | All keybindings (Mod=Super/Win) |
| `.config/niri/conf/startup.kdl` | Auto-started services (waybar, mako, cliphist, swayidle, swaybg) |
| `.config/niri/scripts/` | Custom scripts (powermenu, clipboard, OSD, emoji, screen recording toggle, cheatsheet) |
| `.config/niri/conf/input.kdl` | Input device config |
| `.config/niri/conf/layout.kdl` | Window layout settings |
| `.config/niri/conf/window-rules.kdl` | Per-window rules |
| `.config/niri/conf/output.kdl` | Monitor output config |
| `.config/waybar/config.jsonc` | Waybar bar layout and modules |
| `.config/waybar/style.css` | Waybar styling |
| `.config/waybar/scripts/` | Waybar custom module scripts (nmtui, tuned-profile, screencast status) |
| `.config/fish/config.fish` | Fish shell init (starship prompt, eza aliases, path) |
| `.config/fish/functions/start-win.fish` | Windows VM launcher (podman-compose → freerdp) |
| `.config/fish/conf.d/shortcut.fish` | Fish functions: `snap`/`snap-list`/`snap-del` (btrfs), `fixcpu` (ryzenadj), `share-on`/`share-off` (samba), `clip-wipe` |
| `.local/share/applications/` | Desktop entries (`win-start.desktop`, `win-stop.desktop`) |
| `windows11/podman-compose.yml` | Windows 11 VM definition (podman, dockurr/windows image) |
| `docs/` | Supplementary setup notes (Node.js on Arch, Pi setup, touch/jump fix) |

## Notable conventions

- Keybindings use `Mod` = Super/Win key.
- Screenshot path: `~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png`
- Clipboard: `cliphist` + `wl-paste` (stores text and images on startup).
- Screen recording: `wf-recorder` via `toggle-wfr` script.
- Audio: `pipewire` + `wpctl` + `playerctl`.
- Brightness: `brightnessctl` on `--class=backlight`.
- Power profiles: `tuned` via `tuned-profile.sh`.
- XWayland: `xwayland-satellite` + `xhost +si:localuser:root` for root Xorg apps.
- Niri `config.kdl` includes `conf/*.kdl` — do not put top-level options in the sub-files.

## Git

No strict conventions. This is a personal dotfiles repo — single branch (`main`), no CI/CD.
