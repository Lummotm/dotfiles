 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#1f0f0d',
    base02 = '#2a1917',
    base03 = '#ad8884',
    base04 = '#e6bdb8',
    base05 = '#fcdbd7',
    base06 = '#fcdbd7',
    base07 = '#fcdbd7',
    base08 = '#ffb4ab',
    base09 = '#feb967',
    base0A = '#ffb4aa',
    base0B = '#ffb4aa',
    base0C = '#feb967',
    base0D = '#ffb4aa',
    base0E = '#ffb4aa',
    base0F = '#ffdad5',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#fcdbd7',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#ad8884',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#fcdbd7',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#ad8884',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#ffb4aa',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#e6bdb8',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#ffb4aa' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#ffb4aa' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#feb967' })
  hi('TelescopeSelection',      { fg = '#fcdbd7',          bg = '#2a1917' })
  hi('TelescopeSelectionCaret', { fg = '#ffb4aa',             bg = '#2a1917' })
  hi('TelescopeMatching',       { fg = '#ffb4aa',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#fcdbd7',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#ad8884',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#fcdbd7',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb4aa',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#ffb4aa' })
  hi('MiniPickMatchCurrent',      { fg = '#fcdbd7',          bg = '#2a1917' })
  hi('MiniPickPromptCaret', { fg = '#ffb4aa',             bg = '#2a1917' })
  hi('MiniPickMatchRanges',       { fg = '#ffb4aa',             bold = true })
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
