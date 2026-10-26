#!/bin/sh
# ~/.config/hypr/scripts/screenshot.sh <region|window|screen> [--edit]
#
# Saves a screenshot to ~/Pictures/Screenshots and copies it to the clipboard.
# Click the notification to annotate it in satty; --edit opens satty right away.
# Saving in satty overwrites the file, Enter also copies it and closes.

mode="$1"
dir="$HOME/Pictures/Screenshots"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
mkdir -p "$dir"

case "$mode" in
region)
    # Empty if you press Escape in slurp
    geom=$(slurp) || exit 0
    ;;
window)
    geom=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    ;;
screen)
    output=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')
    ;;
*)
    echo "usage: $0 <region|window|screen> [--edit]" >&2
    exit 1
    ;;
esac

if [ -n "$geom" ]; then
    grim -g "$geom" "$file" || exit 1
else
    grim -o "$output" "$file" || exit 1
fi
wl-copy <"$file"

annotate() {
    satty --filename "$file" --output-filename "$file" \
        --copy-command wl-copy \
        --actions-on-enter save-to-clipboard,save-to-file,exit
}

if [ "$2" = "--edit" ]; then
    annotate
    exit 0
fi

# "default" is the action mako runs when you click the notification
action=$(notify-send --app-name=screenshot --icon="$file" \
    --action=default=Annotate \
    "Screenshot copied" "Saved to ${file#"$HOME"/}. Click to annotate.")
if [ "$action" = "default" ]; then
    annotate
fi
