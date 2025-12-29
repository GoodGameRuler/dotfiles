#!/bin/bash
entries="📦 pacman-update\n🔄 yay-update"
selected=$(echo -e $entries|wofi --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  pacman)
    if pkexec pacman -Syu --noconfirm; then
      notify-send "Pacman Update" "System update completed successfully" -i software-update-available
    else
      notify-send "Pacman Update" "System update failed" -u critical -i dialog-error
    fi
    ;;
  yay)
    if yay -Syu --noconfirm; then
      notify-send "Yay Update" "AUR update completed successfully" -i software-update-available
    else
      notify-send "Yay Update" "AUR update failed" -u critical -i dialog-error
    fi
    ;;
esac
