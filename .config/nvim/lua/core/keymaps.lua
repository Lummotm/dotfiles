local keymap = vim.keymap.set

-- Clean up default LSP or plugin mappings under 'g'
for _, key in ipairs({ "gD", "gr", "grr", "gra", "gri", "grn", "g%", "gx", "gO", "gy" }) do
  pcall(vim.keymap.del, "n", key)
end
pcall(vim.keymap.del, "n", "g") -- deletes direct mapping <g>

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
keymap("n", "<leader>fk", function() require("snacks").picker.keymaps() end, {desc = "Find Keymaps"} )

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
keymap("n", "<leader>nh", function() require("snacks").notifier.show_history() end, { desc = "Notification History" })

-- ╭─────────────────────────────────────────────╮
-- │ Tmux Navigation                             │
-- ╰─────────────────────────────────────────────╯
keymap("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Tmux Left" })
keymap("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Tmux Down" })
keymap("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Tmux Up" })
keymap("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Tmux Right" })
keymap("n", "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "Tmux Previous" })

-- ╭─────────────────────────────────────────────╮
-- │ VimTeX Keymaps                              │
-- ╰─────────────────────────────────────────────╯
-- Only active in .tex buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    local opts = { buffer = true, noremap = true, silent = true }

    -- Compilation and viewer
    keymap("n", "<leader>ll", "<cmd>VimtexCompile<CR>", vim.tbl_extend("force", opts, { desc = "Compile LaTeX" }))
    keymap("n", "<leader>lv", "<cmd>VimtexView<CR>",    vim.tbl_extend("force", opts, { desc = "View PDF" }))
    keymap("n", "<leader>lk", "<cmd>VimtexStop<CR>",    vim.tbl_extend("force", opts, { desc = "Stop compilation" }))
    keymap("n", "<leader>le", "<cmd>VimtexErrors<CR>",  vim.tbl_extend("force", opts, { desc = "Show errors" }))
    keymap("n", "<leader>lo", "<cmd>VimtexCompileOutput<CR>", vim.tbl_extend("force", opts, { desc = "Show output" }))

    -- Cleanup and control
    keymap("n", "<leader>lc", "<cmd>VimtexClean<CR>",   vim.tbl_extend("force", opts, { desc = "Clean aux files" }))
    keymap("n", "<leader>lC", "<cmd>VimtexClean!<CR>",  vim.tbl_extend("force", opts, { desc = "Full clean" }))
    keymap("n", "<leader>li", "<cmd>VimtexInfo<CR>",    vim.tbl_extend("force", opts, { desc = "Project info" }))
    keymap("n", "<leader>ls", "<cmd>VimtexToggleMain<CR>", vim.tbl_extend("force", opts, { desc = "Toggle main file" }))
    keymap("n", "<leader>lr", "<cmd>VimtexReverseSearch<CR>", vim.tbl_extend("force", opts, { desc = "Reverse search" }))
    keymap("n", "<leader>lx", "<cmd>VimtexReload<CR>",  vim.tbl_extend("force", opts, { desc = "Reload VimTeX" }))
    keymap("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", vim.tbl_extend("force", opts, { desc = "Table of contents" }))
  end,
})

