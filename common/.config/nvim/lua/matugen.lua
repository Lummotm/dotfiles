 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#fff8f5',
    base01 = '#fcebdf',
    base02 = '#f6e5da',
    base03 = '#877364',
    base04 = '#544436',
    base05 = '#221a13',
    base06 = '#221a13',
    base07 = '#221a13',
    base08 = '#ba1a1a',
    base09 = '#586100',
    base0A = '#7f5530',
    base0B = '#8b4c00',
    base0C = '#c2cf50',
    base0D = '#ffb779',
    base0E = '#f2bc8e',
    base0F = '#ffdcc1',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#221a13',          bg = '#fff8f5' })
  hi('TelescopeBorder',         { fg = '#877364',             bg = '#fff8f5' })
  hi('TelescopePromptNormal',   { fg = '#221a13',          bg = '#fff8f5' })
  hi('TelescopePromptBorder',   { fg = '#877364',             bg = '#fff8f5' })
  hi('TelescopePromptPrefix',   { fg = '#8b4c00',             bg = '#fff8f5' })
  hi('TelescopePromptCounter',  { fg = '#544436',  bg = '#fff8f5' })
  hi('TelescopePromptTitle',    { fg = '#fff8f5',             bg = '#8b4c00' })
  hi('TelescopePreviewTitle',   { fg = '#fff8f5',             bg = '#7f5530' })
  hi('TelescopeResultsTitle',   { fg = '#fff8f5',             bg = '#586100' })
  hi('TelescopeSelection',      { fg = '#221a13',          bg = '#f6e5da' })
  hi('TelescopeSelectionCaret', { fg = '#8b4c00',             bg = '#f6e5da' })
  hi('TelescopeMatching',       { fg = '#8b4c00',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#221a13',          bg = '#fff8f5' })
  hi('MiniPickBorder',         { fg = '#877364',             bg = '#fff8f5' })
  hi('MiniPickPrompt',   { fg = '#221a13',          bg = '#fff8f5' })
  hi('MiniPickPromptPrefix',   { fg = '#8b4c00',             bg = '#fff8f5' })
  hi('MiniPickBorderText',    { fg = '#fff8f5',             bg = '#8b4c00' })
  hi('MiniPickMatchCurrent',      { fg = '#221a13',          bg = '#f6e5da' })
  hi('MiniPickPromptCaret', { fg = '#8b4c00',             bg = '#f6e5da' })
  hi('MiniPickMatchRanges',       { fg = '#8b4c00',             bold = true })
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
