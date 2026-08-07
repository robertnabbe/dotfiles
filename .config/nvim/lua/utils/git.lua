local M = {}

function M.root()
  local result = vim.fn.systemlist("git rev-parse --show-toplevel")
  return result[1]
end

return M
