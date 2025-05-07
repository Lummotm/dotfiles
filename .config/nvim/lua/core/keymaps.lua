local keymap = vim.keymap.set

-- ╭──────────────────────────────────────────────────╮
-- │ Edición básica                                   │
-- ╰──────────────────────────────────────────────────╯
keymap("n", "<C-s>", ":w<CR>", { desc = "Guardar archivo" })
keymap("n", "<C-q>", ":q<CR>", { desc = "Salir (confirma si hay cambios)" })

-- ╭──────────────────────────────────────────────────╮
-- │ Autoindent y movimiento                          │
-- ╰──────────────────────────────────────────────────╯
keymap("n", "<C-A>", "ggg0vGg$", { noremap = true, silent = true, desc = "Autoidentar todo el buffer" })
keymap("n", "<leader>gi", "magg=G`a", { desc = "Autoidentar y volver al cursor" })
