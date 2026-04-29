return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  opts = {
    ensure_installed = { "rust", "javascript", "zig" },

    highlight = {
      enable = true,
    },

    indent = {
      enable = true,
    },
  },
}
