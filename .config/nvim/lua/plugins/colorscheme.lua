-- Colorschemes for the desktop theme (~/.config/theme): each scheme's official
-- Neovim plugin, lazy-loaded, from ~/.config/theme/schemes.lua. The active one
-- comes from generated/nvim.lua, which ~/.config/theme/apply writes; open
-- Neovims switch as soon as that file changes.
local dir = vim.fn.expand("~/.config/theme")

local function current()
	local ok, t = pcall(dofile, dir .. "/generated/nvim.lua")
	return ok and type(t) == "table" and t or { colorscheme = "tokyonight", background = "dark" }
end

local specs, seen = {}, {}
for _, scheme in ipairs(dofile(dir .. "/schemes.lua")) do
	local repo = scheme.nvim[1]
	if not seen[repo] then
		seen[repo] = true
		specs[#specs + 1] = { repo, name = scheme.nvim.name, lazy = true, priority = 1000 }
	end
end

specs[#specs + 1] = {
	"LazyVim/LazyVim",
	opts = function(_, opts)
		local t = current()
		vim.o.background = t.background
		opts.colorscheme = t.colorscheme

		-- Follow theme switches while Neovim is open. Watches the folder, not the
		-- file, so it also works when nvim.lua doesn't exist yet at startup.
		local watcher = vim.uv.new_fs_event()
		if watcher then
			watcher:start(dir .. "/generated", {}, vim.schedule_wrap(function(err, file)
				if err or file ~= "nvim.lua" then
					return
				end
				local new = current()
				if new.colorscheme ~= vim.g.colors_name or new.background ~= vim.o.background then
					vim.o.background = new.background
					pcall(vim.cmd.colorscheme, new.colorscheme)
				end
			end))
		end
	end,
}

return specs
