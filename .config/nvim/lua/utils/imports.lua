local M = {}

local aliases = {
}

local reverse_aliases = {}
for from, to in pairs(aliases) do
  reverse_aliases[to] = from
end

function M.canonicalize()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local replacements = filename:match("%.spec%.[jt]sx?$") and reverse_aliases or aliases

  local changed = 0

  for i, line in ipairs(lines) do
    local original = line

    for from, to in pairs(replacements) do
      line = line:gsub(from, to)
    end

    if line ~= original then
      lines[i] = line
      changed = changed + 1
    end
  end

  if changed > 0 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local direction = replacements == aliases and "canonicalized" or "expanded"
  vim.notify(("%s %d import alias%s"):format(direction, changed, changed == 1 and "" or "es"), vim.log.levels.INFO)
end

return M
