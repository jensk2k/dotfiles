#!/bin/sh
# ~/.config/hypr/scripts/power-profile-auto.sh
# Switches the power profile when the charger is plugged in or out, run by
# power-profile-auto.service (~/.config/systemd/user). Unplugging remembers
# the current profile and switches to power-saver; plugging in restores the
# remembered one. Only plug/unplug changes anything, so a profile picked by
# hand (SUPER + CTRL + P) stays until the next change. Starting up on battery
# counts as an unplug.

ac=/sys/class/power_supply/AC/online
saved=${XDG_RUNTIME_DIR:-/tmp}/power-profile-auto.saved

set_profile() {
	[ "$(powerprofilesctl get)" = "$1" ] && return
	powerprofilesctl set "$1" && notify-send --app-name=power "Power profile: $1" "$2"
}

on_change() {
	if [ "$(cat "$ac")" = 1 ]; then
		set_profile "$(cat "$saved" 2>/dev/null || echo balanced)" "Charger connected"
		rm -f "$saved"
	else
		powerprofilesctl get >"$saved"
		set_profile power-saver "On battery"
	fi
}

last=$(cat "$ac")
[ "$last" = 0 ] && on_change

# upower prints a line for every power event (battery level updates too), so
# only act when the charger state actually changed
upower --monitor | while read -r _; do
	now=$(cat "$ac")
	[ "$now" = "$last" ] && continue
	last=$now
	on_change
done
