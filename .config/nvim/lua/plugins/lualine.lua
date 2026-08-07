local git = require("utils.git")

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = "",
      section_separators = {
        left = "",
        right = "",
      },
      disabled_filetypes = {
        statusline = {
          "snacks_dashboard",
          "alpha",
        },
      },
    },

    sections = {
      lualine_a = {
        "mode",
      },

      lualine_b = {
        {
          "branch",
          icon = "",
        },
      },

      -- lualine_c = {
      --   {
      --     "filename",
      --     path = 1, -- relative path
      --     shorting_target = 80, -- only shorten when necessary
      --     symbols = {
      --       modified = " ●",
      --       readonly = " ",
      --       unnamed = "[No Name]",
      --       newfile = "[New]",
      --     },
      --   },
      -- },

      lualine_c = {
        {
          function()
            local root = git.root()
            local file = vim.fn.expand("%:p")
            local rel = vim.fn.fnamemodify(file, ":." .. root)

            local dir = vim.fn.fnamemodify(rel, ":h")
            if dir == "." then
              return ""
            end

            return dir .. "/"
          end,
          padding = { left = 2, right = 0 },
          color = {
            fg = "#7f849c", -- muted gray
          },
        },
        {
          function()
            return vim.fn.expand("%:t")
          end,
          color = {
            fg = "#F8F8F2", -- Dracula foreground
            gui = "bold",
          },
          padding = 0,
          symbols = {
            modified = " ●",
            readonly = " ",
            unnamed = "[No Name]",
            newfile = "[New]",
          },
        },
      },

      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          sections = { "error", "warn" },
          symbols = {
            error = "✖ ",
            warn = "▲ ",
          },
          colored = true,
          update_in_insert = false,
          always_visible = false,
        },
      },

      lualine_y = {
        "location",
      },

      lualine_z = {},
    },

    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          path = 1,
          shorting_target = 80,
        },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },

    extensions = {
      "lazy",
      "mason",
      "quickfix",
      "trouble",
      "fzf",
    },
  },
}
