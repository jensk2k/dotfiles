#!/bin/sh
# ~/.config/hypr/scripts/toggle-popup.sh <app-id> <command> [args...]
#
# Opens a terminal program (wiremix, bluetui, nmtui, ...) in a small floating
# kitty window under the bar, or closes it if it's already open.
# The app-id must start with "popup." so the window rule in hyprland.lua
# floats and positions it.

id="$1"
shift

addr=$(hyprctl clients -j | jq -r --arg id "$id" '.[] | select(.class == $id) | .address' | head -n 1)

if [ -n "$addr" ]; then
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null
else
    exec uwsm app -- kitty --class="$id" "$@"
fi
