---------------------
---- KEYBINDINGS ----
---------------------

-- Modifier scheme:
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
bind(mod .. " + SHIFT + slash", hl.dsp.exec_cmd(scripts .. "keybinds.sh"), "This cheat sheet")

-- Window management
group("Windows")
bind(mod .. " + C", hl.dsp.window.close(), "Close window")
bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximize")
bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }), "Float / tile window")
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
	bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = d.dir }), "Swap window " .. d.dir)
end)
each_direction(function(d, key)
	bind(
		mod .. " + ALT + " .. key,
		hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }),
		"Resize " .. d.narrow,
		{ repeating = true }
	)
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
bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")

-- Scratchpad: a hidden workspace you can pop over anything
bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratch"), "Show / hide scratchpad")
bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }), "Send window to scratchpad")

-- Mouse: SUPER + left-drag moves, SUPER + right-drag resizes
group("Mouse")
bind(mod .. " + mouse:272", hl.dsp.window.drag(), "Move window", { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- System (SUPER + CTRL)
group("System")
bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"), "Lock screen") -- hypridle runs hyprlock
bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("~/.config/theme/apply --pick"), "Colour theme picker")
bind(mod .. " + CTRL + A", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.mixer wiremix"), "Audio mixer")
bind(mod .. " + CTRL + B", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.bluetooth bluetui"), "Bluetooth")
bind(mod .. " + CTRL + P", hl.dsp.exec_cmd(scripts .. "power-profile.sh"), "Cycle power profile")
bind(mod .. " + CTRL + I", hl.dsp.exec_cmd(scripts .. "idle-inhibit.sh toggle"), "Stay awake on / off")

-- Session
group("Session")
bind(mod .. " + Escape", hl.dsp.exec_cmd(scripts .. "power-menu.sh"), "Power menu")
bind(mod .. " + SHIFT + Escape", hl.dsp.exec_cmd("uwsm stop"), "Log out")

-- Screenshots: saved to ~/Pictures/Screenshots and copied; click the notification to annotate
group("Screenshots")
local screenshot = scripts .. "screenshot.sh"
bind("Print", hl.dsp.exec_cmd(screenshot .. " region"), "Region")
bind("SHIFT + Print", hl.dsp.exec_cmd(screenshot .. " screen"), "Whole screen")
bind(mod .. " + Print", hl.dsp.exec_cmd(screenshot .. " window"), "Active window")
bind("CTRL + Print", hl.dsp.exec_cmd(screenshot .. " region --edit"), "Region, then annotate")

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
bind(mod .. " + N", hl.dsp.exec_cmd("makoctl dismiss"), "Dismiss notification")
bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"), "Dismiss all notifications")
bind(mod .. " + ALT + N", hl.dsp.exec_cmd("makoctl restore"), "Restore last notification")
bind(
	mod .. " + CTRL + N",
	hl.dsp.exec_cmd("makoctl mode -t do-not-disturb ; pkill -RTMIN+8 waybar"),
	"Do not disturb on / off"
)
