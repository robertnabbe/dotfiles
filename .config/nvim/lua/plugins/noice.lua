return {
  {
    "folke/noice.nvim",
    opts = {
      notify = {
        timeout = 5000,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },

        hover = {
          enabled = true,
          silent = true,
        },

        signature = {
          enabled = true,
        },
      },
      presets = {
        -- bottom_search = true, -- use a classic bottom cmdline for searching
        -- command_palette = true, -- position the cmdline and popupmenu together
        -- long_message_to_split = true, -- send long messages to a split
        -- inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add borders to hover docs and signature help
      },
      views = {
        hover = {
          border = {
            style = "rounded",
          },
          position = { row = 2, col = 2 },
          mouse = false,
          focusable = false,
          win_options = {
            winblend = 0, -- 0 (fully opaque) to 100 (transparent). 10-15 creates a subtle blend
            winhighlight = {
              Normal = "NoiceLspHover", -- Link to a dedicated background group
              FloatBorder = "NoiceLspHoverBorder", -- Visual separation for the frame
            },
          },
        },
      },
    },
  },
}
