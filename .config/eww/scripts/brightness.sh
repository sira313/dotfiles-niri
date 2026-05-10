#!/bin/bash

case "$1" in
  get)
    # Mengambil persentase murni tanpa tanda %
    brightnessctl -m | cut -d, -f4 | tr -d '%'
    ;;
  set)
    brightnessctl set "$2%"
    ;;
  # ... sisa case lainnya
esac