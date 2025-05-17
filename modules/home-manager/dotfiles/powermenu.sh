#!/usr/bin/env bash

options="  Power Off
  Reboot
  Suspend
  Log Out
  Lock
  Reboot to UEFI
  Reboot to Windows"

chosen=$(echo -e "$options" | fuzzel --no-exit-on-keyboard-focus-loss --dmenu --font="NotoSansM Nerd Font Mono:size=20")

case "$chosen" in
"  Power Off")
        systemctl poweroff
        ;;
"  Reboot")
        systemctl reboot
        ;;
"  Suspend")
        systemctl suspend
        ;;
"  Log Out")
        swaymsg exit || riverctl exit || hyprctl dispatch exit
        ;;
"  Lock")
        waylock
        ;;
"  Reboot to UEFI")
        systemctl reboot --firmware-setup
        ;;
"  Reboot to Windows")
        systemctl reboot --boot-loader-entry=auto-windows
        ;;
*) ;;
esac
