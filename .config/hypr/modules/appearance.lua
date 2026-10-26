-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	render = {
		direct_scanout = true, -- Bypasses compositor for fullscreen windows
	},

	general = {
		gaps_in = 2,
		gaps_out = 2,
		border_size = 2,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
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
			color = 0xee1a1a1a,
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
