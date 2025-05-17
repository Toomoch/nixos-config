#!/usr/bin/env bash

Help()
{
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "g     Print the GPL license notification."
   echo "h     Print this Help."
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo
}

while getopts "m:b:e:h" option; do
        case $option in
                m)
                        MONITORS+=("$OPTARG")
                        ;; 
                h) # display Help
                        Help
                        exit;;
                
                b)
                        BEGINS+=("$OPTARG")
                        ;;
                e)
                        ENDS+=("$OPTARG")
                        ;;
                \?) # Invalid option
                        echo "Error: Invalid option"
                        exit;;
        esac
done

current_wp=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
echo "Current Workspace: $current_wp"

for i in "${!MONITORS[@]}"; do
        printf "%s with begin: %s end: %s\n" "${MONITORS[i]}" "${BEGINS[i]}" "${ENDS[i]}"
        workspaces=$((ENDS[i] - BEGINS[i] + 1))
        echo "Will run for $workspaces workspaces"
        for (( j=BEGINS[i]; j<=ENDS[i]; ++j)); do
                swaymsg workspace "$j" output \'"${MONITORS[i]}"\' && swaymsg workspace "$j", move workspace to output \'"${MONITORS[i]}"\' 
        done
done
# swaymsg workspace ${toString (i + begin - 1)} output \'\"${monitor}\"\' && ${pkgs.sway}/bin/swaymsg workspace ${toString (i + begin - 1)}, move workspace to output \'\"${monitor}\"\'")
