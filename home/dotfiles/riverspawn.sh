#!/usr/bin/env bash

apps=("waybar" "swayosd-server" "swaync" "nm-applet --indicator" "wpaperd" "firefox" "swayidle -w before-sleep 'hyprlock --immediate'")

for app in "${apps[@]}"
do
        pname=$(echo "$app" | awk '{print $1}')
        pkill -f "$pname"
        riverctl spawn "$app" 
done
