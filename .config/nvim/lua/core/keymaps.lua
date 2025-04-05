-- lua/core/keymaps.luak
local keymap = vim.keymap.set

-- 1. Keymaps genéricos
keymap({"n","i"}, "<C-s>", ":w<CR>", { desc = "Save file" })
keymap({"n","i"}, "<C-q>", ":q<CR>", { desc = "Exist File" }) -- no need for save and exit due to confirmation when exit

-- 2. Keymaps de plugins que no requieran configuración importante
keymap("n", "<C-n>", ":Neotree toggle left<CR>")
keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Search Files" })
keymap("n", "<leader>fh", "<cmd>Telescope oldfiles<CR>", { desc = "Search Recent Files" })
keymap("n", "<leader>fr", "<cmd>Telescope frecency<CR>", { desc = "Search by recency" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Open Live Grep" })
keymap("n", "<leader>ll", ":VimtexCompile<CR>", { noremap = true, silent = true })


-- 3. Keymaps del LSP (nativos de Neovim)

-- 4. Keymaps de plugins complejos (con carga diferida)
local function setup_plugin_keymaps()
	-- La idea de cargarlo así es la siguiente, si el plugin es complejo o requiere más control que simplemente dar un comando
	-- como es el caso en :NvimTreeToggle y infimo más rendimiento entonces es mejor usar la carga con la API.
	-- Aunque es verdad que es el estandar actual de neovim

	keymap("n", "K", vim.lsp.buf.hover, { desc = "View Lsp Documentation" })
	keymap("n", "gd", vim.lsp.buf.definition, { desc = "View Lsp Definition" })
	keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

	keymap("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format code" })
end

-- Cargar después de que todo esté listo
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = setup_plugin_keymaps,
})
