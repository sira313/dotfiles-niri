#!/usr/bin/env bash

case "$1" in
  fullname)
    getent passwd "$USER" \
      | cut -d ':' -f 5 \
      | cut -d ',' -f 1
    ;;

  hostname)
    cat /proc/sys/kernel/hostname
    ;;

  *)
    echo "unknown"
    ;;
esac