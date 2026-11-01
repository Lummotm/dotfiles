 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#111418',
    base02 = '#1c1e23',
    base03 = '#8e9099',
    base04 = '#c4c6cf',
    base05 = '#e2e2e9',
    base06 = '#e2e2e9',
    base07 = '#e2e2e9',
    base08 = '#ffb4ab',
    base09 = '#dcbce1',
    base0A = '#bdc7dc',
    base0B = '#a9c7ff',
    base0C = '#dcbce1',
    base0D = '#a9c7ff',
    base0E = '#bdc7dc',
    base0F = '#d9e3f9',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e2e2e9',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#8e9099',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#e2e2e9',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#8e9099',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#a9c7ff',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#c4c6cf',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#a9c7ff' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#bdc7dc' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#dcbce1' })
  hi('TelescopeSelection',      { fg = '#e2e2e9',          bg = '#1c1e23' })
  hi('TelescopeSelectionCaret', { fg = '#a9c7ff',             bg = '#1c1e23' })
  hi('TelescopeMatching',       { fg = '#a9c7ff',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e2e2e9',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#8e9099',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#e2e2e9',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#a9c7ff',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#a9c7ff' })
  hi('MiniPickMatchCurrent',      { fg = '#e2e2e9',          bg = '#1c1e23' })
  hi('MiniPickPromptCaret', { fg = '#a9c7ff',             bg = '#1c1e23' })
  hi('MiniPickMatchRanges',       { fg = '#a9c7ff',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
