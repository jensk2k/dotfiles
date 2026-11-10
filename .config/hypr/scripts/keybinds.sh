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
#   --check        report binds without a description or section, and keys
#                  bound twice; exits 1 if there are any
#   --free         list unused letters, digits and punctuation keys for each
#                  modifier combination in the scheme, for picking new binds

self=$(readlink -f "$0")

if [[ -z ${1:-} ]]; then
	# Sized and centred by the "cheatsheet" window rule in modules/rules.lua
	# A smaller font than usual so three columns fit; solid background for legibility
	exec ~/.config/hypr/scripts/toggle-popup.sh keys.cheatsheet -o font_size=10 -o background_opacity=1 "$self" --show
fi

# jq helpers: modifier names from a modmask, readable key names, and
# combo -> {prefix: "SUPER + SHIFT", key: "←"} for one bind
jq_defs='
	def mods:
		[ (if . / 64 | floor % 2 == 1 then "SUPER" else empty end),
		  (if . / 4  | floor % 2 == 1 then "CTRL"  else empty end),
		  (if . / 8  | floor % 2 == 1 then "ALT"   else empty end),
		  (if .      % 2 == 1         then "SHIFT" else empty end) ];
	def key:
		{ "left": "←", "right": "→", "up": "↑", "down": "↓",
		  "mouse:272": "Left drag", "mouse:273": "Right drag",
		  "slash": "/", "Escape": "Esc", "Print": "PrtSc",
		  "period": ".", "comma": ",", "bracketleft": "[", "bracketright": "]",
		  "semicolon": ";", "minus": "-", "equal": "=", "grave": "`",
		  "XF86AudioRaiseVolume": "Vol +", "XF86AudioLowerVolume": "Vol −",
		  "XF86AudioMute": "Mute", "XF86AudioMicMute": "Mic mute",
		  "XF86MonBrightnessUp": "Bright +", "XF86MonBrightnessDown": "Bright −",
		  "XF86AudioNext": "Next", "XF86AudioPrev": "Prev",
		  "XF86AudioPlay": "Play", "XF86AudioPause": "Pause" }[.] // .;
	# SHIFT + slash is "?": show it as "?" without SHIFT (plain slash stays "/")
	def combo:
		(.key == "slash" and .modmask % 2 == 1) as $question
		| (if $question then .modmask - 1 else .modmask end) as $m
		| { prefix: ($m | mods | join(" + ")), key: (if $question then "?" else (.key | key) end) };
	def name: combo | (if .prefix == "" then "" else .prefix + " + " end) + .key;
'

