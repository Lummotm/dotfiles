return {
	"mikavilpas/yazi.nvim",
	cmd = "Yazi",
	keys = {
		{ "<leader>ee", "<cmd>Yazi<CR>", desc = "Yazi: Current File" },
		{ "<leader>ew", "<cmd>Yazi cwd<CR>", desc = "Yazi: Current Directory" },
	},
	opts = {
		open_for_directories = true,
	},
	init = function()
		vim.g.loaded_netrwPlugin = 1
	end,
}
