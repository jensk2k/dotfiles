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
