-- ~/.config/theme/schemes.lua
-- The colour schemes on offer: only the big families, each used through its
-- own official ports (kitty theme, Neovim plugin, ...), never generated. A
-- scheme without wide adoption doesn't belong here.
--
--   name    shown in the picker, stored as `theme` in palette.lua
--   kitty   the scheme's kitty theme (`kitten themes` name)
--   nvim    { repo, name = lazy.nvim plugin name, colorscheme, background? }
--           background is for schemes that switch variant with 'background'
return {
	-- Catppuccin: catppuccin/nvim
	{ name = "Catppuccin Latte", kitty = "Catppuccin-Latte",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-latte" } },
	{ name = "Catppuccin Frappé", kitty = "Catppuccin-Frappe",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-frappe" } },
	{ name = "Catppuccin Macchiato", kitty = "Catppuccin-Macchiato",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-macchiato" } },
	{ name = "Catppuccin Mocha", kitty = "Catppuccin-Mocha",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-mocha" } },

	-- Tokyo Night: folke/tokyonight.nvim
	{ name = "Tokyo Night", kitty = "Tokyo Night",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-night" } },
	{ name = "Tokyo Night Storm", kitty = "Tokyo Night Storm",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-storm" } },
	{ name = "Tokyo Night Moon", kitty = "Tokyo Night Moon",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-moon" } },
	{ name = "Tokyo Night Day", kitty = "Tokyo Night Day",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-day" } },

	-- Rosé Pine: rose-pine/neovim
	{ name = "Rosé Pine", kitty = "Rosé Pine",
		nvim = { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine-main" } },
	{ name = "Rosé Pine Moon", kitty = "Rosé Pine Moon",
		nvim = { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine-moon" } },
	{ name = "Rosé Pine Dawn", kitty = "Rosé Pine Dawn",
		nvim = { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine-dawn" } },

	-- Kanagawa: rebelot/kanagawa.nvim
	{ name = "Kanagawa Wave", kitty = "Kanagawa",
		nvim = { "rebelot/kanagawa.nvim", name = "kanagawa.nvim", colorscheme = "kanagawa-wave" } },
	{ name = "Kanagawa Dragon", kitty = "Kanagawa_dragon",
		nvim = { "rebelot/kanagawa.nvim", name = "kanagawa.nvim", colorscheme = "kanagawa-dragon" } },
	{ name = "Kanagawa Lotus", kitty = "Kanagawa_light",
		nvim = { "rebelot/kanagawa.nvim", name = "kanagawa.nvim", colorscheme = "kanagawa-lotus" } },

	-- Gruvbox: ellisonleao/gruvbox.nvim (variant by background)
	{ name = "Gruvbox Dark", kitty = "Gruvbox Dark",
		nvim = { "ellisonleao/gruvbox.nvim", name = "gruvbox.nvim", colorscheme = "gruvbox", background = "dark" } },
	{ name = "Gruvbox Light", kitty = "Gruvbox Light",
		nvim = { "ellisonleao/gruvbox.nvim", name = "gruvbox.nvim", colorscheme = "gruvbox", background = "light" } },

	-- Everforest: sainnhe/everforest (variant by background)
	{ name = "Everforest Dark", kitty = "Everforest Dark Medium",
		nvim = { "sainnhe/everforest", name = "everforest", colorscheme = "everforest", background = "dark" } },
	{ name = "Everforest Light", kitty = "Everforest Light Medium",
		nvim = { "sainnhe/everforest", name = "everforest", colorscheme = "everforest", background = "light" } },

	-- Solarized: maxmx03/solarized.nvim (variant by background)
	{ name = "Solarized Dark", kitty = "Solarized Dark",
		nvim = { "maxmx03/solarized.nvim", name = "solarized.nvim", colorscheme = "solarized", background = "dark" } },
	{ name = "Solarized Light", kitty = "Solarized Light",
		nvim = { "maxmx03/solarized.nvim", name = "solarized.nvim", colorscheme = "solarized", background = "light" } },

	-- Nord: nordtheme/vim (the official port)
	{ name = "Nord", kitty = "Nord",
		nvim = { "nordtheme/vim", name = "nord-vim", colorscheme = "nord" } },

	-- Dracula: dracula/vim (the official port)
	{ name = "Dracula", kitty = "Dracula",
		nvim = { "dracula/vim", name = "dracula-vim", colorscheme = "dracula" } },
}
