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

-- Gaming mouse: flat curve (no acceleration), so pointer travel depends only on
-- distance, not speed. The touchpad and trackpoint keep libinput's adaptive curve.
-- Device names from `hyprctl devices`.
hl.device({
	name = "--hitscan-hyperlight-1",
	accel_profile = "flat",
})

-- Touchpad gestures. Three fingers: left/right switches workspaces (follows
-- the fingers), down pulls in the drop-down terminal, up puts away whatever
-- special workspace is showing (drop-down or scratchpad). Four fingers: up
-- finds a window (like SUPER + /), down shows the scratchpad.
-- Each "-- Gesture: fingers direction | description" line feeds the cheat sheet
-- (scripts/keybinds.sh), since `hyprctl binds` doesn't list gestures.
-- Gesture: 3 ← → | Switch workspace
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Name of the special workspace showing on the focused monitor ("dropdown"), or nil
local function shown_special()
	local ws = hl.get_active_special_workspace()
	return ws and ws.name:gsub("^special:", "") or nil
end

-- Show a special workspace; does nothing if it's already showing
local function show_special(name)
	return function()
		if shown_special() ~= name then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
		end
	end
end

-- Gesture: 3 ↓ | Drop-down terminal
hl.gesture({ fingers = 3, direction = "down", action = show_special("dropdown") })
-- Gesture: 3 ↑ | Hide drop-down / scratchpad
hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		local name = shown_special()
		if name then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
		end
	end,
})
-- Gesture: 4 ↑ | Find a window
hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.exec_cmd("~/.config/hypr/scripts/window-finder.sh")
	end,
})
-- Gesture: 4 ↓ | Show scratchpad
hl.gesture({ fingers = 4, direction = "down", action = show_special("scratch") })
