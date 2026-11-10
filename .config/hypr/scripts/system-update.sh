#!/bin/sh
# ~/.config/hypr/scripts/system-update.sh
# Runs the system update (yay: repos, then AUR) in a bar popup
# (SUPER + CTRL + U, or a click on the update count), then refreshes the
# Waybar count (signal 10) and waits for a key so the output can be read.

yay -Syu
status=$?
pkill -RTMIN+10 waybar
echo
if [ "$status" -eq 0 ]; then
	echo "Done. Press a key to close."
else
	echo "yay exited with status $status. Press a key to close."
fi
# Single key, no Enter needed
stty -icanon -echo 2>/dev/null
dd bs=1 count=1 >/dev/null 2>&1
