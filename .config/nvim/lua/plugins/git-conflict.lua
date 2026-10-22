local function git_root()
  return vim.fs.root(0, ".git") or vim.fn.getcwd()
end

local function conflicted_files()
  local root = git_root()
  local res = vim.system({ "git", "diff", "--name-only", "--diff-filter=U" }, { cwd = root }):wait()
  local files = {}
  for file in (res.stdout or ""):gmatch("[^\n]+") do
    table.insert(files, vim.fs.joinpath(root, file))
  end
  return files
end

local function open_first_conflict()
  local files = conflicted_files()
  if #files == 0 then
    vim.notify("No conflicted files left; ready to commit the merge")
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(files[1]))
  vim.fn.cursor(1, 1)
  vim.fn.search("^<<<<<<< ", "cW")
  vim.cmd("normal! zz")
  vim.notify(("%d conflicted file(s) left"):format(#files))
end

local function resolve_and_next()
  local path = vim.api.nvim_buf_get_name(0)
  if not vim.tbl_contains(conflicted_files(), path) then
    vim.notify("Current file is not a conflicted file", vim.log.levels.WARN)
    return
  end
  if vim.fn.search("^\\(<<<<<<<\\|>>>>>>>\\) ", "nw") > 0 then
    vim.notify("Conflict markers remain in this file", vim.log.levels.WARN)
    return
  end

  vim.cmd("silent write")
  local res = vim.system({ "git", "add", "--", path }, { cwd = git_root() }):wait()
  if res.code ~= 0 then
    vim.notify("git add failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
    return
  end
  open_first_conflict()
end

return {
  "akinsho/git-conflict.nvim",
  version = "*",
  event = "BufReadPre",
  keys = {
    { "<leader>gx", open_first_conflict, desc = "Open first conflicted file" },
    { "<leader>cw", resolve_and_next, desc = "Save + stage + next conflicted file" },
  },
  opts = {},
}
