require("modules/keybindings")
require("modules/autostart")

------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "1.0",
})

-- Per-output layout from nwg-displays; overrides the catch-all above
require("monitors")
require("workspaces")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Under uwsm, environment variables are best placed in ~/.config/uwsm/env
-- so every app in the session sees them. These two are harmless here.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	cursor = {
		no_hardware_cursors = 0, -- Enforces hardware cursor rendering
	},

	render = {
		direct_scanout = true, -- Bypasses compositor for fullscreen windows
	},

	general = {
		gaps_in = 5,
		gaps_out = 10,
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

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "eu", -- EurKEY
		kb_variant = "",
		kb_options = "",

		--follow_mouse = 1,
		--sensitivity = 0, -- -1.0 to 1.0, 0 = unchanged
		--accel_profile = "flat",
		--force_no_accel = true,

		touchpad = {
			natural_scroll = true, -- set true for "phone-style" scrolling
		},
	},
})

-- Three-finger horizontal swipe switches workspaces
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore apps asking to maximize themselves; the tiling layout decides size.
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix dragging issues with XWayland (older X11) apps
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Small settings dialogs float instead of tiling
hl.window_rule({
	name = "float-settings-dialogs",
	match = { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor)$" },
	float = true,
})

-- Browser picture-in-picture video floats and follows you across workspaces
hl.window_rule({
	name = "pip-float-pin",
	match = { title = "^Picture.in.[Pp]icture$" },
	float = true,
	pin = true,
})

hl.window_rule({
	name = "bar-popups",
	match = { class = "^popup\\." },
	float = true,
	pin = true,
	size = { 720, 460 },
	move = { "monitor_w - window_w - 10", 40 },
})
