---@class scratch_ft
local M = {}

M = Snacks.toggle({
  name = "Use buf ft as scratchbuf ft",
  get = function()
    return M._scratch_ft
  end,

  ---@param state boolean
  set = function(state)
    if state then
      M._scratch_ft = true
    else
      M._scratch_ft = false
    end
  end,
})
M._scratch_ft = false

return M
