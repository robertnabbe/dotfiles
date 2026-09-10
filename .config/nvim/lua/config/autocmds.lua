-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

---@type vim.api.keyset.get_hl_info?
local default_line
---@type vim.api.keyset.get_hl_info?
local default_cursor

local function capture_line_number_defaults()
  default_line = vim.api.nvim_get_hl(0, {
    name = "LineNr",
    link = false,
  })

  default_cursor = vim.api.nvim_get_hl(0, {
    name = "CursorLineNr",
    link = false,
  })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    capture_line_number_defaults()

    vim.api.nvim_set_hl(0, "SnacksDashboardDir", { fg = "#616161" })

    local statement = vim.api.nvim_get_hl(0, { name = "Statement", link = false })
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    vim.api.nvim_set_hl(0, "StatementKnockout", {
      fg = normal.bg,
      bg = statement.fg,
      bold = true,
    })

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
  callback = function()
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
  -- if vim.bo.filetype == "dashboard" then
  --   return
  -- end

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
    if not default_line or not default_cursor then
      capture_line_number_defaults()
    end
    vim.api.nvim_set_hl(0, "LineNr", default_line --[[@as vim.api.keyset.highlight]])
    vim.api.nvim_set_hl(0, "CursorLineNr", default_cursor --[[@as vim.api.keyset.highlight]])
  end
end

local group = vim.api.nvim_create_augroup("ModeLineNumbers", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave", "ModeChanged" }, {
  group = group,
  callback = function()
    set_line_number_colors(vim.fn.mode())
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() ~= 1 then
      return
    end

    local arg = vim.fn.argv(0) --[[@as string]]

    if arg == "" or vim.fn.isdirectory(arg) ~= 1 then
      return
    end

    vim.schedule(function()
      local win = vim.api.nvim_get_current_win()
      local dir_buf = vim.api.nvim_get_current_buf()

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(win, buf)
      pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })

      -- sections/formats come from the merged config, not this call
      ---@diagnostic disable-next-line: missing-fields
      Snacks.dashboard.open({ buf = buf, win = win })
    end)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "SnacksDashboardOpened",
  callback = function()
    vim.api.nvim_set_hl(0, "SnacksDashboardDir", { link = "repeat" })
  end,
})
