return {
	"mikavilpas/yazi.nvim",
	cmd = "Yazi",
	keys = {
		{ "<leader>ee", "<cmd>Yazi<CR>", desc = "Oil: File Explorer" },
	},
	opts = {},
	init = function()
		vim.g.loaded_netrwPlugin = 1
	end,
}
