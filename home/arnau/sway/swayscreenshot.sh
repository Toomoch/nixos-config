#!/bin/sh

filename=$(xdg-user-dir PICTURES)/screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')

case "$1" in
    area)
        slurpout=$(slurp)
        if [ -z "$slurpout" ]; then
            exit
        else
            grim -g "$slurpout" - | wl-copy --type image/png && wl-paste > "$filename"
        fi
    ;;
    output)
        grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" - | wl-copy --type image/png && wl-paste > "$filename"
    ;;
    window)
        grim -g "$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | wl-copy --type image/png && wl-paste > "$filename"
    ;;
esac
notify-send -i "$filename" "Screenshot Tool" "Screenshot saved to $filename and copied to clipboard"
