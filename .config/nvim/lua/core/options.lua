-- ╭─────────────────────────────────────────────╮
-- │ Neovim Core Configuration                   │
-- ╰─────────────────────────────────────────────╯

-- ╭─────────────────────────────────────────────╮
-- │ Visual Settings                             │
-- ╰─────────────────────────────────────────────╯
vim.opt.number = true              -- Show absolute line numbers
vim.opt.relativenumber = true      -- Relative numbers for easier navigation
vim.opt.cursorline = false         -- Don't highlight the current line
vim.opt.termguicolors = true       -- Enable 24-bit RGB color
vim.opt.showmode = false           -- Disable "-- INSERT --" (handled by statusline)
vim.opt.wrap = false

-- ╭─────────────────────────────────────────────╮
-- │ Whitespace & Indentation                    │
-- ╰─────────────────────────────────────────────╯
vim.opt.tabstop = 2                -- Number of spaces a TAB represents
vim.opt.shiftwidth = 2             -- Spaces for auto-indentation
vim.opt.softtabstop = 2            -- Spaces inserted when pressing TAB
vim.opt.expandtab = true           -- Convert tabs to spaces
vim.opt.breakindent = true         -- Preserve indent in wrapped lines

-- ╭─────────────────────────────────────────────╮
-- │ Behavior & Performance                      │
-- ╰─────────────────────────────────────────────╯
vim.opt.undofile = true            -- Enable persistent undo
vim.opt.confirm = true             -- Confirm before quitting unsaved changes
vim.opt.updatetime = 250           -- Faster updates (useful for plugins)
vim.opt.timeoutlen = 500           -- Timeout for mapped sequence (ms)

-- ╭─────────────────────────────────────────────╮
-- │ UI Elements                                 │
-- ╰─────────────────────────────────────────────╯
vim.opt.signcolumn = "yes"         -- Always show sign column (LSP/git)
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- ╭─────────────────────────────────────────────╮
-- │ Input & Navigation                          │
-- ╰─────────────────────────────────────────────╯
vim.opt.mouse = ""                 -- Disable mouse entirely
vim.g.mapleader = " "              -- Set <leader> key to space
vim.g.maplocalleader = " "         -- Local leader (buffer-specific mappings)

