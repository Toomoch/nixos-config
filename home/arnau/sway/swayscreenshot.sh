if [ "$1" = "area" ]; then
    slurpout=$(slurp)
    if [ -z "$slurpout" ]; then
        exit
    else
        grim -g "$slurpout" - | wl-copy --type image/png && wl-paste > $(xdg-user-dir PICTURES)/screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')
    fi
elif [ "$1" = "output" ]; then
    grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') - | wl-copy --type image/png && wl-paste > $(xdg-user-dir PICTURES)/screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')
elif [ "$1" = "window" ]; then
    grim -g "$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | wl-copy --type image/png && wl-paste > $(xdg-user-dir PICTURES)/screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')
fi