local keymap = vim.keymap.set

-- Atajos generales
keymap("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })

-- Atajos para nvim-tree
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true, noremap = true })

-- Atajos LSP
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Ir a la definición" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Ver referencias" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Mostrar documentación" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Acciones de código" })

-- Puedes añadir más atajos aquí
