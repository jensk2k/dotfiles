---------------------
---- KEYBINDINGS ----
---------------------

local terminal = "kitty"
local launcher = "hyprlauncher"

local mod = "SUPER"

-- Apps
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("brave"))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(terminal .. " yazi"))

-- Clipboard history picker
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | hyprlauncher --dmenu | cliphist decode | wl-copy"))

-- Window management
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit")) -- flip horizontal/vertical split
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + O", hl.dsp.window.pin()) -- keep a floating window on all workspaces

-- Groups (tabbed windows)
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + ALT + Tab", hl.dsp.group.next())

-- Move focus
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Swap windows
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Resize the active window (hold to keep resizing)
local step = 40
hl.bind(mod .. " + ALT + left", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + ALT + right", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
hl.bind(mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true })

-- Workspaces: SUPER + 1..0 to switch, SUPER + SHIFT + 1..0 to send the window there
for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Cycle through open workspaces
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad: a hidden workspace you can pop over anything
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Mouse: SUPER + left-drag moves, SUPER + right-drag resizes
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Session
hl.bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session")) -- hypridle runs hyprlock
hl.bind(mod .. " + SHIFT + Escape", hl.dsp.exec_cmd("uwsm stop")) -- log out cleanly

-- Screenshots (copied to clipboard)
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy')) -- select a region
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy")) -- whole screen

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
hl.bind(mod .. " + CTRL + N", hl.dsp.exec_cmd("makoctl restore"))
hl.bind(mod .. " + ALT + N", hl.dsp.exec_cmd("makoctl mode -t do-not-disturb ; pkill -RTMIN+8 waybar"))
