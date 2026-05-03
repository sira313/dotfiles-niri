#!/usr/bin/env python3
import os
import re

def format_key_pretty(key_string):
    mapping = {
        # Modifier keys — pakai teks supaya pasti muncul di fuzzel
        "Mod":   "",
        "Super": "",
        "Alt":   "Alt",
        "Ctrl":  "Ctrl",
        "Shift": "Shift",
        "Delete": "Del",
        # Special keys — glyph Nerd Font (umumnya render dengan baik)
        "Space":      "󱁐",
        "Page_Up":    "PgUp",
        "Page_Down":  "PgDn",
        "Period":     ".",
        "Comma":      ",",
        "Slash":      "/",
        "BracketLeft":  "[",
        "BracketRight": "]",
        "Minus":      "-",
        "Equal":      "=",
        "Escape":     "Esc",
        "Print":      "󰄀",
        "Left":       "←",
        "Right":      "→",
        "Up":         "↑",
        "Down":       "↓",
        # Media keys
        "XF86AudioPlay":        "󰐊",
        "XF86AudioStop":        "󰓛",
        "XF86AudioPrev":        "󰒮",
        "XF86AudioNext":        "󰒭",
        "XF86AudioRaiseVolume": "󰕾",
        "XF86AudioLowerVolume": "󰕿",
        "XF86AudioMute":        "󰝟",
        "XF86AudioMicMute":     "󰍬",
        "XF86MonBrightnessUp":  "󰃠",
        "XF86MonBrightnessDown":"󰃟",
        "WheelScrollDown":  "",
        "WheelScrollUp":    "",
        "WheelScrollRight": "",
        "WheelScrollLeft":  "",
    }

    parts = key_string.split('+')
    pretty_parts = [mapping.get(p, p) for p in parts]
    return " + ".join(pretty_parts)

def parse_niri_binds():
    path = os.path.expanduser("~/.config/niri/conf/binds.kdl")
    if not os.path.exists(path):
        return

    with open(path, "r") as f:
        lines = f.readlines()

    results = []
    for i in range(len(lines)):
        line = lines[i].strip()

        if 'hotkey-overlay-title="' in line:
            title_match = re.search(r'hotkey-overlay-title="([^"]+)"', line)
            title = title_match.group(1) if title_match else "No Title"
            key = "Unknown"

            for j in range(i, max(-1, i-3), -1):
                current_search_line = lines[j].strip()
                key_match = re.search(r'([\w\+\-]+)(?=\s+.*hotkey-overlay-title)', current_search_line)
                if key_match:
                    key = key_match.group(1)
                    break

            pretty_key = format_key_pretty(key)

            cmd = "Action"
            for k in range(i, min(len(lines), i+5)):
                if "spawn" in lines[k]:
                    cmd_match = re.search(r'spawn(?:-sh)?\s+"([^"]+)"', lines[k])
                    if cmd_match:
                        cmd = cmd_match.group(1)
                        break

            results.append(f"{pretty_key}\t{title}\t{cmd}")

    for item in sorted(set(results)):
        print(item)

if __name__ == "__main__":
    parse_niri_binds()
