 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#19120b',
    base02 = '#241c15',
    base03 = '#a28d7d',
    base04 = '#dac2b1',
    base05 = '#f0dfd4',
    base06 = '#f0dfd4',
    base07 = '#f0dfd4',
    base08 = '#ffb4ab',
    base09 = '#c2cf50',
    base0A = '#f2bc8e',
    base0B = '#ffb779',
    base0C = '#c2cf50',
    base0D = '#ffb779',
    base0E = '#f2bc8e',
    base0F = '#ffdcc1',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f0dfd4',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#a28d7d',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#f0dfd4',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#a28d7d',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#ffb779',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#dac2b1',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#ffb779' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#f2bc8e' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#c2cf50' })
  hi('TelescopeSelection',      { fg = '#f0dfd4',          bg = '#241c15' })
  hi('TelescopeSelectionCaret', { fg = '#ffb779',             bg = '#241c15' })
  hi('TelescopeMatching',       { fg = '#ffb779',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f0dfd4',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#a28d7d',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#f0dfd4',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb779',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#ffb779' })
  hi('MiniPickMatchCurrent',      { fg = '#f0dfd4',          bg = '#241c15' })
  hi('MiniPickPromptCaret', { fg = '#ffb779',             bg = '#241c15' })
  hi('MiniPickMatchRanges',       { fg = '#ffb779',             bold = true })
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