if [[ $1 == --check ]]; then
	problems=$(hyprctl -j binds | jq -r "$jq_defs"'
		(.[] | select(.has_description | not) | "no description: \(name)"),
		(.[] | select(.has_description and (.description | contains("|") | not))
		 | "no section (call group() first): \(name)  \(.description)"),
		(group_by([.submap, .modmask, .key, .keycode]) | .[] | select(length > 1)
		 | "bound \(length) times: \(.[0] | name)")
	')
	if [[ -n $problems ]]; then
		printf '%s\n' "$problems"
		exit 1
	fi
	echo "keybindings ok: $(hyprctl -j binds | jq length) binds"
	exit
fi

if [[ $1 == --free ]]; then
	# modmask bits: SHIFT 1, CTRL 4, ALT 8, SUPER 64
	hyprctl -j binds | jq -r '
		[ .[] | "\(.modmask)|\(.key | ascii_upcase)" ] as $taken
		| ("ABCDEFGHIJKLMNOPQRSTUVWXYZ" | split("")) as $letters
		| ("1234567890" | split("")) as $digits
		| ["comma", "period", "slash", "semicolon", "apostrophe", "minus", "equal",
		   "bracketleft", "bracketright", "backslash", "grave", "Return", "BackSpace", "Delete"] as $punct
		| [ [64, "SUPER"], [65, "SUPER + SHIFT"], [72, "SUPER + ALT"],
		    [68, "SUPER + CTRL"], [69, "SUPER + CTRL + SHIFT"] ][]
		| .[0] as $m
		| def free(keys): [ keys[] | select(("\($m)|\(ascii_upcase)") as $k | $taken | index($k) | not) ];
		  "\(.[1])\n  letters: \(free($letters) | join(" "))\n  digits:  \(free($digits) | join(" ") | if . == "" then "-" else . end)\n  other:   \(free($punct) | join(" "))\n"
	'
	exit
fi

# One "section<TAB>keys<TAB>description" line per merged bind, in config order
entries() {
	hyprctl -j binds | jq -r "$jq_defs"'
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
	# Touchpad gestures, from the "-- Gesture: 3 ↓ | description" comments in input.lua
	sed -n 's/^-- Gesture: \([0-9]*\) \(.*[^ ]\) *| *\(.*\)/Gestures\t\1 fingers \2\t\3/p' ~/.config/hypr/modules/input.lua
}

# The modifier scheme, read from the header comment of keybindings.lua (the one
# place the rules are written down): "SUPER + SHIFT<TAB>move it / ..." lines,
# then the "Directions ..." note on its own line
legend() {
	awk '/^-- Modifier scheme/ { on = 1; next }
		on && /^--   / { sub(/^--   /, ""); split($0, a, /  +/); print a[1] "\t" a[2]; next }
		on && /^-- Directions/ { sub(/^-- /, ""); print; exit }' ~/.config/hypr/modules/keybindings.lua
}

if [[ $1 == --print ]]; then
	legend | awk -F '\t' 'NF == 2 { printf "  %-26s %s\n", $1, $2; next } { print "  " $0 "\n" }'
	entries | awk -F '\t' '$1 != last { if (NR > 1) print ""; print $1; last = $1 } { printf "  %-26s %s\n", $2, $3 }'
	exit
fi

# --show: lay the sections out in as many columns as fit, centred.
# Colours are ANSI, so they follow the kitty (desktop) theme: section titles
# in blue (accent), the modifiers dimmed and the key itself in green (accent2).
data=$(entries)
# Legend items joined with "|" for awk: "SUPER<TAB>do it / focus it|...|Directions ..."
legend_items=$(legend | paste -sd '|')

draw() {
	local cols lines
	cols=$(tput cols) lines=$(tput lines)
	printf '\033[2J\033[H'
	awk -F '\t' -v W="$cols" -v H="$lines" -v L="$legend_items" '
		function rep(n,   s) { s = ""; while (n-- > 0) s = s " "; return s }
		# "SUPER + SHIFT + ←/H" -> dim "SUPER + SHIFT + ", bold green "←/H"
		function style(combo,   p, i) {
			p = ""
			while ((i = index(combo, " + ")) > 0) { p = p substr(combo, 1, i + 2); combo = substr(combo, i + 3) }
			return "\033[2m" p "\033[0;1;32m" combo "\033[0m"
		}
		{
			if ($1 != cur) { nb++; title[nb] = $1; cur = $1 }
			n[nb]++; k[nb, n[nb]] = $2; d[nb, n[nb]] = $3
			if (length($2) > kw) kw = length($2)
			if (length($3) > dw) dw = length($3)
		}
		END {
			# Column gap and minimum side margin, in characters
			gap = 5; margin = 6; cw = kw + 2 + dw
			nc = int((W - 2 * margin + gap) / (cw + gap)); if (nc < 1) nc = 1
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
					line = style(k[b, i]) rep(kw - length(k[b, i]) + 2) d[b, i]
					rows[c, ++len[c]] = line; plain[c, len[c]] = k[b, i] rep(kw - length(k[b, i]) + 2) d[b, i]
				}
				h += bh
			}
			used = c; maxh = 0; for (c = 1; c <= used; c++) if (len[c] > maxh) maxh = len[c]

			left = int((W - (used * cw + (used - 1) * gap)) / 2); if (left < 0) left = 0
			# Legend: the modifier scheme on one line (wrapped if too wide), then the directions note
			nl = split(L, item, "|"); lg = ""; lp = ""; note = ""; nlines = 0
			for (i = 1; i <= nl; i++) {
				if (split(item[i], f, "\t") < 2) { note = item[i]; continue }
				part = "\033[1;32m" f[1] "\033[0m  " f[2]; ppart = f[1] "  " f[2]
				sep = (lp == "") ? "" : "      "
				if (lp != "" && length(lp sep ppart) > W - 2 * margin) {
					leg[++nlines] = lg; legp[nlines] = lp; lg = ""; lp = ""; sep = ""
				}
				lg = lg sep part; lp = lp sep ppart
			}
			if (lp != "") { leg[++nlines] = lg; legp[nlines] = lp }
			extra = nlines + (note != "" ? 1 : 0) + 2

			top = int((H - maxh - extra - 2) / 2); if (top < 0) top = 0
			for (r = 0; r < top; r++) print ""
			for (i = 1; i <= nlines; i++) print rep(int((W - length(legp[i])) / 2)) leg[i]
			if (note != "") print rep(int((W - length(note)) / 2)) "\033[2m" note "\033[0m"
			print ""; print ""
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
