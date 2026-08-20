local gh = require("utils.gh")

local dashboard_max_width = 108
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function dashboard_visible()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard" then
      return true
    end
  end
  return false
end

local function refresh_prs()
  gh.fetch_prs(function()
    Snacks.dashboard.update()
  end)
end

return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false,
    },
    dashboard = {
      lazy = false,
      enabled = true,
      width = dashboard_max_width,
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
                { "    ", hl = "DiagnosticWarn" },
                { (vim.fn.systemlist({ "git", "branch", "--show-current" })[1] or ""), hl = "DiagnosticUnderlineInfo" },
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
                if in_git and gh.prs.out == nil and not gh.prs.fetching then
                  refresh_prs() -- first open: kick off the initial fetch
                end

                local icon = " " -- so we can swap it out with spinner anim
                if gh.prs.fetching then
                  local frame = math.floor((vim.uv or vim.loop).hrtime() / 8e7) % #spinner_frames + 1
                  icon = spinner_frames[frame] .. " "
                end

                local lines = {
                  { icon, hl = "icon" },
                  { " Open PRs", hl = "title" },
                  { (" "):rep(math.max(1, dashboard_max_width - 11 - 1)) }, -- padding so P sits on the far right edge (11=title+icon,1=P)
                  { "P", hl = "SnacksDashboardKey" },
                  { "\n" },
                }

                local out = gh.prs.out
                if out == nil then
                  if gh.prs.err then
                    table.insert(lines, { "   gh unavailable", hl = "Comment" })
                  else
                    table.insert(lines, { "   fetching PRs…", hl = "Comment" })
                  end
                  return lines
                end

                if #out == 0 then
                  table.insert(lines, { "   no open PRs", hl = "Comment" })
                  return lines
                end

                -- { icon, icon hl }
                local review_style = {
                  APPROVED = { " ", "Character" },
                  CHANGES_REQUESTED = { " ", "DiagnosticError" },
                  REVIEW_REQUIRED = { " ", "DiagnosticWarn" },
                }
                local checks_style = {
                  pass = { "✓ ", "Character" },
                  fail = { "✗ ", "DiagnosticError" },
                  pending = { "○ ", "DiagnosticWarn" },
                }
                local title_w = dashboard_max_width - 32
                local me = gh.me()

                for _, pr in ipairs(out) do
                  local num, title, author = pr.number, pr.title or "", (pr.author and pr.author.login) or ""
                  local review = pr.reviewDecision or ""

                  if num then
                    local mine = author == me
                    local icon, icon_hl = unpack(review_style[review] or { "", "Comment" })
                    local check = checks_style[gh.check_state(pr.statusCheckRollup)]

                    if vim.fn.strchars(title) > title_w then
                      title = vim.fn.strcharpart(title, 0, title_w - 2) .. ".."
                    end

                    table.insert(lines, { "  " .. icon .. " ", hl = icon_hl })
                    table.insert(lines, { "#" .. num, hl = "Statement", width = 6, align = "left" })
                    table.insert(lines, { check and check[1] or "  ", hl = check and check[2] or "Comment" })
                    table.insert(
                      lines,
                      { title, hl = mine and "CursorLine" or "normal", width = title_w, align = "left" }
                    )
                    table.insert(
                      lines,
                      { author, hl = mine and "Character" or "DiagnosticWarn", width = 18, align = "right" }
                    )
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
        gh_pr = {
          format = function(item, picker)
            -- default gh formatter, but highlight my own PRs
            local ret = require("snacks.picker.source.gh").format(item, picker)
            local me = gh.me()
            if me and item.author == me then
              for _, seg in ipairs(ret) do
                if seg[1] == "@" .. item.author then
                  seg[2] = "Character"
                end
              end
            end
            return ret
          end,
        },
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
    -- Refresh the PR list (async) on window (re-)focus
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        if dashboard_visible() then
          refresh_prs()
        end
      end,
    })
  end,
}
