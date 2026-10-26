-- Yazi integration: Terminal file picker
return {
	"mikavilpas/yazi.nvim",
	cmd = "Yazi",
	keys = { { "<leader>ee", "<cmd>Yazi<CR>", desc = "File Explorer" } },
	init = function()
		vim.g.loaded_netrwPlugin = 1
	end,
}
