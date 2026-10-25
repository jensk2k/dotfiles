-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("uwsm app -- mako")
	hl.exec_cmd("uwsm app -- hyprpaper")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- hyprsunset")
	hl.exec_cmd("uwsm app -- nm-applet")
	--hl.exec_cmd("uwsm app -- blueman-applet")
	hl.exec_cmd("uwsm app -- signal")
	-- Clipboard history: store everything copied (text and images)
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
end)
-- The password prompt agent is better run as a systemd user service:
--   systemctl --user enable --now hyprpolkitagent.service
