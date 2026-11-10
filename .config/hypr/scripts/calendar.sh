#!/bin/sh
# ~/.config/hypr/scripts/calendar.sh
# Calendar notification (SUPER + CTRL + C), laid out like the Waybar clock's
# calendar tooltip: month heading, Monday first, ISO week numbers ("W46") in
# the theme's dim colour, today bold in its accent2 colour. Pressing again
# replaces the previous one.

palette=$HOME/.config/theme/generated/palette.lua
dim=$(sed -n 's/.*dim = "\([0-9a-f]*\)".*/\1/p' "$palette")
accent2=$(sed -n 's/.*accent2 = "\([0-9a-f]*\)".*/\1/p' "$palette")
today=$(date +%-d)

# cal -m -w lines: the month heading, the weekday header, then a 2-character
# ISO week number followed by 7 day cells of 3 characters each
body=$(cal -m -w --color=never | tail -n +2 | awk -v d="$today" -v dim="${dim:-808080}" -v acc="${accent2:-00ff00}" '
	NR == 1 { print " " $0; next }
	{
		wk = substr($0, 1, 2)
		gsub(/ /, "", wk)
		out = (wk == "" ? "   " : sprintf("<span color=\"#%s\">W%s</span>", dim, wk))
		for (i = 0; i < 7; i++) {
			cell = substr($0, 3 + i * 3, 3)
			n = cell
			gsub(/ /, "", n)
			if (n == d)
				cell = substr(cell, 1, 3 - length(n)) sprintf("<span color=\"#%s\"><b>%s</b></span>", acc, n)
			out = out cell
		}
		print out
	}')

# Replace the previous calendar notification instead of stacking another
id_file=${XDG_RUNTIME_DIR:-/tmp}/calendar-notification.id
replace=$(cat "$id_file" 2>/dev/null)
notify-send --app-name=calendar --icon=x-office-calendar --print-id \
	${replace:+--replace-id="$replace"} \
	"$(date '+%B %Y')" "$body" >"$id_file"
