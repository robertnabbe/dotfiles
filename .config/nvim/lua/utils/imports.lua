local M = {}

local has_cup_paths = vim.api.nvim_get_runtime_file("lua/utils/imports_cup.lua", false)[1] ~= nil
local aliases = has_cup_paths and require("utils.imports_cup") or {}

if vim.tbl_isempty(aliases) then
  M.canonicalize = function() end
  return M
end

local reverse_aliases = {}
for from, to in pairs(aliases) do
  reverse_aliases[to] = from
end

local function escape_pattern(s)
  return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
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
      line = line:gsub(escape_pattern(from), to)
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
