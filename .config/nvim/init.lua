-- ~/.config/nvim/init.lua
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("🔄 Instalando Lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",  
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

local status, _ = pcall(require, "lazy")
if not status then
  print("❌ Error cargando Lazy:", _)
  return
end

-- Cargar configuraciones base PRIMERO
require("core.options")
require("core.keymaps")

-- Cargar plugins
require("lazy").setup("plugins")
