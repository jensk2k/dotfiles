#!/bin/sh
# ~/.config/hypr/scripts/battery-notify.sh
# Low-battery notifications, run every minute by battery-notify.timer
# (~/.config/systemd/user). While discharging: a normal notification at LOW%,
# a critical one (stays until dismissed, shown even in do-not-disturb) at
# CRITICAL%. Each fires once per discharge; plugging in resets them.
# BATTERY=/path/to/BATn overrides the battery, for testing.

LOW=15
CRITICAL=5

bat=${BATTERY:-$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)}
[ -r "$bat/capacity" ] || exit 0
capacity=$(cat "$bat/capacity")
status=$(cat "$bat/status")

# Which warning was last shown during this discharge: none, low or critical
state=${XDG_RUNTIME_DIR:-/tmp}/battery-notify.state
last=$(cat "$state" 2>/dev/null || echo none)

if [ "$status" != Discharging ]; then
	rm -f "$state"
	exit 0
fi

if [ "$capacity" -le "$CRITICAL" ] && [ "$last" != critical ]; then
	notify-send --app-name=battery --urgency=critical --icon=battery-empty \
		"Battery critical: $capacity%" "Plug in now, or the laptop will shut down."
	echo critical >"$state"
elif [ "$capacity" -le "$LOW" ] && [ "$last" = none ]; then
	notify-send --app-name=battery --icon=battery-caution \
		"Battery low: $capacity%" "Plug in soon."
	echo low >"$state"
fi
