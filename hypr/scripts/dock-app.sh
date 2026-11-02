#!/usr/bin/env bash
# Focus the next window of a given class, cycling through them, or launch
# the app if none are open. Used by the Super+D dock submap.
#
# Usage: dock-app.sh <window-class> <launch-command>

set -euo pipefail

class="$1"
exec_cmd="$2"

mapfile -t addresses < <(hyprctl clients -j | jq -r --arg class "$class" \
    '[.[] | select(.class == $class)] | sort_by(.address) | .[].address')

if [ "${#addresses[@]}" -eq 0 ]; then
    hyprctl dispatch "hl.dsp.exec_cmd(\"$exec_cmd\")"
else
    active_address=$(hyprctl activewindow -j | jq -r '.address // empty')

    current_index=-1
    for i in "${!addresses[@]}"; do
        if [ "${addresses[$i]}" = "$active_address" ]; then
            current_index=$i
            break
        fi
    done

    if [ "$current_index" -ge 0 ]; then
        next_index=$(( (current_index + 1) % ${#addresses[@]} ))
    else
        next_index=0
    fi

    hyprctl dispatch "hl.dsp.focus({ window = \"address:${addresses[$next_index]}\" })"
fi

hyprctl dispatch 'hl.dsp.submap("reset")'
