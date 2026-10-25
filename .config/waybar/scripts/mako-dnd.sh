#!/usr/bin/env bash
# Prints one line of JSON for Waybar: icon, CSS class, tooltip
if makoctl mode | grep -qx 'do-not-disturb'; then
  echo '{"text": "󰂛", "class": "dnd", "tooltip": "Do not disturb: on"}'
else
  echo '{"text": "󰂚", "class": "", "tooltip": "Notifications: on"}'
fi
