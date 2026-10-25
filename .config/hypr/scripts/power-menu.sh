#!/bin/sh
# ~/.config/hypr/scripts/power-menu.sh
# Small power menu shown with fuzzel. Used by the Waybar power button.

choice=$(printf '%s\n' "Lock" "Log out" "Suspend" "Reboot" "Shut down" |
  fuzzel --dmenu --prompt "Power ❯ " --lines 5 --width 20)

case "$choice" in
"Lock") loginctl lock-session ;;
"Log out") uwsm stop ;;
"Suspend") systemctl suspend ;;
"Reboot") systemctl reboot ;;
"Shut down") systemctl poweroff ;;
esac
