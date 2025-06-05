#!/bin/bash

entries="⇠ Lock\n⇠ Logout\n⏾ Suspend\n⭮ Reboot\n⏻ Shutdown"

selected=$(echo -e $entries|wofi --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  lock)
    exec hyprlock;;
  logout)
    hyprctl dispatch exit;;
  suspend)
    exec systemctl suspend;;
  shutdown)
    exec systemctl poweroff;;
    # it used to be poweroff -i
  reboot)
    exec systemctl reboot;;
esac
