-- lua/core/keymaps.lua
local keymap = vim.keymap.set

-- 1. Keymaps genéricos
keymap("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })

-- 2. Keymaps de plugins que no requieran configuración importante
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toogles NvimTree" })
keymap("n", "<Leader>ff", ":Telescope find_files<CR>", { desc = "Opens file search with telescope" })

-- 3. Keymaps del LSP (nativos de Neovim)
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Ir a la definición" })

-- 4. Keymaps de plugins complejos (con carga diferida)
local function setup_plugin_keymaps()
  -- La idea de cargarlo así es la siguiente, si el plugin es complejo o requiere más control que simplemente dar un comando 
  -- como es el caso en :NvimTreeToggle y infimo más rendimiento entonces es mejor usar la carga con la API.
  -- Aunque es verdad que es el estandar actual de neovim

  -- Telescope
  --local telescope_builtin = require("telescope.builtin")
  --keymap("n", "<Leader>ff", telescope_builtin.find_files, {})
  --keymap("n", "<Leader>fg", telescope_builtin.live_grep, {})
end



-- Cargar después de que todo esté listo
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = setup_plugin_keymaps,
})
