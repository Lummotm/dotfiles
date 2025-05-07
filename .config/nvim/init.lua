
-- ~/.config/nvim/init.lua
vim.g.mapleader = " "

-- recuerda clonar el repo si no tira
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Cargar configuraciones base PRIMERO
require("core.options")
require("core.keymaps")

-- Cargar plugins
require("lazy").setup("plugins")

-- Cargar tema (ahora en core/theme.lua)
require("core.theme").setup()

vim.schedule(function()
  vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
  vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
  vim.api.nvim_set_hl(0, "Visual", { bg = "#414868", fg = "#ffffff" })
end)
