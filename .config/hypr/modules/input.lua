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
