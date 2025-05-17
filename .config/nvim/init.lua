vim.loader.enable()
vim.g.mapleader = " "

-- clone repo first if it doesn't work
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

-- Load core first
require("core.options")
require("core.keymaps")

-- Load plugins
require("lazy").setup("plugins")
