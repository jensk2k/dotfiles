#!/bin/sh
# ~/.config/waybar/scripts/claude.sh — Waybar custom/claude module.
# One glyph per Claude Code session, from the state files claude-hook.sh
# writes: working (accent), needs you (warn), done (accent2). The pill's CSS
# class is the most urgent state (waiting > working > done); hidden when no
# session runs. Sessions whose claude process is gone are dropped. Refreshed
# by signal 11 from the hook, and every 30 s for the "for 3m" in the tooltip.
# Click: claude-focus.sh.

dir="${XDG_RUNTIME_DIR:-/tmp}/claude-status"
palette=$HOME/.config/theme/generated/palette.lua
col() { sed -n "s/.*[^a-z]$1 = \"\([0-9a-f]*\)\".*/\1/p" "$palette"; }
c_working=$(col accent) c_waiting=$(col warn) c_done=$(col accent2)
# Nerd Font glyphs as UTF-8 bytes: robot, circle-notch, exclamation-circle, check-circle
icon=$(printf '\363\260\232\251') g_working=$(printf '\357\207\216')
g_waiting=$(printf '\357\201\252') g_done=$(printf '\357\201\230')

now=$(date +%s)
text= tooltip= class= n=0
for file in "$dir"/*; do
	[ -f "$file" ] || continue
	case "$file" in *.tmp) continue ;; esac
	old_state= since= project= pid= window=
	. "$file"
	if [ -n "$pid" ] && [ ! -d "/proc/$pid" ]; then
		rm -f "$file"
		continue
	fi
	case "$old_state" in
	working) glyph=$g_working color=$c_working label=working ;;
	waiting) glyph=$g_waiting color=$c_waiting label="needs you" ;;
	*) glyph=$g_done color=$c_done label=done ;;
	esac
	case "$old_state" in
	waiting) class=waiting ;;
	working) [ "$class" = waiting ] || class=working ;;
	*) [ -n "$class" ] || class=done ;;
	esac
	age=$(((now - ${since:-$now}) / 60))
	[ "$age" -lt 60 ] && ago="${age}m" || ago="$((age / 60))h"
	text="$text <span color='#${color:-ffffff}'>$glyph</span>"
	line="$project: $label for $ago"
	[ -n "$window" ] || line="$line (background)"
	tooltip="${tooltip:+$tooltip\\n}$line"
	n=$((n + 1))
done

if [ "$n" -eq 0 ]; then
	printf '{"text": ""}\n'
else
	printf '{"text": "%s%s", "tooltip": "%s", "class": "%s"}\n' "$icon" "$text" "$tooltip" "$class"
fi
