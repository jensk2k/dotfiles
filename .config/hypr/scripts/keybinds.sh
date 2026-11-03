#!/usr/bin/env bash
# ~/.config/hypr/scripts/keybinds.sh [--show | --print]
#
# Keybinding cheat sheet (SUPER + ?). Reads the live binds from `hyprctl binds`:
# each description is "Section|Description" (set by group() and bind() in
# modules/keybindings.lua). Binds sharing a description and modifiers are
# merged into one line, e.g. "SUPER + ←/H  Focus left".
#   (no argument)  toggle a near-fullscreen kitty window showing --show
#   --show         draw the sheet in columns in this terminal; any key closes
#   --print        plain text to stdout

self=$(readlink -f "$0")

if [[ -z ${1:-} ]]; then
	# Sized and centred by the "cheatsheet" window rule in modules/rules.lua
	# A smaller font than usual so three columns fit; solid background for legibility
	exec ~/.config/hypr/scripts/toggle-popup.sh keys.cheatsheet -o font_size=10 -o background_opacity=1 "$self" --show
fi

# One "section<TAB>keys<TAB>description" line per merged bind, in config order
entries() {
	hyprctl -j binds | jq -r '
		def mods:
			[ (if . / 64 | floor % 2 == 1 then "SUPER" else empty end),
			  (if . / 4  | floor % 2 == 1 then "CTRL"  else empty end),
			  (if . / 8  | floor % 2 == 1 then "ALT"   else empty end),
			  (if .      % 2 == 1         then "SHIFT" else empty end) ];
		def key:
			{ "left": "←", "right": "→", "up": "↑", "down": "↓",
			  "mouse:272": "Left drag", "mouse:273": "Right drag",
			  "mouse_down": "Scroll ↓", "mouse_up": "Scroll ↑",
			  "slash": "?", "Escape": "Esc", "Print": "PrtSc",
			  "XF86AudioRaiseVolume": "Vol +", "XF86AudioLowerVolume": "Vol −",
			  "XF86AudioMute": "Mute", "XF86AudioMicMute": "Mic mute",
			  "XF86MonBrightnessUp": "Bright +", "XF86MonBrightnessDown": "Bright −",
			  "XF86AudioNext": "Next", "XF86AudioPrev": "Prev",
			  "XF86AudioPlay": "Play", "XF86AudioPause": "Pause" }[.] // .;
		# SHIFT + slash is "?": drop SHIFT there
		def combo:
			(if .key == "slash" then (.modmask - 1) else .modmask end) as $m
			| { prefix: ($m | mods | join(" + ")), key: (.key | key) };

		[ .[] | select(.has_description)
		  | (.description | split("|")) as $d
		  | { section: (if ($d | length) > 1 then $d[0] else "Other" end), description: $d[-1] } + combo ]
		| reduce .[] as $b ([];
			(map(.section + "|" + .description + "|" + .prefix)
			 | index($b.section + "|" + $b.description + "|" + $b.prefix)) as $i
			| if $i == null then . + [$b + {keys: [$b.key]}]
			  else .[$i].keys += [$b.key] end)
		| .[]
		| (.keys | if length > 4 then "\(.[0])…\(.[-1])" else join("/") end) as $keys
		| "\(.section)\t\((if .prefix == "" then "" else .prefix + " + " end) + $keys)\t\(.description)"
	'
}

if [[ $1 == --print ]]; then
	entries | awk -F '\t' '$1 != last { if (NR > 1) print ""; print $1; last = $1 } { printf "  %-26s %s\n", $2, $3 }'
	exit
fi

# --show: lay the sections out in as many columns as fit, centred.
# Colours are ANSI, so they follow the kitty (desktop) theme:
# section titles in blue (accent), keys in green (accent2).
data=$(entries)

draw() {
	local cols lines
	cols=$(tput cols) lines=$(tput lines)
	printf '\033[2J\033[H'
	awk -F '\t' -v W="$cols" -v H="$lines" '
		function rep(n,   s) { s = ""; while (n-- > 0) s = s " "; return s }
		{
			if ($1 != cur) { nb++; title[nb] = $1; cur = $1 }
			n[nb]++; k[nb, n[nb]] = $2; d[nb, n[nb]] = $3
			if (length($2) > kw) kw = length($2)
			if (length($3) > dw) dw = length($3)
		}
		END {
			gap = 5; cw = kw + 2 + dw
			nc = int((W + gap) / (cw + gap)); if (nc < 1) nc = 1
			total = 0; for (b = 1; b <= nb; b++) total += n[b] + 2
			target = int((total + nc - 1) / nc)

			# Fill columns in order, moving on when the next section would overflow
			c = 1; h = 0
			for (b = 1; b <= nb; b++) {
				bh = n[b] + 1
				if (h > 0 && h + bh > target && c < nc) { c++; h = 0 }
				if (h > 0) { rows[c, ++len[c]] = ""; plain[c, len[c]] = ""; h++ }
				rows[c, ++len[c]] = "\033[1;34m" title[b] "\033[0m"; plain[c, len[c]] = title[b]
				for (i = 1; i <= n[b]; i++) {
					line = "\033[32m" k[b, i] "\033[0m" rep(kw - length(k[b, i]) + 2) d[b, i]
					rows[c, ++len[c]] = line; plain[c, len[c]] = k[b, i] rep(kw - length(k[b, i]) + 2) d[b, i]
				}
				h += bh
			}
			used = c; maxh = 0; for (c = 1; c <= used; c++) if (len[c] > maxh) maxh = len[c]

			left = int((W - (used * cw + (used - 1) * gap)) / 2); if (left < 0) left = 0
			top = int((H - maxh - 2) / 2); if (top < 0) top = 0
			for (r = 0; r < top; r++) print ""
			for (r = 1; r <= maxh; r++) {
				out = rep(left)
				for (c = 1; c <= used; c++) {
					s = (r <= len[c]) ? rows[c, r] : ""; p = (r <= len[c]) ? plain[c, r] : ""
					out = out s (c < used ? rep(cw - length(p) + gap) : "")
				}
				print out
			}
			hint = "any key closes"
			printf "\n%s\033[2m%s\033[0m", rep(int((W - length(hint)) / 2)), hint
		}
	' <<<"$data"
}

tput civis
trap 'tput cnorm' EXIT
trap draw WINCH
draw
# A resize (the window rule sizing the window) interrupts read; only a key ends it
until read -rsn1; do :; done
