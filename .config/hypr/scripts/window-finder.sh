#!/bin/sh
# ~/.config/hypr/scripts/window-finder.sh
# Window finder (SUPER + /): lists every window as "workspace  app  title" in
# fuzzel, sorted by workspace; Enter focuses the chosen window, switching to
# its workspace. Type to filter by any of the three.

windows=$(hyprctl -j clients | jq -r '
	[ .[] | select(.mapped and .class != "") ]
	| sort_by(.workspace.id, .focusHistoryID)
	| .[]
	| [ .address,
	    (if .workspace.id < 0 then (.workspace.name | sub("^special:"; "*")) else (.workspace.id | tostring) end),
	    .class,
	    (.title | if length > 70 then .[:69] + "…" else . end) ]
	| @tsv')
[ -n "$windows" ] || exit 0

i=$(printf '%s\n' "$windows" | awk -F '\t' '{ printf "%-4s %-18s %s\n", $2, $3, $4 }' |
	fuzzel --dmenu --index --prompt "Window ❯ " --width 90 --lines 15) || exit 0

addr=$(printf '%s\n' "$windows" | sed -n "$((i + 1))p" | cut -f1)
[ -n "$addr" ] && hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
