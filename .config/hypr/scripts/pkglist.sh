#!/bin/sh
# ~/.config/hypr/scripts/pkglist.sh
# Saves the explicitly installed packages to ~/.config/pkglist/ so the
# dotfiles can bring a system back: repo.txt (official repos) and aur.txt
# (foreign: AUR and local builds). Run by system-update.sh after each
# update; run it by hand after installing or removing something.
#
# Restore on a new machine:
#   sudo pacman -S --needed - < ~/.config/pkglist/repo.txt
#   yay -S --needed - < ~/.config/pkglist/aur.txt

dir="$HOME/.config/pkglist"
mkdir -p "$dir"
pacman -Qqen > "$dir/repo.txt"
pacman -Qqem > "$dir/aur.txt"
