#!/bin/sh
# ~/.config/hypr/scripts/power-menu.sh
# Keyboard power menu (SUPER + Escape). The Waybar power button has its own
# native menu (~/.config/waybar/power-menu.xml) with the same actions.

choice=$(printf '%s\n' "󰌾  Lock" "󰍃  Log out" "󰤄  Suspend" "󰜉  Reboot" "󰐥  Shut down" |
    fuzzel --dmenu --prompt "Power ❯ " --lines 5 --width 20)

case "$choice" in
*Lock) loginctl lock-session ;;
*"Log out") uwsm stop ;;
*Suspend) systemctl suspend ;;
*Reboot) systemctl reboot ;;
*"Shut down") systemctl poweroff ;;
esac
