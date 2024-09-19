#!/usr/bin/env bash

directories=( "$HOME/projects" "/workspace/projects" "$HOME/assig" )
final_directories=()

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        final_directories+=("$dir")
    fi
done 

selected="$(find "${final_directories[@]}" -mindepth 1 -maxdepth 1 -type d | fzf --header="Pick a project")"

if [[ -z $selected ]]; then
    exit 0
fi

#selected="$HOME/$selected"
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
