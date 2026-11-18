#!/bin/sh
# ~/.config/hypr/scripts/pkglist.sh
# Saves the explicitly installed packages to ~/.config/pkglist/<hostname>/
# so the dotfiles can bring a system back: repo.txt (official repos) and
# aur.txt (foreign: AUR and local builds). One folder per machine, so the
# laptop and the desktop don't overwrite each other's lists. Run by
# system-update.sh after each update; run it by hand after installing or
# removing something.
#
# Restore (or set up a new machine from another machine's list; leave out
# what that machine needs only for its hardware, e.g. fprintd, brightnessctl,
# power-profiles-daemon, intel-media-driver, sof-firmware on the laptop, and
# intel-ucode unless the CPU is Intel too; amd-ucode for an AMD CPU):
#   sudo pacman -S --needed - < ~/.config/pkglist/<hostname>/repo.txt
#   yay -S --needed - < ~/.config/pkglist/<hostname>/aur.txt

dir="$HOME/.config/pkglist/$(cat /etc/hostname)"
mkdir -p "$dir"
pacman -Qqen > "$dir/repo.txt"
pacman -Qqem > "$dir/aur.txt"
