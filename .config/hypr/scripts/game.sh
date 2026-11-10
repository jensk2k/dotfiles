#!/bin/sh
# ~/.config/hypr/scripts/game.sh <command> [args...]
# Runs a game with the performance power profile, then puts back the profile
# that was active before. If the profile changed while the game ran (charger
# plugged/unplugged, which power-profile-auto.sh acts on, or SUPER + CTRL + P),
# that newer choice is kept.
# Used by game desktop entries in ~/.local/share/applications (e.g. quake3e.desktop).

prev=$(powerprofilesctl get)
if [ "$prev" != performance ]; then
	powerprofilesctl set performance &&
		notify-send --app-name=power "Power profile: performance" "While ${1##*/} runs"
fi

"$@"
status=$?

if [ "$prev" != performance ] && [ "$(powerprofilesctl get)" = performance ]; then
	powerprofilesctl set "$prev" &&
		notify-send --app-name=power "Power profile: $prev" "${1##*/} closed"
fi
exit $status
