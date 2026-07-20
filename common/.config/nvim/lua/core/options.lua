-- Neovim core options: Essential settings for editing experience

-- Disable mouse for keyboard-only workflow
vim.opt.mouse = ""

-- Line numbers: Relative numbering for navigation, absolute disabled
vim.opt.number = false
vim.opt.relativenumber = true

-- Cursor: No highlight line (handled by colorscheme)
vim.opt.cursorline = false

-- Colors: True color support for modern terminals
vim.opt.termguicolors = true

-- Showmode: Hidden since statusline handles mode display
vim.opt.showmode = false

-- Text wrapping: Wrap lines at screen edge
vim.opt.wrap = true

-- Conceal: Hide syntax elements (e.g., markdown links)
vim.opt.conceallevel = 1

-- Indentation: 4 spaces per tab, expand tabs to spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Wrap indent: Maintain indent level on wrapped lines
vim.opt.breakindent = true

-- Persistent undo: Undo history survives across sessions
vim.opt.undofile = true

-- Confirm quit: Prompt before quitting with unsaved changes
vim.opt.confirm = true

-- Updates: Faster response for LSP and plugins
vim.opt.updatetime = 200

-- Timeout: Key sequence timeout (keymaps, abbreviations)
vim.opt.timeoutlen = 500

-- Sign column: Always show for LSP, git, and other plugins
vim.opt.signcolumn = "yes"

-- Whitespace: Visual indicators for tabs, trailing spaces, nbsp
vim.opt.listchars = {
	tab = "» ",
	trail = "·",
	nbsp = "␣",
}

-- Leader: Space as prefix for all custom keybinds
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Search: Case insensitive by default
vim.opt.ignorecase = true

-- Path: Recursive search for gf and other commands
vim.opt.path:append("**")

-- Spell: Spanish and English dictionaries
vim.opt.spelllang = { "es", "en_us" }

-- Autoread: Reload files changed outside Neovim
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	command = "if mode() != 'c' | checktime | endif",
	pattern = { "*" },
})
