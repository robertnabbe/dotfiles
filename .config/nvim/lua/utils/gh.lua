local M = {}

M.prs = { out = nil, err = false, fetching = false }

local login
function M.me()
  if login == nil then
    local out = vim.fn.systemlist({ "gh", "config", "get", "-h", "github.com", "user" })
    login = (vim.v.shell_error == 0 and out[1] ~= "" and out[1]) or false
  end
  return login or nil
end

-- CheckRun.conclusion / StatusContext.state combined into one state;
-- any failure wins, anything unfinished means pending.
function M.check_state(rollup)
  if not rollup or #rollup == 0 then
    return nil -- no CI configured
  end

  local pending = false

  for _, c in ipairs(rollup) do
    local s = c.conclusion or c.state
    if s == "FAILURE" or s == "ERROR" or s == "CANCELLED" or s == "TIMED_OUT" or s == "ACTION_REQUIRED" then
      return "fail"
    end

    if not (s == "SUCCESS" or s == "NEUTRAL" or s == "SKIPPED") then
      pending = true
    end
  end

  return pending and "pending" or "pass"
end

function M.fetch_prs(on_change)
  if M.prs.fetching then
    return
  end

  M.prs.fetching = true

  local timer = (vim.uv or vim.loop).new_timer()
  timer:start(
    0,
    80,
    vim.schedule_wrap(function()
      if not M.prs.fetching then
        if not timer:is_closing() then
          timer:stop()
          timer:close()
        end
      end

      if on_change then
        on_change()
      end
    end)
  )

  vim.system({
    "gh",
    "pr",
    "list",
    "--draft=false",
    "-L",
    "10",
    "--json",
    "number,title,author,reviewDecision,statusCheckRollup",
  }, { text = true }, function(res)
    M.prs.err = res.code ~= 0
    if not M.prs.err then -- on failure show last good list
      local ok, decoded = pcall(vim.json.decode, res.stdout or "[]", { luanil = { object = true, array = true } })
      M.prs.out = ok and decoded or {}
    end

    M.prs.fetching = false
  end)
end

return M
