#!/usr/bin/env bash

powered() {
  if bluetoothctl show | grep -q "Powered: yes"; then
    echo enabled
  else
    echo disabled
  fi
}

connected_line() {
  bluetoothctl devices Connected | head -n1
}

is_connected() {
  if [[ -n "$(connected_line)" ]]; then
    echo yes
  else
    echo no
  fi
}

case "$1" in
  status)
    powered
  ;;
  
  connected)
    is_connected
  ;;
  
  name)
    connected_line | cut -d' ' -f3-
  ;;
  
  mac)
    connected_line | awk '{print $2}'
  ;;
  
  toggle)
    if bluetoothctl show | grep -q "Powered: yes"; then
      bluetoothctl power off >/dev/null
      # Paksa update variabel eww secara manual
      eww update bluetooth_status="disabled"
      eww update bluetooth_connected="no"
    else
      bluetoothctl power on >/dev/null
      eww update bluetooth_status="enabled"
    fi
  ;;
  
  *)
    echo disabled
  ;;
esac