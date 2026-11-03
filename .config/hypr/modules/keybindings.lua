---------------------
---- KEYBINDINGS ----
---------------------

-- Modifier scheme:
--   SUPER           do it / focus it
--   SUPER + SHIFT   move it / send it / the stronger version
--   SUPER + ALT     resize / a variant
--   SUPER + CTRL    system: settings, toggles, session
-- Directions work with both the arrow keys and vim-style h/j/k/l.

local terminal = "kitty"
local launcher = "fuzzel"
local scripts = "~/.config/hypr/scripts/"

local mod = "SUPER"

-- Apps
hl.bind(mod .. " + Space", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("brave"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(terminal .. " yazi"))

-- Clipboard history picker
hl.bind(
	mod .. " + V",
	hl.dsp.exec_cmd('cliphist list | fuzzel --dmenu --prompt "Clipboard ❯ " | cliphist decode | wl-copy')
)

-- Window management
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + D", hl.dsp.layout("togglesplit")) -- flip horizontal/vertical split
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + O", hl.dsp.window.pin()) -- keep a floating window on all workspaces

-- Groups (tabbed windows)
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + ALT + Tab", hl.dsp.group.next())

-- Focus (SUPER), swap (SUPER + SHIFT) and resize (SUPER + ALT, hold to repeat)
local step = 40
local directions = {
	{ keys = { "left", "H" }, dir = "left", x = -step, y = 0 },
	{ keys = { "down", "J" }, dir = "down", x = 0, y = step },
	{ keys = { "up", "K" }, dir = "up", x = 0, y = -step },
	{ keys = { "right", "L" }, dir = "right", x = step, y = 0 },
}
for _, d in ipairs(directions) do
	for _, key in ipairs(d.keys) do
		hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = d.dir }))
		hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = d.dir }))
		hl.bind(
			mod .. " + ALT + " .. key,
			hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }),
			{ repeating = true }
		)
	end
end

-- Workspaces: SUPER + 1..0 to switch, SUPER + SHIFT + 1..0 to send the window there
for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Cycle through open workspaces; SUPER + CTRL + Tab jumps back to the previous one
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad: a hidden workspace you can pop over anything
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Mouse: SUPER + left-drag moves, SUPER + right-drag resizes
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- System (SUPER + CTRL)
hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session")) -- hypridle runs hyprlock
hl.bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("~/.config/theme/apply --pick")) -- colour theme picker
hl.bind(mod .. " + CTRL + A", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.mixer wiremix")) -- audio mixer
hl.bind(mod .. " + CTRL + B", hl.dsp.exec_cmd(scripts .. "toggle-popup.sh popup.bluetooth bluetui"))
hl.bind(mod .. " + CTRL + P", hl.dsp.exec_cmd(scripts .. "power-profile.sh")) -- cycle power profile
hl.bind(mod .. " + CTRL + I", hl.dsp.exec_cmd(scripts .. "idle-inhibit.sh toggle")) -- stay awake on/off

-- Session
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(scripts .. "power-menu.sh"))
hl.bind(mod .. " + SHIFT + Escape", hl.dsp.exec_cmd("uwsm stop")) -- log out cleanly

-- Screenshots: saved to ~/Pictures/Screenshots and copied; click the notification to annotate
local screenshot = scripts .. "screenshot.sh"
hl.bind("Print", hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(screenshot .. " screen"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd(screenshot .. " window"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(screenshot .. " region --edit")) -- straight into satty

-- Volume, brightness and media keys (work on the lock screen too)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Notifications (Mako)
hl.bind(mod .. " + N", hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"))
hl.bind(mod .. " + ALT + N", hl.dsp.exec_cmd("makoctl restore"))
hl.bind(mod .. " + CTRL + N", hl.dsp.exec_cmd("makoctl mode -t do-not-disturb ; pkill -RTMIN+8 waybar"))
