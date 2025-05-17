return {
	"rose-pine/neovim",
	name = "rose-pine",
	event = "UIEnter",
	priority = 1000,
	config = function()
		require("rose-pine").setup({
			variant = "auto",
			dark_variant = "moon",
			dim_inactive_windows = false,
			extend_background_behind_borders = false,
			enable = {
				terminal = true,
				legacy_highlights = false,
				migrations = true,
			},
			styles = {
				bold = true,
				italic = true,
				transparency = true,
			},
		})

		vim.cmd("colorscheme rose-pine")
		require("core.theme").setup()
	end,
}
