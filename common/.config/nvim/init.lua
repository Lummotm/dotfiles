-- Neovim configuration entry point

-- Enable faster module loading
vim.loader.enable()

-- Leader key: Space for all custom keybinds
vim.g.mapleader = " "

-- Lazy.nvim plugin manager setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Clipboard: Wayland integration via wl-copy/wl-paste
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

-- Mason: Add LSP/debugger binaries to PATH
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

-- Core configuration
require("core.options")
require("core.keymaps")
require("core.autocmds")

local theme = require("core.theme")
theme.setup()

-- Plugin loading via Lazy.nvim
require("lazy").setup({
	spec = {
		{ import = "plugins.lsp" },
		{ import = "plugins.navigation" },
		{ import = "plugins.ui" },
		{ import = "plugins.tools" },
	},
})

-- Mason tools: Install on first run only
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
