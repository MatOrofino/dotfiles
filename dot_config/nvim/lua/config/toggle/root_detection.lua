---@class root_detection
local M = {}

M.root_detection = Snacks.toggle({
  name = "Root Detection",
  get = function()
    return #vim.g.root_spec > 1
  end,

  ---@param state boolean
  set = function(state)
    if state then
      vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
    else
      vim.g.root_spec = { "cwd" }
      vim.cmd("cd %:p:h")
    end
  end,
})

setmetatable(M, {
  __call = function(m, ...)
    return m.option(...)
  end,
})

return M
