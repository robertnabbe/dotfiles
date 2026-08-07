return {
  { "catppuccin/nvim" },
  { "folke/tokyonight.nvim" },
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("dracula")
    end,
  },
  { "rose-pine/neovim" },
  { "EdenEast/nightfox.nvim" },
}
