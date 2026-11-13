 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#0c120f',
    base02 = '#151d19',
    base03 = '#646e67',
    base04 = '#9da49a',
    base05 = '#d3cdc3',
    base06 = '#d3cdc3',
    base07 = '#d3cdc3',
    base08 = '#c27979',
    base09 = '#7f9193',
    base0A = '#cb9b7c',
    base0B = '#8da383',
    base0C = '#96e0e9',
    base0D = '#b0e996',
    base0E = '#e9b696',
    base0F = '#f4d3be',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#d3cdc3',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#646e67',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#d3cdc3',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#646e67',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#8da383',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#9da49a',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#8da383' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#cb9b7c' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#7f9193' })
  hi('TelescopeSelection',      { fg = '#d3cdc3',          bg = '#151d19' })
  hi('TelescopeSelectionCaret', { fg = '#8da383',             bg = '#151d19' })
  hi('TelescopeMatching',       { fg = '#8da383',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#d3cdc3',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#646e67',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#d3cdc3',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#8da383',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#8da383' })
  hi('MiniPickMatchCurrent',      { fg = '#d3cdc3',          bg = '#151d19' })
  hi('MiniPickPromptCaret', { fg = '#8da383',             bg = '#151d19' })
  hi('MiniPickMatchRanges',       { fg = '#8da383',             bold = true })
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
