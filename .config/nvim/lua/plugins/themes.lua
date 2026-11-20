return {
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
  { "scottmckendry/cyberdream.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
}
