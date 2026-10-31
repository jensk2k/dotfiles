-- ~/.config/theme/palette.lua
-- Picks the colour scheme for the whole desktop. After editing, run
-- ~/.config/theme/apply (or `apply "Theme Name"`, or `apply --pick` / SUPER + SHIFT + T).
--
-- `theme` is any kitty theme name (`kitten themes` lists them). apply reads its
-- colours from kitty and derives the palette slots:
--   bg, fg            background and text
--   surface, dim      blends of bg and fg: raised elements, secondary text/borders
--   accent, accent2   the theme's blue and green
--   warn, crit        the theme's yellow and red
-- For the four colour slots it picks the normal or bright variant, whichever
-- stands out more against bg. The result is written to generated/palette.lua.
return {
	theme = "Tokyo Night",

	-- Opacity of bg and surface in Waybar, mako and fuzzel
	bg_alpha = 0.92,

	-- Shown first in the picker, before all other kitty themes
	favorites = {
		"Dracula",
		"Gruvbox Dark",
		"Catppuccin-Mocha",
		"Catppuccin-Latte",
		"Nord",
		"Tokyo Night",
		"Rosé Pine",
	},

	-- Per-theme slot overrides, hex without '#', e.g.
	-- ["Rosé Pine"] = { accent2 = "ebbcba" },
	overrides = {},
}
