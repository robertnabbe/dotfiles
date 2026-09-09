-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.conceallevel = 0
vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.autoindent = true
vim.lsp.inlay_hint.enable(false)

-- match team.settings.json prettier.requireConfig: only format when a prettier config exists
vim.g.lazyvim_prettier_needs_config = true

-- colorscheme handling
--  terminal
vim.api.nvim_set_hl(0, "Terminal", { bg = "NONE" })
vim.g.terminal_color_0 = nil
vim.g.terminal_color_1 = nil
vim.g.terminal_color_2 = nil
vim.g.terminal_color_3 = nil
vim.g.terminal_color_4 = nil
vim.g.terminal_color_5 = nil
vim.g.terminal_color_6 = nil
vim.g.terminal_color_7 = nil
vim.g.terminal_color_8 = nil
vim.g.terminal_color_9 = nil
vim.g.terminal_color_10 = nil
vim.g.terminal_color_11 = nil
vim.g.terminal_color_12 = nil
vim.g.terminal_color_13 = nil
vim.g.terminal_color_14 = nil
vim.g.terminal_color_15 = nil

vim.api.nvim_create_user_command("W", "write", {})
vim.api.nvim_create_user_command("Dashboard", function()
  Snacks.dashboard()
end, { desc = "Open snacks dashboard" })
