#!/bin/sh
# ~/.config/hypr/scripts/bluetooth-menu.sh
# Bluetooth quick menu (SUPER + CTRL + B): one line per paired device to
# connect or disconnect it, plus Bluetooth on/off and "open bluetui" for
# scanning and pairing (also SUPER + CTRL + SHIFT + B). Results show as a
# notification.

notify() { notify-send --app-name=bluetooth --icon=bluetooth "$@"; }

powered=$(bluetoothctl show | awk '/Powered:/ { print $2 }')

# One "mac<TAB>connected<TAB>icon<TAB>name" line per paired device
devices=$(bluetoothctl devices Paired | while read -r _ mac name; do
	info=$(bluetoothctl info "$mac")
	connected=$(printf '%s\n' "$info" | awk '/Connected:/ { print $2 }')
	case $(printf '%s\n' "$info" | awk '/Icon:/ { print $2 }') in
	audio-headphones | audio-headset) icon=󰋋 ;;
	audio-card | audio-speakers) icon=󰓃 ;;
	input-keyboard) icon=󰌌 ;;
	input-mouse) icon=󰍽 ;;
	input-gaming) icon=󰊗 ;;
	phone) icon=󰏲 ;;
	*) icon=󰂯 ;;
	esac
	printf '%s\t%s\t%s\t%s\n' "$mac" "$connected" "$icon" "$name"
done)

# Menu lines: devices first, then the fixed actions (in the same order as below)
menu=$(printf '%s\n' "$devices" | awk -F '\t' 'NF { printf "%s  %-28s %s\n", $3, $4, ($2 == "yes" ? "disconnect" : "connect") }')
if [ "$powered" = yes ]; then toggle="󰂲  Turn Bluetooth off"; else toggle="󰂯  Turn Bluetooth on"; fi
menu=$(printf '%s\n%s\n%s' "$menu" "$toggle" "󰒓  Open bluetui (scan, pair)" | sed '/^$/d')

i=$(printf '%s\n' "$menu" | fuzzel --dmenu --index --prompt "Bluetooth ❯ " --width 50) || exit 0
count=$(printf '%s\n' "$devices" | grep -c .)

if [ "$i" -lt "$count" ]; then
	line=$(printf '%s\n' "$devices" | sed -n "$((i + 1))p")
	mac=$(printf '%s' "$line" | cut -f1)
	name=$(printf '%s' "$line" | cut -f4)
	if [ "$(printf '%s' "$line" | cut -f2)" = yes ]; then
		bluetoothctl disconnect "$mac" >/dev/null && notify "Disconnected: $name" || notify "Couldn't disconnect $name"
	else
		[ "$powered" = yes ] || bluetoothctl power on >/dev/null
		bluetoothctl connect "$mac" >/dev/null && notify "Connected: $name" ||
			notify "Couldn't connect $name" "Is it switched on and in range?"
	fi
elif [ "$i" -eq "$count" ]; then
	if [ "$powered" = yes ]; then
		bluetoothctl power off >/dev/null && notify "Bluetooth off"
	else
		bluetoothctl power on >/dev/null && notify "Bluetooth on"
	fi
else
	exec ~/.config/hypr/scripts/toggle-popup.sh popup.bluetooth bluetui
fi
