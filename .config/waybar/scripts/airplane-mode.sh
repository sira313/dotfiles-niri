#!/usr/bin/env bash
# ~/.config/waybar/scripts/airplane-mode.sh
# Airplane mode: toggles WiFi + Bluetooth on/off

get_status() {
  local wifi bluetooth
  wifi=$(nmcli radio wifi)
  bluetooth=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

  if [ "$wifi" = "disabled" ] && [ "$bluetooth" = "no" ]; then
    echo "enabled"
  else
    echo "disabled"
  fi
}

case "${1:-status}" in
  status)
    class=$(get_status)
    if [ "$class" = "enabled" ]; then
      printf '{"text":"󰀝","alt":"enabled","tooltip":"Airplane Mode: ON","class":"enabled"}\n'
    else
      printf '{"text":"󰀞","alt":"disabled","tooltip":"Airplane Mode: OFF","class":"disabled"}\n'
    fi
    ;;

  toggle)
    class=$(get_status)
    if [ "$class" = "enabled" ]; then
      nmcli radio wifi on
      bluetoothctl power on
    else
      nmcli radio wifi off
      bluetoothctl power off
    fi
    ;;
esac
