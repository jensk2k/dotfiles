#!/bin/sh
# ~/.config/hypr/scripts/emoji.sh
# Emoji picker (SUPER + .): every emoji with its name in fuzzel; type to search
# by name ("thumbs up"). The pick is copied to the clipboard and, if wtype is
# installed, also typed into the focused window.
# Needs: unicode-emoji (the list), noto-fonts-emoji (to draw them), wtype (optional):
#   sudo pacman -S unicode-emoji noto-fonts-emoji wtype

data=/usr/share/unicode/emoji/emoji-test.txt
if [ ! -r "$data" ]; then
	notify-send --app-name=emoji "Emoji picker" "Missing $data: sudo pacman -S unicode-emoji"
	exit 1
fi

# "1F600 ; fully-qualified # 😀 E1.0 grinning face" -> "😀  grinning face"
pick=$(awk -F '# ' '/; fully-qualified/ { split($2, f, " "); name = $2; sub(/^[^ ]+ E[0-9.]+ /, "", name); print f[1] "  " name }' "$data" |
	fuzzel --dmenu --prompt "Emoji ❯ " --width 50 --lines 15) || exit 0

emoji=${pick%%  *}
[ -n "$emoji" ] || exit 0
printf '%s' "$emoji" | wl-copy
command -v wtype >/dev/null && wtype -- "$emoji"
