-- ~/.config/theme/schemes.lua
-- The colour schemes on offer: only the big families, each used through its
-- own official ports (kitty theme, Neovim plugin, btop/bat/fzf themes), never
-- generated. A scheme without wide adoption doesn't belong here.
--
--   name    shown in the picker, stored as `theme` in palette.lua
--   kitty   the scheme's kitty theme (`kitten themes` name)
--   nvim    { repo, name = lazy.nvim plugin name, colorscheme, background? }
--           background is for schemes that switch variant with 'background'
--   btop    a built-in btop theme name, or { url } of a port to fetch
--   bat     a built-in bat theme name, or { url } of a .tmTheme to fetch
--   fzf     { url } of a port whose --color options are used
--   palette { url, map } the family's official named colours (its Waybar port);
--           map gives each of our 8 UI slots a colour name. Colours our own UI
--           (Waybar, Hyprland borders, hyprlock, SDDM); without it the slots
--           are derived from the kitty colours
--   mako, fuzzel  { url } of the family's colour config for that app, used as-is
-- A missing btop/bat/fzf entry means the app uses the terminal's colours
-- (which come from the scheme's kitty port); missing mako/fuzzel means our own
-- colour choices from the 8 slots. Fetched files are downloaded by
-- ./fetch-ports into ~/.local/share/theme-ports (bat: ~/.config/bat/themes).

-- Port repositories, pinned to a commit; bump a pin and re-run ./fetch-ports to update
local function gh(repo, commit)
	return function(path)
		return { url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(repo, commit, path) }
	end
end
local catppuccin_btop = gh("catppuccin/btop", "f437574b600f1c6d932627050b15ff5153b58fa3")
local catppuccin_fzf = gh("catppuccin/fzf", "7508f8141286fb95249100a2b5325960320dcf32")
local tokyonight = gh("folke/tokyonight.nvim", "cdc07ac78467a233fd62c493de29a17e0cf2b2b6")
local rosepine_btop = gh("rose-pine/btop", "c27e5d48e44e8bd115a2838ecf8cf1f3ea39475e")
local rosepine_tm = gh("rose-pine/tm-theme", "6d556734541ccb04172e81fd58de4a35fff72d19")
local rosepine_fzf = gh("rose-pine/fzf", "9af300f871df52331c362ca58c73535f69b6fb03")
local kanagawa = gh("rebelot/kanagawa.nvim", "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3")
local dracula_fzf = gh("dracula/fzf", "f4c7758a813ca73b69e9c954c001586c33858c24")
local catppuccin_waybar = gh("catppuccin/waybar", "ee8ed32b4f63e9c417249c109818dcc05a2e25da")
local catppuccin_mako = gh("catppuccin/mako", "92844f144e72f2dc8727879ec141ffdacf3ff6a1")
local catppuccin_fuzzel = gh("catppuccin/fuzzel", "879879da8a7dc58f173b4cd7987723fd19bef6d5")
local rosepine_waybar = gh("rose-pine/waybar", "d337e99fac6e6d46170f9ad91ef0d70cf6a872d7")
local rosepine_mako = gh("rose-pine/mako", "12f7814de6a485ecc373933cc04bb2b13b23e491")
local dracula_waybar = gh("dracula/waybar", "359e71bdd3935df849801ca0d8533765e8779d8a")
local dracula_fuzzel = gh("dracula/fuzzel", "0a17de1c24b2bf7d2577424c8ee763a6867177ec")

-- Our 8 UI slots in each family's own colour names (Catppuccin's accent: mauve)
local catppuccin_map = { bg = "base", surface = "surface0", fg = "text", dim = "overlay1",
	accent = "mauve", accent2 = "green", warn = "yellow", crit = "red" }
local rosepine_map = { bg = "base", surface = "overlay", fg = "text", dim = "muted",
	accent = "iris", accent2 = "foam", warn = "gold", crit = "love" }
local dracula_map = { bg = "background", surface = "selection", fg = "foreground", dim = "comment",
	accent = "purple", accent2 = "green", warn = "yellow", crit = "red" }
local function palette(port, map)
	port.map = map
	return port
end

