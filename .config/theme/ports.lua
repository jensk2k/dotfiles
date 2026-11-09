-- ~/.config/theme/ports.lua
-- Where fetched ports live, shared by fetch-ports (which downloads them) and
-- apply (which switches the apps to them).
local home = os.getenv("HOME")
local share = home .. "/.local/share/theme-ports"

local M = {}

-- "Rosé Pine" -> "rose-pine"
local function slug(name)
	return (name:lower():gsub("é", "e"):gsub("[^%w]+", "-"))
end

-- Every kind of fetched port, in schemes.lua's field names
M.tools = { "btop", "bat", "fzf", "palette", "mako", "fuzzel" }

-- Local file for a scheme's fetched port of `tool` (one of M.tools)
function M.path(tool, scheme)
	local url = scheme[tool].url
	if tool == "bat" then
		-- bat only reads themes from its config dir; the theme name is the file name
		return home .. "/.config/bat/themes/" .. url:match("([^/]+)$")
	end
	-- mako ports have no extension
	return ("%s/%s/%s.%s"):format(share, tool, slug(scheme.name), url:match("/[^/.]+%.(%w+)$") or "conf")
end

-- bat's name for a fetched .tmTheme (the file name without the extension)
function M.bat_name(scheme)
	return scheme.bat.url:match("([^/]+)%.tmTheme$")
end

-- The --color options from an fzf port (a shell snippet or README that sets
-- FZF_DEFAULT_OPTS), in order, without duplicates; other options are left out
-- so fzf's layout doesn't change with the theme
function M.fzf_colors(file)
	local f = io.open(file)
	if not f then
		return nil
	end
	local text = f:read("a")
	f:close()
	local seen, out = {}, {}
	for opt in text:gmatch("%-%-color=[^%s\"'\\]+") do
		if not seen[opt] then
			seen[opt], out[#out + 1] = true, opt
		end
	end
	return #out > 0 and table.concat(out, " ") or nil
end

-- A palette port's named colours, { name = "rrggbb" }: CSS "@define-color name #hex"
function M.palette_colors(file)
	local f = io.open(file)
	if not f then
		return nil
	end
	local colors = {}
	for name, hex in f:read("a"):gmatch("@define%-color%s+([%w_-]+)%s+#(%x%x%x%x%x%x)") do
		colors[name] = hex:lower()
	end
	f:close()
	return next(colors) and colors or nil
end

return M
