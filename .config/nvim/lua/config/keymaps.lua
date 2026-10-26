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
    if vim.fn.pumvisible() ~= 0 or vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) == 0 then
      return
    end
    -- Skip if this buffer's hover float is still open: calling hover() again
    -- while it exists makes Neovim focus that window instead of redrawing it.
    local existing = vim.b.lsp_floating_preview
    if existing and vim.api.nvim_win_is_valid(existing) then
      return
    end
    vim.lsp.buf.hover({ focus = false })
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

-- Open definition in a V-split
vim.keymap.set("n", "gv", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", { desc = "Goto Definition (V-split)" })

vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "Grep" })

-- makes sure change ops don't add to register/clipboard
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "C", '"_C', { noremap = true })

vim.diagnostic.config({
  virtual_text = false,
  float = {
    border = "rounded",
    source = "if_many",
    header = "",
    focusable = false,
    max_width = 80,
  },
})

vim.keymap.set("n", "<leader>cx", vim.diagnostic.open_float, {
  desc = "Show diagnostic",
})

-- jump to the outermost top-level fn definition (e.g. the component)
vim.keymap.set("n", "[T", function()
  local node = vim.treesitter.get_node()

  if not node then
    return
  end

  while node:parent() and node:parent():type() ~= "program" do
    node = node:parent()
  end

  local row, col = node:start()

  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end, { desc = "Jump to top-level definition" })
