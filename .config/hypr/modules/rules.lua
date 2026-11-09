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

-- A window alone on its workspace fills it edge to edge: no gaps, border or
-- rounding. Matches one tiled window (w[tv1]) or a maximized one (f[1]).
-- Floating windows keep their border and rounding.
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0 })
hl.window_rule({
	name = "solo-single-tiled",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})
hl.window_rule({
	name = "solo-maximized",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

-- Small settings dialogs float instead of tiling
hl.window_rule({
	name = "float-settings-dialogs",
	match = { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor|firewall-config)$" },
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
	match = { class = "^popup\\..*" }, -- rule patterns must match the whole class
	float = true,
	pin = true,
	size = { 720, 460 },
	move = { "monitor_w - window_w - 10", 40 },
})

-- Keybinding cheat sheet (SUPER + ?, scripts/keybinds.sh): almost fullscreen, centred
hl.window_rule({
	name = "cheatsheet",
	match = { class = "^keys\\.cheatsheet$" },
	float = true,
	size = { "monitor_w * 0.9", "monitor_h * 0.85" },
	center = true,
})

-- Drop-down terminal (SUPER + `): a hidden special workspace that starts kitty
-- the first time it's opened; the terminal keeps running while hidden. Shown as
-- a wide panel under the bar.
hl.workspace_rule({ workspace = "special:dropdown", on_created_empty = "uwsm app -- kitty --class dropdown -o background_opacity=1" })
hl.window_rule({
	name = "dropdown-terminal",
	match = { class = "^dropdown$" },
	float = true,
	size = { "monitor_w - 20", "monitor_h * 0.45" },
	move = { 10, 44 },
})
