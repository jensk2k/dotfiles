#!/bin/sh
# ~/.config/waybar/scripts/claude-focus.sh — click on the Waybar claude pill.
# Focuses the terminal of the session that most needs you: one waiting for
# you first, then the one that finished most recently, then a working one.
# Background sessions have no window and are skipped.

dir="${XDG_RUNTIME_DIR:-/tmp}/claude-status"
best= best_rank=9 best_since=0
for file in "$dir"/*; do
	[ -f "$file" ] || continue
	case "$file" in *.tmp) continue ;; esac
	old_state= since= window=
	. "$file"
	[ -n "$window" ] || continue
	case "$old_state" in
	waiting) rank=0 ;;
	done) rank=1 ;;
	*) rank=2 ;;
	esac
	if [ "$rank" -lt "$best_rank" ] || { [ "$rank" -eq "$best_rank" ] && [ "${since:-0}" -gt "$best_since" ]; }; then
		best=$window best_rank=$rank best_since=${since:-0}
	fi
done
[ -n "$best" ] && hyprctl dispatch "hl.dsp.focus({ window = \"address:$best\" })" >/dev/null
