local M = {}

-- Overrides que deben sobrevivir a cada recarga de paleta
function M.apply_overrides()
  local set = vim.api.nvim_set_hl
  local c = require("base16-colorscheme").colors

  for _, g in ipairs({
    "NormalFloat", "FloatBorder", "SignColumn", "Pmenu",
  }) do
    set(0, g, { bg = "NONE" })
  end

  set(0, "MatchParen", { fg = c.base0D, bg = "NONE", underline = true })
  set(0, "Visual", { bg = c.base02 })
end

function M.setup()
  local b16 = require("base16-colorscheme")
  local orig = b16.setup
  b16.setup = function(...)
    orig(...)
    M.apply_overrides()
    vim.api.nvim_exec_autocmds("User", { pattern = "ThemeReload", modeline = false })
  end

  vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("ThemeBackground", { clear = true }),
    pattern = "background",
    callback = function()
      vim.schedule(function()
        require("matugen").setup()
      end)
    end,
  })

  require("matugen").setup()
end

return M
