#!/usr/bin/env bash
# Define the jq command (makes it reusable)
JQ_CMD='._meta.hostvars as $hostvars | [to_entries[] | select(.key != "_meta" and .key != "all") | .value.hosts[] as $hostname | ($hostvars[$hostname].ansible_host) as $ansiblehost | ($ansiblehost // $hostname) as $target | (if $ansiblehost != null and $ansiblehost != $hostname then "\($hostname) (ansible_host: \($ansiblehost))" else $hostname end) as $display | "\($display)#\($target)"] | unique[]'

# Run fzf, selecting based on display text, then extract the target value
selected_target=$(
        ansible-inventory -i inventory.yaml --list --export |
                jq -r "$JQ_CMD" |
                fzf --delimiter='#' --with-nth=1 --multi --tmux --border --prompt="Select target: " |
                awk -F '#' '{print $2}'
)

printf '%s\n' "${selected_target[@]}"
# # Check if something was selected and use it
# if [[ -n "$selected_target" ]]; then
#         echo "You selected target: $selected_target"
#         # ssh "$selected_target" # Or whatever you want to do with it
# else
#         echo "No target selected."
# fi
