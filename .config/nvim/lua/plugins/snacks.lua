local max_width = 100

return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false,
    },
    dashboard = {
      lazy = false,
      enabled = true,
      width = max_width,
      pane_gap = 1,
      preset = {
        header = vim.trim([[
 ██████   █████                                ███                 
░░██████ ░░███                                ░░░                  
 ░███░███ ░███   ██████   ██████  █████ █████ ████  █████████████  
 ░███░░███░███  ███░░███ ███░░███░░███ ░░███ ░░███ ░░███░░███░░███ 
 ░███ ░░██████ ░███████ ░███ ░███ ░███  ░███  ░███  ░███ ░███ ░███ 
 ░███  ░░█████ ░███░░░  ░███ ░███ ░░███ ███   ░███  ░███ ░███ ░███ 
 █████  ░░█████░░██████ ░░██████   ░░█████    █████ █████░███ █████
░░░░░    ░░░░░  ░░░░░░   ░░░░░░     ░░░░░    ░░░░░ ░░░░░ ░░░ ░░░░░ 
]]),
      },
      sections = {
        { section = "header", height = 7 },
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
        { section = "startup" },
        function()
          local in_git = Snacks.git.get_root() ~= nil
          local cmds = {
            {
              height = 2,
              text = {
                { " ", hl = "icon" },
                { " Current branch", hl = "title" },
                { "\n" },
                { "   " .. (vim.fn.systemlist({ "git", "branch", "--show-current" })[1] or ""), hl = "Statement" },
              },
              enabled = in_git,
              padding = 1,
              indent = 0,
            },
            {
              key = "P",
              action = function()
                Snacks.picker.gh_pr({ confirm = "gh_browse" })
              end,
              enabled = in_git,
              padding = 1,
              indent = 0,
              text = (function()
                local lines = {
                  { " ", hl = "icon" },
                  { " Open PRs", hl = "title" },
                  { (" "):rep(math.max(1, max_width - 11 - 1)) }, -- padding so P sits on ther far right edge (11=title+icon,1=P)
                  { "P", hl = "SnacksDashboardKey" },
                  { "\n" },
                }
                local out = vim.fn.systemlist({
                  "gh",
                  "pr",
                  "list",
                  "--draft=false",
                  "-L",
                  "10",
                  "--json",
                  "number,title,author,reviewDecision",
                  "--template",
                  "{{range .}}{{.number}}\t{{.title}}\t{{.author.login}}\t{{.reviewDecision}}\n{{end}}",
                })
                if vim.v.shell_error ~= 0 then
                  table.insert(lines, { "   gh unavailable", hl = "Comment" })
                  return lines
                end
                if #out == 0 then
                  table.insert(lines, { "   no open PRs", hl = "Comment" })
                  return lines
                end
                -- { icon, icon hl }
                local review_style = {
                  APPROVED = { " ", "DiagnosticOk" },
                  CHANGES_REQUESTED = { "", "DiagnosticError" },
                  REVIEW_REQUIRED = { " ", "DiagnosticWarn" },
                }
                local title_w = 70
                for _, line in ipairs(out) do
                  local num, title, author, review = line:match("^(%d+)\t(.-)\t(.-)\t(.-)$")
                  if num then
                    local icon, icon_hl = unpack(review_style[review] or { "", "Comment" })
                    if vim.fn.strchars(title) > title_w then
                      title = vim.fn.strcharpart(title, 0, title_w - 2) .. ".."
                    end
                    table.insert(lines, { "  " .. icon .. " ", hl = icon_hl })
                    table.insert(lines, { "#" .. num, hl = "Statement", width = 7, align = "left" })
                    table.insert(lines, { title, hl = "normal", width = title_w, align = "left" })
                    table.insert(lines, { author, hl = "special", width = 18, align = "right" })
                    table.insert(lines, { "\n" })
                  end
                end
                return lines
              end)(),
            },
            -- {
            --   icon = " ",
            --   title = "Open PRs",
            --   cmd = 'gh pr list --search "draft:false" -L 10',
            --   key = "P",
            --   action = function()
            --     vim.fn.jobstart("gh pr list --web", { detach = true })
            --   end,
            --   height = 14,
            --   section = "terminal",
            --   enabled = in_git,
            --   padding = 1,
            --   ttl = 5 * 60,
            --   indent = 3,
            -- },
            {
              icon = " ",
              title = "Recent Files",
              section = "recent_files",
              limit = in_git and 5 or 7,
              indent = 2,
              padding = 1,
              filter = function(file)
                return not vim.tbl_contains({
                  "COMMIT_EDITMSG",
                  "MERGE_MSG",
                  "TAG_EDITMSG",
                  "git-rebase-todo",
                }, vim.fs.basename(file))
              end,
            },
            {
              icon = " ",
              title = "Projects",
              section = "projects",
              limit = in_git and 5 or 7,
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
