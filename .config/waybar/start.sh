#!/bin/sh
# ~/.config/waybar/start.sh — starts Waybar with this machine's config.
# config.jsonc is the laptop bar. A machine without a backlight (the desktop)
# gets desktop.jsonc, which includes config.jsonc and leaves out the
# brightness pill (Waybar shows an empty one instead of hiding it). The
# battery hides itself when there is none. Autostarted by Hyprland
# (modules/autostart.lua); after editing: pkill waybar; uwsm app -- ~/.config/waybar/start.sh &
dir="$HOME/.config/waybar"
cfg="$dir/config.jsonc"
ls /sys/class/backlight/* >/dev/null 2>&1 || cfg="$dir/desktop.jsonc"
exec waybar -c "$cfg" "$@"
