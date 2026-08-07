-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- local function git_root()
--   local result = vim.fn.systemlist("git rev-parse --show-toplevel")
--   return result[1]
-- end

local git = require("utils.git")
local root = git.root()

-- Copy relative path to clipboard
-- vim.keymap.set("n", "<leader>fy", function()
--   local root = git_root()
--   local file = vim.fn.expand("%:p")
--
--   local rel = vim.fn.fnamemodify(file, ":." .. root)
--
--   vim.fn.setreg("+", rel)
--   vim.notify("Copied relative path:\n" .. rel)
-- end, { desc = "Copy git-relative path" })

-- Copy relative path WITH ln #/selection #s to clipboard
local function copy_path_with_lines()
  local file = vim.fn.expand("%:p")
  local rel = vim.fn.fnamemodify(file, ":." .. root)

  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" or mode == "\22" then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    rel = string.format("%s#%d-%d", rel, start_line, end_line)
  else
    rel = string.format("%s#%d", rel, vim.fn.line("."))
  end

  vim.fn.setreg("+", rel)
  vim.notify("Copied:\n" .. rel)
end

vim.keymap.set("n", "<leader>fy", copy_path_with_lines, {
  desc = "Copy path:line",
})

vim.keymap.set("x", "<leader>fy", copy_path_with_lines, {
  desc = "Copy path:range",
})

-- Copy absolute path to clipboard
vim.keymap.set("n", "<leader>fY", function()
  local file = vim.fn.expand("%:p")

  vim.fn.setreg("+", file)
  vim.notify("Copied absolute path:\n" .. file)
end, { desc = "Copy absolute path" })

-- Triggers hover window automatically on cursor idle
vim.api.nvim_create_augroup("LSPHoverAuto", { clear = true })
vim.api.nvim_create_autocmd("CursorHold", {
  group = "LSPHoverAuto",
  pattern = "*",
  callback = function()
    -- Only trigger if the completion menu is NOT open and no other float is present
    if vim.fn.pumvisible() == 0 and vim.api.nvim_win_get_config(0).relative == "" then
      vim.lsp.buf.hover()
    end
  end,
})

-- Sets the idle duration to 1 second
vim.opt.updatetime = 1000

vim.keymap.set("n", "<leader>ct", vim.lsp.buf.type_definition, {
  desc = "LSP type definition",
})

vim.keymap.set("n", "<leader>cd", function()
  require("telescope.builtin").lsp_definitions()
end, {
  desc = "LSP definitions",
})

-- Go to definition in split window (retain focus in original)
vim.keymap.set("n", "g/", function()
  local current_win = vim.api.nvim_get_current_win()

  vim.cmd("rightbelow vsplit")
  vim.lsp.buf.definition()

  vim.schedule(function()
    vim.api.nvim_set_current_win(current_win)
  end)
end, {
  desc = "Goto Definition in split",
})
