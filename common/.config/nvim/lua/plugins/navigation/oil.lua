return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	keys = {
		{ "<leader>ef", "<cmd>Oil<CR>", desc = "Oil: File Explorer" },
	},
	config = function()
		require("oil").setup({
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				natural_order = "fast",
			},
		})
	end,
}
