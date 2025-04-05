--[[
  NEOVIM CORE CONFIGURATION
  Minimalist yet powerful setup with thoughtful defaults
--]]

--------------------------------------------------------------------------------
-- Visual Settings
--------------------------------------------------------------------------------
-- Line Numbers & Appearance
vim.opt.number = true -- Show absolute line numbers
vim.opt.relativenumber = true -- Relative numbers for easier navigation
vim.opt.cursorline = true -- Highlight current line
vim.opt.termguicolors = true -- Enable 24-bit RGB color support
vim.opt.showmode = false -- Hide mode (covered by statusline)

-- Whitespace & Indentation
vim.opt.tabstop = 2 -- Number of spaces a TAB represents
vim.opt.shiftwidth = 2 -- Spaces for auto-indentation
vim.opt.softtabstop = 2 -- Spaces inserted when pressing TAB
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.breakindent = true -- Maintain indentation on wrapped lines

--------------------------------------------------------------------------------
-- Behavior & Performance
--------------------------------------------------------------------------------
-- File Handling
vim.opt.undofile = true -- Persistent undo history
vim.opt.confirm = true -- Confirm before unsaved changes

-- Timing & Responsiveness
vim.opt.updatetime = 250 -- Faster updates (for plugins)
vim.opt.timeoutlen = 500 -- Timeout for key sequences

-- UI Elements
vim.opt.signcolumn = "yes" -- Always show sign column (for LSP/git)
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

--------------------------------------------------------------------------------
-- Input & Navigation
--------------------------------------------------------------------------------
-- Mouse & Keybindings
vim.opt.mouse = "" -- Disable mouse completely
vim.g.mapleader = " " -- Set space as leader key
vim.g.maplocalleader = " " -- Local leader for buffer-specific mappings

-- Clipboard Integration
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus" -- System clipboard integration
end)

--[[
  Note: Additional plugin configurations should be added
  in their respective files under lua/plugins/
--]]
