#!/usr/bin/env python3
import os
import re

def parse_niri_binds():
    path = os.path.expanduser("~/.config/niri/conf/binds.kdl")
    if not os.path.exists(path):
        return

    with open(path, "r") as f:
        lines = f.readlines()

    results = []
    key_pattern = re.compile(r'\"([^\"]+)\"|\b(Mod\+?\S*|Super\+?\S*|Alt\+?\S*|Ctrl\+?\S*)\b')

    for i in range(len(lines)):
        line = lines[i].strip()
        
        if 'hotkey-overlay-title="' in line:
            title_match = re.search(r'hotkey-overlay-title="([^"]+)"', line)
            title = title_match.group(1) if title_match else "No Title"

            key = "Unknown"
            found_key = False
            for j in range(i, max(-1, i-4), -1):
                current_search_line = lines[j].strip()
                
                key_match = re.search(r'(?:bind\s+)?\"([^\"]+)\"|(\b(?:Mod|Super|Alt|Ctrl|Shift)\S+)', current_search_line)
                
                if key_match:
                    key = key_match.group(1) or key_match.group(2)
                    key = key.replace("{", "").strip()
                    found_key = True
                    break
            
            cmd = ""
            for k in range(i, min(len(lines), i+4)):
                if "spawn" in lines[k]:
                    cmd_match = re.search(r'spawn(?:-sh)?\s+"([^"]+)"', lines[k])
                    if cmd_match:
                        cmd = cmd_match.group(1).strip()
                        break
            
            results.append(f"{key:<22} │ {title:<30} │ {cmd}")

    for item in sorted(set(results)):
        print(item)

if __name__ == "__main__":
    parse_niri_binds()