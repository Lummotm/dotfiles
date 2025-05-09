local keymap = vim.keymap.set

-- ╭──────────────────────────────────────────────────╮
-- │ Edición básica                                   │
-- ╰──────────────────────────────────────────────────╯
keymap("n", "<C-s>", ":w<CR>", { desc = "Save File" })
keymap("n", "<C-q>", ":q<CR>", { desc = "Exit"})

-- ╭──────────────────────────────────────────────────╮
-- │ Autoindent y movimiento                          │
-- ╰──────────────────────────────────────────────────╯
keymap("n", "<C-A>", "ggg0vGg$", { noremap = true, silent = true, desc = "Select all text" })
keymap("n", "<leader>gi", "magg=G`a", { desc = "Autoindent" })
