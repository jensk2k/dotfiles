------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "1.0",
})

-- Per-output layout from nwg-displays; overrides the catch-all above.
-- monitors.lua and workspaces.lua are per machine (untracked: each machine
-- runs nwg-displays once); without them the catch-all is used.
local dir = os.getenv("HOME") .. "/.config/hypr/"
for _, name in ipairs({ "monitors", "workspaces" }) do
	local f = io.open(dir .. name .. ".lua")
	if f then
		f:close()
		require(name)
	end
end
