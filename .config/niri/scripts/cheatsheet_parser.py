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
    for i in range(len(lines)):
        line = lines[i].strip()
        
        if 'hotkey-overlay-title="' in line:
            # 1. Ambil Title
            title_match = re.search(r'hotkey-overlay-title="([^"]+)"', line)
            title = title_match.group(1) if title_match else "No Title"

            # 2. Cari Key (Melacak ke atas hingga 4 baris)
            key = "Unknown"
            for j in range(i, max(-1, i-4), -1):
                current_search_line = lines[j].strip()
                key_match = re.search(r'(?:bind\s+)?\"([^\"]+)\"|(\b(?:Mod|Super|Alt|Ctrl|Shift)\S+)', current_search_line)
                
                if key_match:
                    key = key_match.group(1) or key_match.group(2)
                    key = key.replace("{", "").strip()
                    break
            
            # Hanya simpan Key dan Title
            results.append(f"{key:<22} │ {title}")

    # Print hasil unik dan terurut
    for item in sorted(set(results)):
        print(item)

if __name__ == "__main__":
    parse_niri_binds()