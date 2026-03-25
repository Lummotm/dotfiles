-- Enable Vim's built-in module loader
vim.loader.enable()

-- Set the leader key to Space
vim.g.mapleader = " "

-- Define the path for the lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Clone lazy.nvim if it's not already installed
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none", -- Optimize cloning
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- Use the stable branch
		lazypath,
	})
end

-- Add lazy.nvim to Vim's runtime path
vim.opt.rtp:prepend(lazypath)

-- Configure clipboard for Wayland if 'wl-copy' is available
if vim.fn.has("unix") == 1 and vim.fn.executable("wl-copy") == 1 then
	vim.g.clipboard = {
		name = "wl-clipboard",
		copy = {
			["+"] = "wl-copy --foreground --type text/plain",
			["*"] = "wl-copy --foreground --primary --type text/plain",
		},
		paste = {
			["+"] = "wl-paste --no-newline",
			["*"] = "wl-paste --no-newline --primary",
		},
		cache_enabled = true,
	}
end

-- Add Mason's bin directory to the PATH
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

-- Load core Neovim options and keymaps
require("core.options")
require("core.keymaps")

local theme = require("core.theme")
theme.setup()

-- Load and setup plugins via Lazy.nvim
require("lazy").setup("plugins")

-- Load mason-tools on the first time only
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local config_dir = vim.fn.stdpath("config")
		local flag_file = config_dir .. "/.mason_tools_installed"

		if vim.fn.filereadable(flag_file) == 0 then
			vim.cmd("MasonToolsUpdateSync")
			vim.fn.writefile({}, flag_file)
		end
	end,
})
