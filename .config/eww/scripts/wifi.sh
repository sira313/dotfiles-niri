#!/usr/bin/env bash

# File: ~/.config/eww/scripts/wifi.sh

toggle() {
    STATUS=$(nmcli radio wifi)
    if [ "$STATUS" = "enabled" ]; then
        nmcli radio wifi off
        eww update wifi_status="disabled"
        eww update wifi_ssid="WiFi Off"
        eww update wifi_ip="Disconnected"
    else
        nmcli radio wifi on
        eww update wifi_status="enabled"
        # Berikan feedback visual bahwa sedang mencoba menyambung
        eww update wifi_ssid="Connecting..."
    fi
}

case "$1" in
    toggle) toggle ;;
    *) nmcli radio wifi ;;
esac