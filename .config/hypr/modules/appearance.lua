-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Colours from the current theme (~/.config/theme); hex strings without '#'
local p = dofile(os.getenv("HOME") .. "/.config/theme/generated/palette.lua")

hl.config({
	render = {
		direct_scanout = true, -- Bypasses compositor for fullscreen windows
	},

	general = {
		gaps_in = 2,
		gaps_out = 2,
		border_size = 2,

		col = {
			active_border = { colors = { "rgba(" .. p.accent .. "ee)", "rgba(" .. p.accent2 .. "ee)" }, angle = 45 },
			inactive_border = "rgba(" .. p.dim .. "aa)",
		},

		resize_on_border = true, -- drag borders/gaps with the mouse to resize
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 6,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(00000099)",
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	-- Built-in default animations; see the wiki's Animations page to tune them.
	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	--	misc = {
	--		force_default_wallpaper = 0, -- no mascot wallpapers; hyprpaper draws ours
	--		disable_hyprland_logo = true,
	--	vrr = 1,
	--	},
})

-- Special workspaces (drop-down terminal, scratchpad) slide down from the top
-- like a Quake console. "top" forces the side (Hyprland 0.57 accepts a side for
-- workspace slides too, though the wiki only documents it for windows)
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
-- The side is where the slide happens on the way in; for the way out it's the
-- opposite edge, so "bottom" makes a hidden workspace go back up.
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert bottom" })
