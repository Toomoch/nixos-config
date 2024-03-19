#!/usr/bin/env bash

selected="$(find "$HOME"/projects -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | fzf --header="Pick a project")"

if [[ -z $selected ]]; then
    exit 0
fi

selected="$HOME/projects/$selected"
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

if [ -z "$TMUX" ]; then   # si estamos fuera de tmux hacemos attach
    tmux attach -t "$selected_name"
else                    # si estamos dentro solo cambiamos el cliente
    tmux switch-client -t "$selected_name"
fi
