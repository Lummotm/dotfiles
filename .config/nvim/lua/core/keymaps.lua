local keymap = vim.keymap.set

keymap({ "n" }, "<C-s>", ":w<CR>", { desc = "Save file" })
keymap({ "n" }, "<C-q>", ":q<CR>", { desc = "Exist File" }) -- no need for save and exit due to confirmation when exit
vim.api.nvim_set_keymap('n', '<C-A>', 'ggvg0G', { noremap = true, silent = true })

keymap("n", "<C-n>", ":Neotree toggle left<CR>")

keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Search Files" })
keymap("n", "<leader>fh", "<cmd>Telescope oldfiles<CR>", { desc = "Search Recent Files" })
keymap("n", "<leader>fr", "<cmd>Telescope frecency<CR>", { desc = "Search by recency" })

keymap("n", "<leader>ll", ":VimtexCompile<CR>", { desc = "Compile with latexmk", noremap = true, silent = true })
keymap("n", "<leader>lc", ":VimtexClean<CR>", { desc = "Clean complation files" })

local function setup_plugin_keymaps()
	keymap("n", "K", vim.lsp.buf.hover, { desc = "View Lsp Documentation" })
	keymap("n", "gd", vim.lsp.buf.definition, { desc = "View Lsp Definition" })
	keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

	keymap("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format code" })
end

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = setup_plugin_keymaps,
})
