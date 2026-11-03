#!/bin/sh
# ~/.config/hypr/scripts/idle-inhibit.sh [toggle|status]
#
# Keeps the screen from dimming, locking and suspending by holding a systemd
# idle inhibitor, which hypridle respects. Used by SUPER + CTRL + I and the
# Waybar custom/idle module, so both always show the same state.
#   toggle   start or stop the inhibitor, then refresh Waybar
#   status   print one line of JSON for Waybar

# Runs as a transient user unit, so stopping it also ends the `sleep` it holds
unit="idle-inhibit"

running() {
    systemctl --user is-active --quiet "$unit"
}

case "${1:-status}" in
toggle)
    if running; then
        systemctl --user stop "$unit"
        notify-send --app-name=idle "Idle: normal" "Screen will dim, lock and suspend as usual."
    else
        systemd-run --user --quiet --unit="$unit" \
            systemd-inhibit --what=idle --who="idle-inhibit.sh" --why="Toggled from the keyboard or Waybar" \
            sleep infinity
        notify-send --app-name=idle "Idle: staying awake" "No dimming, locking or suspending until toggled off."
    fi
    pkill -RTMIN+9 waybar
    ;;
status)
    if running; then
        echo '{"text": "󰅶", "class": "activated", "tooltip": "Staying awake (SUPER + CTRL + I)"}'
    else
        echo '{"text": "󰾪", "class": "", "tooltip": "Normal idle and lock (SUPER + CTRL + I)"}'
    fi
    ;;
esac
