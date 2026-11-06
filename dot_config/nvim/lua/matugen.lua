 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1d1a23',
    base01 = '#302b3b',
    base02 = '#2b2636',
    base03 = '#696474',
    base04 = '#b1afb6',
    base05 = '#f2f2f3',
    base06 = '#f2f2f3',
    base07 = '#f2f2f3',
    base08 = '#fd4663',
    base09 = '#d092be',
    base0A = '#c68ed4',
    base0B = '#a086dc',
    base0C = '#d9a6ca',
    base0D = '#b3a1de',
    base0E = '#d0a3dc',
    base0F = '#e3c8ea',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f2f2f3',          bg = '#1d1a23' })
  hi('TelescopeBorder',         { fg = '#696474',             bg = '#1d1a23' })
  hi('TelescopePromptNormal',   { fg = '#f2f2f3',          bg = '#1d1a23' })
  hi('TelescopePromptBorder',   { fg = '#696474',             bg = '#1d1a23' })
  hi('TelescopePromptPrefix',   { fg = '#a086dc',             bg = '#1d1a23' })
  hi('TelescopePromptCounter',  { fg = '#b1afb6',  bg = '#1d1a23' })
  hi('TelescopePromptTitle',    { fg = '#1d1a23',             bg = '#a086dc' })
  hi('TelescopePreviewTitle',   { fg = '#1d1a23',             bg = '#c68ed4' })
  hi('TelescopeResultsTitle',   { fg = '#1d1a23',             bg = '#d092be' })
  hi('TelescopeSelection',      { fg = '#f2f2f3',          bg = '#2b2636' })
  hi('TelescopeSelectionCaret', { fg = '#a086dc',             bg = '#2b2636' })
  hi('TelescopeMatching',       { fg = '#a086dc',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f2f2f3',          bg = '#1d1a23' })
  hi('MiniPickBorder',         { fg = '#696474',             bg = '#1d1a23' })
  hi('MiniPickPrompt',   { fg = '#f2f2f3',          bg = '#1d1a23' })
  hi('MiniPickPromptPrefix',   { fg = '#a086dc',             bg = '#1d1a23' })
  hi('MiniPickBorderText',    { fg = '#1d1a23',             bg = '#a086dc' })
  hi('MiniPickMatchCurrent',      { fg = '#f2f2f3',          bg = '#2b2636' })
  hi('MiniPickPromptCaret', { fg = '#a086dc',             bg = '#2b2636' })
  hi('MiniPickMatchRanges',       { fg = '#a086dc',             bold = true })
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
