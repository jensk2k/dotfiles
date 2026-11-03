#!/bin/sh
# ~/.config/hypr/scripts/power-profile.sh
# Cycles power-saver -> balanced -> performance (SUPER + CTRL + P).
# Waybar's power-profiles-daemon module updates by itself.

case $(powerprofilesctl get) in
power-saver) next=balanced ;;
balanced) next=performance ;;
*) next=power-saver ;;
esac
powerprofilesctl set "$next" && notify-send --app-name=power "Power profile: $next"
