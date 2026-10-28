-- ~/.config/theme/palette.lua
-- Single source of truth for the desktop colours. Hex without '#', no alpha.
-- Hyprland reads this file directly; for Waybar, mako, fuzzel and hyprlock,
-- run ~/.config/theme/apply after editing to regenerate their colour files.
return {
	bg = "141418", -- panel/notification background (drawn at bg_alpha)
	surface = "282830", -- raised elements: bar modules, selection, progress
	fg = "d0d0d0", -- normal text
	fg_bright = "ffffff", -- emphasized text (selected item)
	dim = "707070", -- secondary text, low-urgency borders
	muted = "595959", -- inactive window borders, calendar week numbers
	accent = "33ccff", -- primary accent (cyan)
	accent2 = "00ff99", -- secondary accent (green)
	warn = "ffaa33", -- warnings
	crit = "ff3366", -- errors, critical, urgent
	shadow = "1a1a1a", -- window shadows

	bg_alpha = 0.92, -- opacity of bg and surface where they're translucent
}
