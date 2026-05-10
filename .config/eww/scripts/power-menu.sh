#!/usr/bin/env fish

switch $argv[1]

  case lock
    if command -v hyprlock >/dev/null
      hyprlock
    else if command -v swaylock >/dev/null
      swaylock
    else
      notify-send "Error" "No screen locker found"
    end
  case logout
    niri msg action quit --skip-confirmation
  case suspend
    systemctl suspend
  case reboot
    systemctl reboot
  case shutdown
    systemctl poweroff
end