-- Instalar Lazy.nvim si no está presente
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

-- Cargar configuraciones base PRIMERO
require("core.options")  -- Importante: sin "lua/" en la ruta
require("core.keymaps")

-- Cargar plugins
require("lazy").setup("plugins")  -- Carga lua/plugins/init.lua
