---------------------
---- KEYBINDINGS ----
---------------------

-- Modifier scheme (shown as the legend on the SUPER + ? cheat sheet, which
-- parses these lines: keep "--   MODIFIERS<2+ spaces>meaning" and the Directions line):
--   SUPER           do it / focus it
--   SUPER + SHIFT   move it / send it / the stronger version
--   SUPER + ALT     resize / a variant
--   SUPER + CTRL    system: settings, toggles, session
-- Directions work with both the arrow keys and vim-style h/j/k/l.
--
-- Every bind gets a description: SUPER + ? (scripts/keybinds.sh) shows them
-- from `hyprctl binds` as a cheat sheet, under the section set by group(),
-- merging binds that share one (e.g. arrow + hjkl).

local terminal = "kitty"
local launcher = "fuzzel"
local scripts = "~/.config/hypr/scripts/"

local mod = "SUPER"

-- Cheat sheet section for the binds that follow
local section = ""
local function group(name)
	section = name
end

-- hl.bind with a description (stored as "Section|Description"), plus any other bind options
local function bind(keys, action, description, opts)
	opts = opts or {}
	opts.description = section .. "|" .. description
	hl.bind(keys, action, opts)
end

-- Apps
group("Apps")
bind(mod .. " + Space", hl.dsp.exec_cmd(launcher), "App launcher")
bind(mod .. " + Q", hl.dsp.exec_cmd(terminal), "Terminal")
bind(mod .. " + W", hl.dsp.exec_cmd("brave"), "Browser")
bind(mod .. " + E", hl.dsp.exec_cmd(terminal .. " yazi"), "File manager (yazi)")
bind(
	mod .. " + V",
	hl.dsp.exec_cmd('cliphist list | fuzzel --dmenu --prompt "Clipboard ❯ " | cliphist decode | wl-copy'),
	"Clipboard history"
)
bind(mod .. " + slash", hl.dsp.exec_cmd(scripts .. "window-finder.sh"), "Find a window")
bind(mod .. " + period", hl.dsp.exec_cmd(scripts .. "emoji.sh"), "Emoji picker")
bind(mod .. " + SHIFT + slash", hl.dsp.exec_cmd(scripts .. "keybinds.sh"), "This cheat sheet")

-- Window management
group("Windows")
bind(mod .. " + C", hl.dsp.window.close(), "Close window")
bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximize")
bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }), "Float / tile window")
-- Directional focus only moves between tiled windows, so this jumps between the layers
bind(mod .. " + ALT + T", function()
	local w = hl.get_active_window()
	hl.dispatch(hl.dsp.focus({ window = (w and w.floating) and "tiled" or "floating" }))
end, "Focus floating / tiled windows")
bind(mod .. " + D", hl.dsp.layout("togglesplit"), "Flip split direction")
bind(mod .. " + P", hl.dsp.window.pseudo(), "Pseudo-tile window")
bind(mod .. " + O", hl.dsp.window.pin(), "Pin window to all workspaces")

-- Groups (tabbed windows)
group("Groups")
bind(mod .. " + G", hl.dsp.group.toggle(), "Group windows (tabs)")
bind(mod .. " + ALT + Tab", hl.dsp.group.next(), "Next tab in group")

-- Focus (SUPER), swap (SUPER + SHIFT) and resize (SUPER + ALT, hold to repeat)
group("Focus, swap, resize")
local step = 40
local directions = {
	{ keys = { "left", "H" }, dir = "left", x = -step, y = 0, narrow = "narrower" },
	{ keys = { "down", "J" }, dir = "down", x = 0, y = step, narrow = "taller" },
	{ keys = { "up", "K" }, dir = "up", x = 0, y = -step, narrow = "shorter" },
	{ keys = { "right", "L" }, dir = "right", x = step, y = 0, narrow = "wider" },
}
-- Calls fn(direction, key) for every arrow and hjkl key
local function each_direction(fn)
	for _, d in ipairs(directions) do
		for _, key in ipairs(d.keys) do
			fn(d, key)
		end
	end
end
-- One function at a time, so the cheat sheet lists them grouped by function
each_direction(function(d, key)
	bind(mod .. " + " .. key, hl.dsp.focus({ direction = d.dir }), "Focus " .. d.dir)
end)
each_direction(function(d, key)
	-- Tiled windows swap places; floating ones move by one step instead
	bind(mod .. " + SHIFT + " .. key, function()
		local w = hl.get_active_window()
		if w and w.floating then
			hl.dispatch(hl.dsp.window.move({ x = d.x, y = d.y, relative = true }))
		else
			hl.dispatch(hl.dsp.window.swap({ direction = d.dir }))
		end
	end, "Swap / move window " .. d.dir)
end)
each_direction(function(d, key)
	bind(
		mod .. " + ALT + " .. key,
		hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }),
		"Resize " .. d.narrow,
		{ repeating = true }
	)
end)

-- Resize mode (a submap): SUPER + R enters it; then plain h/j/k/l or arrows
-- resize without holding modifiers, SHIFT for bigger steps. Esc, Enter or
-- SUPER + R leave. Waybar's hyprland/submap module shows "resize" meanwhile.
group("Resize mode")
bind(mod .. " + R", hl.dsp.submap("resize"), "Enter resize mode")
hl.define_submap("resize", function()
	-- Normal steps first, then big ones, so the cheat sheet groups them by function
	for _, big in ipairs({ false, true }) do
		local scale, prefix, suffix = big and 3 or 1, big and "SHIFT + " or "", big and " (big steps)" or ""
		each_direction(function(d, key)
			bind(
				prefix .. key,
				hl.dsp.window.resize({ x = d.x * scale, y = d.y * scale, relative = true }),
				"Resize " .. d.narrow .. suffix,
				{ repeating = true }
			)
		end)
	end
	for _, key in ipairs({ "Escape", "Return", mod .. " + R" }) do
		bind(key, hl.dsp.submap("reset"), "Leave resize mode")
	end
end)

