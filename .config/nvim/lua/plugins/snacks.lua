return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false,
    },
    dashboard = {
      lazy = false,
      enabled = true,
      width = 100,
      pane_gap = 1,
      preset = {
        header = [[
 ██████   █████                                ███                 
░░██████ ░░███                                ░░░                  
 ░███░███ ░███   ██████   ██████  █████ █████ ████  █████████████  
 ░███░░███░███  ███░░███ ███░░███░░███ ░░███ ░░███ ░░███░░███░░███ 
 ░███ ░░██████ ░███████ ░███ ░███ ░███  ░███  ░███  ░███ ░███ ░███ 
 ░███  ░░█████ ░███░░░  ░███ ░███ ░░███ ███   ░███  ░███ ░███ ░███ 
 █████  ░░█████░░██████ ░░██████   ░░█████    █████ █████░███ █████
░░░░░    ░░░░░  ░░░░░░   ░░░░░░     ░░░░░    ░░░░░ ░░░░░ ░░░ ░░░░░ 
        ]],
      },
      sections = {
        { section = "header", gap = 0, padding = 0, height = 7 },
        function()
          local v = vim.version()

          return {
            align = "center",
            padding = 0,
            text = {
              {
                string.format("v%d.%d.%d  ·  %s", v.major, v.minor, v.patch, os.date("%b %d, %Y")),
                hl = "SnacksDashboardFooter",
              },
            },
          }
        end,
        { section = "startup", gap = 0, padding = 0 },
        function()
          local in_git = Snacks.git.get_root() ~= nil
          local cmds = {
            {
              icon = " ",
              title = "Current branch",
              height = 2,
              text = {
                { " ", hl = "icon" },
                { " Current branch", hl = "title" },
                { "\n" },
                { "   " .. vim.fn.systemlist({ "git", "branch", "--show-current" })[1] or "", hl = "statement" },
              },
              enabled = in_git,
              padding = 1,
              indent = 0,
            },
            {
              icon = " ",
              title = "Open PRs",
              cmd = 'gh pr list --search "draft:false" -L 10',
              key = "P",
              action = function()
                vim.fn.jobstart("gh pr list --web", { detach = true })
              end,
              height = 14,
              section = "terminal",
              enabled = in_git,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            },
            {
              icon = " ",
              title = "Recent Files",
              section = "recent_files",
              limit = in_git and 3 or 5,
              indent = 2,
              padding = 1,
            },
            {
              icon = " ",
              title = "Projects",
              section = "projects",
              limit = in_git and 3 or 5,
              indent = 2,
              padding = 1,
            },
          }
          return cmds
        end,
      },
    },
    picker = {
      sources = {
        explorer = {
          enabled = false, -- disable this pos, i hate it
          hidden = true,
          -- Keeps heavily cluttered folders out of sight if needed
          -- exclude = { "**/.git", "**/node_modules" },
        },
        colorschemes = {
          transform = function(item) -- filter out vim default themes, don't like em
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
  init = function()
    vim.api.nvim_set_hl(0, "SnacksDashboardDir", { fg = "#FF0000" })
  end,
}
