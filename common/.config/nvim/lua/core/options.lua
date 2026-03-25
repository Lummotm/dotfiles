-- Neovim Core Configuration

-- Visual Settings
vim.opt.number = false -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers for easier navigation
vim.opt.cursorline = false -- Do not highlight the current line
vim.opt.termguicolors = true -- Enable 24-bit RGB color support
vim.opt.showmode = false -- Disable "-- INSERT --" message (handled by statusline)
vim.opt.wrap = true -- Wrap long lines that exceed the screen width
vim.opt.conceallevel = 1 -- Conceal parts of text based on 'conceal' syntax

-- Whitespace & Indentation
vim.opt.tabstop = 4 -- Number of spaces a Tab character represents
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indentation
vim.opt.softtabstop = 4 -- Number of spaces inserted when pressing Tab
vim.opt.expandtab = true -- Convert Tab characters to spaces
vim.opt.breakindent = true -- Maintain indent of wrapped lines

-- Behavior & Performance
vim.opt.undofile = true -- Enable persistent undo history
vim.opt.confirm = true -- Prompt for confirmation before quitting with unsaved changes
vim.opt.updatetime = 200 -- Faster update frequency (useful for plugins like LSP)
vim.opt.timeoutlen = 500 -- Time in milliseconds for key sequence timeout

-- UI Elements
vim.opt.signcolumn = "yes" -- Always show the sign column (for LSP, Git, etc.)
vim.opt.listchars = { -- Define characters for whitespace and special characters
	tab = "» ", -- Character for Tab
	trail = "·", -- Character for trailing whitespace
	nbsp = "␣", -- Character for non-breaking space
}

-- Input & Navigation
vim.g.mapleader = " " -- Set the global leader key to Space
vim.g.maplocalleader = " " -- Set the local leader key (buffer-specific) to Space
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.path:append("**") -- Allow Neovim to search recursively in the current directory via find

vim.opt.spelllang = { "es", "en_us" } -- Set preferred spell check languages

-- Clipboard
-- This doesnt work as I want to the clipboard just gets full of junk
-- vim.opt.clipboard = "unnamedplus"
