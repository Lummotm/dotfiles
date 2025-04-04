-- lua/core/keymaps.luak
local keymap = vim.keymap.set

-- 1. Keymaps genéricos
keymap("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })

-- 2. Keymaps de plugins que no requieran configuración importante
keymap("n", "<Leader>ff", ":Telescope find_files<CR>", { desc = "Opens file search with telescope" })
keymap("n", "<C-n>", ":Neotree toggle left<CR>")


-- 3. Keymaps del LSP (nativos de Neovim)

-- 4. Keymaps de plugins complejos (con carga diferida)
local function setup_plugin_keymaps()
  -- La idea de cargarlo así es la siguiente, si el plugin es complejo o requiere más control que simplemente dar un comando 
  -- como es el caso en :NvimTreeToggle y infimo más rendimiento entonces es mejor usar la carga con la API.
  -- Aunque es verdad que es el estandar actual de neovim

  local lspconfig = require("lspconfig")
  keymap("n", "K", vim.lsp.buf.hover, {})
  keymap("n", "gd", vim.lsp.buf.definition, {})
  keymap({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
end



-- Cargar después de que todo esté listo
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = setup_plugin_keymaps,
})
