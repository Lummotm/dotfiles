
local M = {}

function M.setup()
  vim.cmd("colorscheme lushwal")

  vim.schedule(function()
    vim.api.nvim_set_hl(0, "TelescopeNormal",       { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeBorder",       { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyFloat",         { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat",           { bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLine",            { bg = "none" })
    vim.api.nvim_set_hl(0, "Visual",                { bg = "#414868", fg = "#ffffff" })
  end)
end

return M

