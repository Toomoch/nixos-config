#!/usr/bin/env bash

apps=("waybar" "swayosd-server" "swaync" "nm-applet --indicator" "wpaperd" "firefox" "swayidle -w before-sleep 'hyprlock --immediate'")

for app in "${apps[@]}"
do
        pkill -f "$app"
        riverctl spawn "$app" 
done