-- Workspaces: SUPER + 1..0 to switch, SUPER + SHIFT + 1..0 to send the window there
group("Workspaces")
for i = 1, 10 do
	local key = i % 10
	bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Go to workspace 1-10")
	bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Send window to workspace 1-10")
end

-- Cycle through open workspaces; SUPER + CTRL + Tab jumps back to the previous one
bind(mod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")
bind(mod .. " + CTRL + Tab", hl.dsp.focus({ workspace = "previous" }), "Back to last workspace")

-- Scratchpad: a hidden workspace you can pop over anything
bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratch"), "Show / hide scratchpad")
bind(mod .. " + grave", hl.dsp.workspace.toggle_special("dropdown"), "Drop-down terminal")
bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }), "Send window to scratchpad")

-- Mouse: SUPER + left-drag moves, SUPER + right-drag resizes
group("Mouse")
bind(mod .. " + mouse:272", hl.dsp.window.drag(), "Move window", { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- System (SUPER + CTRL)
group("System")
bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"), "Lock screen") -- hypridle runs hyprlock
bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("~/.config/theme/apply --pick"), "Colour theme picker")
bind(mod .. " + CTRL + SHIFT + T", hl.dsp.exec_cmd("~/.config/theme/apply --previous"), "Previous colour theme")
bind(mod .. " + CTRL + A", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.mixer wiremix"), "Audio mixer")
bind(mod .. " + CTRL + B", hl.dsp.exec_cmd(scripts .. "bluetooth-menu.sh"), "Bluetooth devices")
bind(mod .. " + CTRL + SHIFT + B", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.bluetooth bluetui"), "Bluetooth (bluetui)")
bind(mod .. " + CTRL + W", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.network nmtui connect"), "Wi-Fi")
bind(mod .. " + CTRL + C", hl.dsp.exec_cmd(scripts .. "calendar.sh"), "Calendar (this month)")
bind(mod .. " + CTRL + P", hl.dsp.exec_cmd(scripts .. "power-profile.sh"), "Cycle power profile")
bind(mod .. " + CTRL + I", hl.dsp.exec_cmd(scripts .. "idle-inhibit.sh toggle"), "Stay awake on / off")
bind(mod .. " + CTRL + U", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.update " .. scripts .. "system-update.sh"), "System update")
bind(mod .. " + CTRL + M", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.btop btop"), "System monitor (btop)")

-- Session
group("Session")
bind(mod .. " + Escape", hl.dsp.exec_cmd(scripts .. "power-menu.sh"), "Power menu")
bind(mod .. " + SHIFT + Escape", hl.dsp.exec_cmd("uwsm stop"), "Log out")

-- Screen zoom: magnifies the whole screen around the pointer (cursor.zoom_factor)
group("Zoom")
local function zoom(factor)
	return function()
		local z = factor and math.max(1, math.min(hl.get_config("cursor.zoom_factor") * factor, 10)) or 1
		hl.config({ cursor = { zoom_factor = z } })
	end
end
bind(mod .. " + equal", zoom(1.5), "Zoom in", { repeating = true })
bind(mod .. " + minus", zoom(1 / 1.5), "Zoom out", { repeating = true })
bind(mod .. " + SHIFT + minus", zoom(nil), "Reset zoom")

-- Screenshots: saved to ~/Pictures/Screenshots and copied; click the notification to annotate
group("Screenshots")
local screenshot = scripts .. "screenshot.sh"
bind("Print", hl.dsp.exec_cmd(screenshot .. " region"), "Region")
bind("SHIFT + Print", hl.dsp.exec_cmd(screenshot .. " screen"), "Whole screen")
bind(mod .. " + Print", hl.dsp.exec_cmd(screenshot .. " window"), "Active window")
bind("CTRL + Print", hl.dsp.exec_cmd(screenshot .. " region --edit"), "Region, then annotate")
bind(mod .. " + I", hl.dsp.exec_cmd("hyprpicker -a -n -f hex"), "Pick a colour (copies hex)") -- I: the eyedropper key in GIMP, Krita, Figma

-- Volume, brightness and media keys (work on the lock screen too)
group("Media keys")
bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	"Volume up",
	{ locked = true, repeating = true }
)
bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	"Volume down",
	{ locked = true, repeating = true }
)
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), "Mute", { locked = true })
bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	"Mute microphone",
	{ locked = true }
)
bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
	"Brightness up",
	{ locked = true, repeating = true }
)
bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
	"Brightness down",
	{ locked = true, repeating = true }
)
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), "Next track", { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "Play / pause", { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), "Play / pause", { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), "Previous track", { locked = true })

-- Notifications (Mako)
group("Notifications")
-- SUPER + M does what clicking the newest notification does; SHIFT picks one of its actions
bind(mod .. " + M", hl.dsp.exec_cmd("makoctl invoke"), "Act on notification (like a click)")
bind(
	mod .. " + SHIFT + M",
	hl.dsp.exec_cmd('makoctl menu fuzzel --dmenu --prompt "Action ❯ "'),
	"Choose a notification action"
)
bind(mod .. " + N", hl.dsp.exec_cmd("makoctl dismiss"), "Dismiss notification")
bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"), "Dismiss all notifications")
bind(mod .. " + ALT + N", hl.dsp.exec_cmd("makoctl restore"), "Restore last notification")
bind(
	mod .. " + CTRL + N",
	hl.dsp.exec_cmd("makoctl mode -t do-not-disturb ; pkill -RTMIN+8 waybar"),
	"Do not disturb on / off"
)
