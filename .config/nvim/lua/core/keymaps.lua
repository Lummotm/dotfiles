local keymap = vim.keymap.set

-- Clean up default LSP or plugin mappings under 'g'
for _, key in ipairs({ "gD", "gr", "grr", "gra", "gri", "grn", "g%", "gx", "gO", "gy" }) do
  pcall(vim.keymap.del, "n", key)
end
pcall(vim.keymap.del, "n", "g") -- deletes direct mapping <g>


-- ╭─────────────────────────────────────────────╮
-- │ Basic Editing                               │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<C-s>", ":w<CR>", { desc = "Save File" })
keymap("n", "<C-q>", ":q<CR>", { desc = "Exit" })
keymap("n", "<C-A>", "ggg0VGg$", { desc = "Select All Text" })
-- Restore native macro recording on 'q'
vim.keymap.set("n", "q", "q", { noremap = true, silent = true })

-- ╭─────────────────────────────────────────────╮
-- │ Clipboard Integration                       │
-- ╰─────────────────────────────────────────────╯
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus" -- Use system clipboard

  -- Use black hole register for 'd' (delete doesn't copy)
  vim.keymap.set("n", "d", '"_d', { noremap = true, desc = "Delete without yanking" })
  vim.keymap.set("v", "d", '"_d', { noremap = true, desc = "Delete without yanking" })
end)

-- ╭─────────────────────────────────────────────╮
-- │ Style / Formatting                          │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<leader>si", "magg=G`a", { desc = "Autoindent Entire File" })
keymap("n", "<leader>sf", vim.lsp.buf.format, { desc = "Format with LSP" })

-- ╭─────────────────────────────────────────────╮
-- │ Code (LSP)                                  │
-- ╰─────────────────────────────────────────────╯
keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })

-- ╭─────────────────────────────────────────────╮
-- │ Git (Snacks)                                │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "Open LazyGit" })

-- ╭─────────────────────────────────────────────╮
-- │ File Explorers                              │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<leader>ee", "<cmd>Yazi<CR>", { desc = "Yazi: Current File" })
keymap("n", "<leader>ew", "<cmd>Yazi cwd<CR>", { desc = "Yazi: Current Directory" })
keymap("n", "<leader>ef", function() require("snacks").explorer() end, { desc = "Snacks: File Explorer" })

-- ╭─────────────────────────────────────────────╮
-- │ Pickers (Snacks)                            │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<leader>fb", function() require("snacks").picker.buffers() end, { desc = "Buffer List" })
keymap("n", "<leader>fc", function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
keymap("n", "<leader>ff", function() require("snacks").picker.files() end, { desc = "Find Files" })
keymap("n", "<leader>fp", function() require("snacks").picker.projects() end, { desc = "Projects" })
keymap("n", "<leader>fr", function() require("snacks").picker.recent() end, { desc = "Recent Files" })
keymap("n", "<leader>fg", function() require("snacks").picker.grep() end, { desc = "Grep Text" })

-- ╭─────────────────────────────────────────────╮
-- │ LSP Navigation (Snacks)                     │
-- ╰─────────────────────────────────────────────╯
keymap("n", "gd", function() require("snacks").picker.lsp_definitions() end, { desc = "Go to Definition" })
keymap("n", "gD", function() require("snacks").picker.lsp_declarations() end, { desc = "Go to Declaration" })
keymap("n", "gr", function() require("snacks").picker.lsp_references() end, { nowait = true, desc = "References" })
keymap("n", "gI", function() require("snacks").picker.lsp_implementations() end, { desc = "Go to Implementation" })
keymap("n", "gy", function() require("snacks").picker.lsp_type_definitions() end, { desc = "Go to T[y]pe Definition" })

-- ╭─────────────────────────────────────────────╮
-- │ Notifications                               │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<leader>n", function() require("snacks").notifier.show_history() end, { desc = "Notification History" })

-- ╭─────────────────────────────────────────────╮
-- │ Tmux Navigation                             │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Tmux Left" })
keymap("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Tmux Down" })
keymap("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Tmux Up" })
keymap("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Tmux Right" })
keymap("n", "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "Tmux Previous" })

