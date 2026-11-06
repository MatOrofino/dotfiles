---@class floating_terminal
local M = {}

M._floating_terminal = false
M.floating_terminal = Snacks.toggle({
  name = "Floating Terminal",
  get = function()
    return M._floating_terminal
  end,

  ---@param state boolean
  set = function(state)
    if state then
      M._floating_terminal = true
    else
      M._floating_terminal = false
    end
  end,
})

setmetatable(M, {
  __call = function(m, ...)
    return m.option(...)
  end,
})

return M
