#!/bin/sh
# ~/.config/waybar/scripts/updates.sh
# Waybar custom/updates: number of pending updates (repos via checkupdates,
# AUR via yay -Qua), hidden at zero. Runs hourly; refreshed with
# `pkill -RTMIN+10 waybar` after ~/.config/hypr/scripts/system-update.sh.

repo=$(checkupdates 2>/dev/null)
case $? in
	0|2) ;;                 # 2 = no updates
	*) exit 0 ;;            # offline or pacman locked: hide, try again next hour
esac
aur=$(command -v yay >/dev/null && yay -Qua 2>/dev/null)

nr=$(printf '%s' "$repo" | grep -c .)
na=$(printf '%s' "$aur" | grep -c .)
total=$((nr + na))
[ "$total" -eq 0 ] && { echo '{"text": ""}'; exit 0; }

# Tooltip: counts, then the first 20 packages (name old -> new)
list=$(printf '%s\n%s\n' "$repo" "$aur" | grep . | head -n 20 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
[ "$total" -gt 20 ] && list="$list
…"
tooltip=$(printf 'Updates: %s repo, %s AUR (SUPER + CTRL + U)\n%s' "$nr" "$na" "$list" | jq -Rs .)
printf '{"text": "%s 󰚰", "tooltip": %s, "class": "pending"}\n' "$total" "$tooltip"
