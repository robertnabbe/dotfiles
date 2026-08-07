return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          -- Shows dotfiles like .github and .env by default
          hidden = true,
          -- Keeps heavily cluttered folders out of sight if needed
          -- exclude = { "**/.git", "**/node_modules" },
        },
        colorschemes = {
          transform = function(item)
            local ignore = {
              blue = true,
              darkblue = true,
              default = true,
              delek = true,
              desert = true,
              elflord = true,
              evening = true,
              habamax = true,
              industry = true,
              koehler = true,
              lunaperche = true,
              morning = true,
              murphy = true,
              pablo = true,
              peachpuff = true,
              quiet = true,
              retrobox = true,
              ron = true,
              shine = true,
              slate = true,
              sorbet = true,
              torte = true,
              vim = true,
              unokai = true,
              wildcharm = true,
              zaibatsu = true,
              zellner = true,
            }

            if ignore[item.text] then
              return false
            end

            return item
          end,
        },
      },
    },
    terminal = {
      win = {
        position = "bottom",
        height = 15,
        border = "rounded",
      },
    },
  },
  keys = {
    {
      "<C-\\>", -- terminal toggle
      function()
        Snacks.terminal.toggle()
        vim.schedule(function()
          if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
          end
        end)
      end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
  },
}