return {
	-- Catppuccin: catppuccin/{nvim,btop,fzf,waybar,mako,fuzzel}; bat built in
	{ name = "Catppuccin Latte", kitty = "Catppuccin-Latte",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-latte" },
		btop = catppuccin_btop("themes/catppuccin_latte.theme"), bat = "Catppuccin Latte",
		fzf = catppuccin_fzf("themes/catppuccin-fzf-latte.sh"),
		palette = palette(catppuccin_waybar("themes/latte.css"), catppuccin_map),
		mako = catppuccin_mako("themes/catppuccin-latte/catppuccin-latte-mauve"), fuzzel = catppuccin_fuzzel("themes/catppuccin-latte/mauve.ini") },
	{ name = "Catppuccin Frappé", kitty = "Catppuccin-Frappe",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-frappe" },
		btop = catppuccin_btop("themes/catppuccin_frappe.theme"), bat = "Catppuccin Frappe",
		fzf = catppuccin_fzf("themes/catppuccin-fzf-frappe.sh"),
		palette = palette(catppuccin_waybar("themes/frappe.css"), catppuccin_map),
		mako = catppuccin_mako("themes/catppuccin-frappe/catppuccin-frappe-mauve"), fuzzel = catppuccin_fuzzel("themes/catppuccin-frappe/mauve.ini") },
	{ name = "Catppuccin Macchiato", kitty = "Catppuccin-Macchiato",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-macchiato" },
		btop = catppuccin_btop("themes/catppuccin_macchiato.theme"), bat = "Catppuccin Macchiato",
		fzf = catppuccin_fzf("themes/catppuccin-fzf-macchiato.sh"),
		palette = palette(catppuccin_waybar("themes/macchiato.css"), catppuccin_map),
		mako = catppuccin_mako("themes/catppuccin-macchiato/catppuccin-macchiato-mauve"), fuzzel = catppuccin_fuzzel("themes/catppuccin-macchiato/mauve.ini") },
	{ name = "Catppuccin Mocha", kitty = "Catppuccin-Mocha",
		nvim = { "catppuccin/nvim", name = "catppuccin", colorscheme = "catppuccin-mocha" },
		btop = catppuccin_btop("themes/catppuccin_mocha.theme"), bat = "Catppuccin Mocha",
		fzf = catppuccin_fzf("themes/catppuccin-fzf-mocha.sh"),
		palette = palette(catppuccin_waybar("themes/mocha.css"), catppuccin_map),
		mako = catppuccin_mako("themes/catppuccin-mocha/catppuccin-mocha-mauve"), fuzzel = catppuccin_fuzzel("themes/catppuccin-mocha/mauve.ini") },

	-- Tokyo Night: folke/tokyonight.nvim and its extras (btop, sublime = bat, fzf, fuzzel)
	{ name = "Tokyo Night", kitty = "Tokyo Night",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-night" },
		btop = tokyonight("extras/btop/tokyonight_night.theme"), bat = tokyonight("extras/sublime/tokyonight_night.tmTheme"),
		fzf = tokyonight("extras/fzf/tokyonight_night.sh"),
		fuzzel = tokyonight("extras/fuzzel/tokyonight_night.ini") },
	{ name = "Tokyo Night Storm", kitty = "Tokyo Night Storm",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-storm" },
		btop = tokyonight("extras/btop/tokyonight_storm.theme"), bat = tokyonight("extras/sublime/tokyonight_storm.tmTheme"),
		fzf = tokyonight("extras/fzf/tokyonight_storm.sh"),
		fuzzel = tokyonight("extras/fuzzel/tokyonight_storm.ini") },
	{ name = "Tokyo Night Moon", kitty = "Tokyo Night Moon",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-moon" },
		btop = tokyonight("extras/btop/tokyonight_moon.theme"), bat = tokyonight("extras/sublime/tokyonight_moon.tmTheme"),
		fzf = tokyonight("extras/fzf/tokyonight_moon.sh"),
		fuzzel = tokyonight("extras/fuzzel/tokyonight_moon.ini") },
	{ name = "Tokyo Night Day", kitty = "Tokyo Night Day",
		nvim = { "folke/tokyonight.nvim", name = "tokyonight.nvim", colorscheme = "tokyonight-day" },
		btop = tokyonight("extras/btop/tokyonight_day.theme"), bat = tokyonight("extras/sublime/tokyonight_day.tmTheme"),
		fzf = tokyonight("extras/fzf/tokyonight_day.sh"),
		fuzzel = tokyonight("extras/fuzzel/tokyonight_day.ini") },

	-- Rosé Pine: rose-pine/{neovim,btop,tm-theme,fzf,waybar,mako}
	{ name = "Rosé Pine", kitty = "Rosé Pine",
		nvim = { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine-main" },
		btop = rosepine_btop("rose-pine.theme"), bat = rosepine_tm("dist/rose-pine.tmTheme"),
		fzf = rosepine_fzf("dist/rose-pine.sh"),
		palette = palette(rosepine_waybar("rose-pine.css"), rosepine_map), mako = rosepine_mako("theme/rose-pine.theme") },
	{ name = "Rosé Pine Moon", kitty = "Rosé Pine Moon",
		nvim = { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine-moon" },
		btop = rosepine_btop("rose-pine-moon.theme"), bat = rosepine_tm("dist/rose-pine-moon.tmTheme"),
		fzf = rosepine_fzf("dist/rose-pine-moon.sh"),
		palette = palette(rosepine_waybar("rose-pine-moon.css"), rosepine_map), mako = rosepine_mako("theme/rose-pine-moon.theme") },
	{ name = "Rosé Pine Dawn", kitty = "Rosé Pine Dawn",
		nvim = { "rose-pine/neovim", name = "rose-pine", colorscheme = "rose-pine-dawn" },
		btop = rosepine_btop("rose-pine-dawn.theme"), bat = rosepine_tm("dist/rose-pine-dawn.tmTheme"),
		fzf = rosepine_fzf("dist/rose-pine-dawn.sh"),
		palette = palette(rosepine_waybar("rose-pine-dawn.css"), rosepine_map), mako = rosepine_mako("theme/rose-pine-dawn.theme") },

	-- Kanagawa: rebelot/kanagawa.nvim (its extras have one tmTheme, for Wave); btop built in
	{ name = "Kanagawa Wave", kitty = "Kanagawa",
		nvim = { "rebelot/kanagawa.nvim", name = "kanagawa.nvim", colorscheme = "kanagawa-wave" },
		btop = "kanagawa-wave", bat = kanagawa("extras/tmTheme/kanagawa.tmTheme") },
	{ name = "Kanagawa Dragon", kitty = "Kanagawa_dragon",
		nvim = { "rebelot/kanagawa.nvim", name = "kanagawa.nvim", colorscheme = "kanagawa-dragon" },
		btop = "kanagawa-dragon" },
	{ name = "Kanagawa Lotus", kitty = "Kanagawa_light",
		nvim = { "rebelot/kanagawa.nvim", name = "kanagawa.nvim", colorscheme = "kanagawa-lotus" },
		btop = "kanagawa-lotus" },

	-- Gruvbox: ellisonleao/gruvbox.nvim (variant by background); btop and bat built in
	{ name = "Gruvbox Dark", kitty = "Gruvbox Dark",
		nvim = { "ellisonleao/gruvbox.nvim", name = "gruvbox.nvim", colorscheme = "gruvbox", background = "dark" },
		btop = "gruvbox_dark", bat = "gruvbox-dark" },
	{ name = "Gruvbox Light", kitty = "Gruvbox Light",
		nvim = { "ellisonleao/gruvbox.nvim", name = "gruvbox.nvim", colorscheme = "gruvbox", background = "light" },
		btop = "gruvbox_light", bat = "gruvbox-light" },

	-- Everforest: sainnhe/everforest (variant by background); btop built in
	{ name = "Everforest Dark", kitty = "Everforest Dark Medium",
		nvim = { "sainnhe/everforest", name = "everforest", colorscheme = "everforest", background = "dark" },
		btop = "everforest-dark-medium" },
	{ name = "Everforest Light", kitty = "Everforest Light Medium",
		nvim = { "sainnhe/everforest", name = "everforest", colorscheme = "everforest", background = "light" },
		btop = "everforest-light-medium" },

	-- Solarized: maxmx03/solarized.nvim (variant by background); btop and bat built in
	{ name = "Solarized Dark", kitty = "Solarized Dark",
		nvim = { "maxmx03/solarized.nvim", name = "solarized.nvim", colorscheme = "solarized", background = "dark" },
		btop = "solarized_dark", bat = "Solarized (dark)" },
	{ name = "Solarized Light", kitty = "Solarized Light",
		nvim = { "maxmx03/solarized.nvim", name = "solarized.nvim", colorscheme = "solarized", background = "light" },
		btop = "solarized_light", bat = "Solarized (light)" },

	-- Nord: nordtheme/vim (the official port); btop and bat built in
	{ name = "Nord", kitty = "Nord",
		nvim = { "nordtheme/vim", name = "nord-vim", colorscheme = "nord" },
		btop = "nord", bat = "Nord" },

	-- Dracula: dracula/{vim,fzf,waybar,fuzzel}; btop and bat built in
	{ name = "Dracula", kitty = "Dracula",
		nvim = { "dracula/vim", name = "dracula-vim", colorscheme = "dracula" },
		btop = "dracula", bat = "Dracula",
		fzf = dracula_fzf("INSTALL.md"),
		palette = palette(dracula_waybar("waybar/colors.css"), dracula_map), fuzzel = dracula_fuzzel("fuzzel.ini") },
}
