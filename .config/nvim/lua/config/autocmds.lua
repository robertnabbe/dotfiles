-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

---@type vim.api.keyset.highlight
local default_line

---@type vim.api.keyset.highlight
local default_cursor
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- store defaults for the lineNr color swaps below
    default_line = vim.api.nvim_get_hl(0, { name = "LineNr" })
    default_cursor = vim.api.nvim_get_hl(0, { name = "CursorLineNr" })

    -- the window separator line
    vim.api.nvim_set_hl(0, "WinSeparator", {
      fg = "#BD93F9", -- dracula purple
      bg = "NONE",
    })

    --diffview colors (tokyo-night)
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#20303b" })
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#37222c" })
    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1f2231" })
    vim.api.nvim_set_hl(0, "DiffText", { bg = "#394b70" })

    -- treesitter context
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#1e1e2e" })
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#7f849c", bg = "#1e1e2e" })
    vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#ff00cc" })

    -- For a dark theme, give the hover window a slightly lighter background than normal editor code
    vim.api.nvim_set_hl(0, "NoiceLspHover", { bg = "#282a36", fg = "#eeeeee" })
    -- Give the border a distinct, noticeable color (e.g., a bright gray or accent color)
    vim.api.nvim_set_hl(0, "NoiceLspHoverBorder", { fg = "#88c0d0", bg = "#282a36" })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx" },
  callback = function(args)
    local filename = vim.api.nvim_buf_get_name(args.buf)
    if filename:match("%.spec%.") then
      return
    end

    require("utils.imports").canonicalize()
  end,
})

-- Persistence plugin (open last session)
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Don't restore when opening specific files
    if vim.fn.argc() == 0 then
      require("persistence").load()
    end
  end,
})

local function set_line_number_colors(mode)
  if mode == "i" then
    -- Insert
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#50FA7B" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#50FA7B", bold = true })
  elseif mode == "v" or mode == "V" or mode == "\22" then
    -- Visual, Visual Line, Visual Block
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#F1FA8C" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#F1FA8C", bold = true })
  else
    -- Normal: restore theme defaults
    vim.api.nvim_set_hl(0, "LineNr", default_line)
    vim.api.nvim_set_hl(0, "CursorLineNr", default_cursor)
  end
end

local group = vim.api.nvim_create_augroup("ModeLineNumbers", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "ModeChanged" }, {
  group = group,
  callback = function()
    set_line_number_colors(vim.fn.mode())
  end,
})
