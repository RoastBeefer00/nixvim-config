-- sidekick.cli.session.herdr
-- =====================================================================
-- A Sidekick.nvim session backend that runs each AI CLI as a first-class
-- *herdr* agent (herdr >= 0.7.5), so your Claude / Grok / Codex sessions
-- show up in `herdr agent list`, fire herdr's agent-state hooks, and drive
-- notifications (focus-notify) — while still being viewed inside a Neovim
-- terminal buffer, exactly like Sidekick's built-in tmux backend.
--
-- It mirrors the interface of `sidekick.cli.session.tmux`, but maps the
-- backend methods onto herdr's socket CLI instead of tmux commands:
--
--   tmux                                  herdr (>= 0.7.5)
--   ------------------------------------  ------------------------------------
--   tmux new -A -s <id> … <cmd>           tab create --no-focus + agent start
--   tmux attach-session -t <id>           terminal session control <target>
--   tmux load-buffer / paste-buffer       agent prompt <target> <text>
--   tmux send-keys Enter                  agent send-keys <target> Enter
--   tmux list-panes -a + proc walk        agent list  (native JSON)
--   tmux capture-pane -p                  agent read  <target> --format ansi
--   pid liveness check                    agent get   <target>
--
-- ---------------------------------------------------------------------
-- WIRING (do this from your nvim config, e.g. nixvim extraConfigLua or an
-- after/plugin file — anywhere that runs after sidekick.nvim loads):
--
--   -- 1. register the backend under the name "herdr"
--   package.loaded["sidekick.cli.session.herdr"] = dofile("<path>/herdr.lua")
--   require("sidekick.cli.session").register(
--     "herdr", require("sidekick.cli.session.herdr"))
--
--   -- 2. tell sidekick to use it
--   require("sidekick").setup({
--     cli = { mux = { enabled = true, backend = "herdr", create = "window" } },
--   })
--
-- NOTE: sidekick's Session.setup() hard-codes only tmux/zellij, but it calls
-- Config.tools() first "since they may register session backends" — so
-- registering from a tool spec or from your own init both work. Registering
-- before the first sidekick CLI open is all that matters.
-- =====================================================================

local Config = require("sidekick.config")
local Util = require("sidekick.util")

---@class sidekick.cli.muxer.Herdr: sidekick.cli.Session
---@field herdr_pane_id string   herdr pane id, e.g. "w4:p3"
---@field herdr_target string    what we pass as <target> to herdr agent/terminal cmds
local M = {}
M.__index = M

-- Path to the herdr binary. Overridable via vim.g.sidekick_herdr_cmd.
local function bin()
  return vim.g.sidekick_herdr_cmd or "herdr"
end

-- Run a herdr CLI command and decode its single-line JSON envelope.
-- herdr prints one JSON object of the shape {"id":..,"result":{..},"type":..}
-- or an error envelope. Returns the decoded `result` table (or nil).
---@param args string[]
---@param opts? { notify?: boolean }
---@return table? result, table? raw
local function herdr_json(args, opts)
  opts = opts or {}
  local cmd = { bin() }
  vim.list_extend(cmd, args)
  local _, stdout = Util.exec(cmd, { notify = opts.notify == true })
  if not stdout or stdout == "" then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, stdout)
  if not ok or type(decoded) ~= "table" then
    return nil
  end
  return decoded.result or decoded, decoded
end

-- Map a Sidekick tool name to a herdr agent `--kind`.
-- herdr 0.7.5 kinds: pi claude codex gemini cursor devin agy cline omp
-- mastracode opencode copilot kimi kiro droid amp grok hermes kilo qodercli maki
local KIND_BY_TOOL = {
  claude = "claude",
  codex = "codex",
  gemini = "gemini",
  grok = "grok",
  copilot = "copilot",
  opencode = "opencode",
  cursor = "cursor",
  droid = "droid",
  amp = "amp",
  kimi = "kimi",
  cline = "cline",
  devin = "devin",
  qwen = nil, -- no herdr kind; falls through to raw command (see start())
}

---@return string? kind
function M:herdr_kind()
  return KIND_BY_TOOL[self.tool.name]
end

-- ---------------------------------------------------------------------
-- lifecycle hooks
-- ---------------------------------------------------------------------

function M:init()
  -- We only treat a session as "external" (owned by an already-running herdr)
  -- when we discovered it via M.sessions(). Freshly-created sessions are ours.
  if self.started then
    self.external = self.herdr_target ~= nil
  else
    -- Prefer running inside herdr when we're already inside a herdr session
    -- (HERDR_ENV=1), unless the user forced the plain terminal backend.
    self.external = vim.env.HERDR_ENV == "1" and Config.cli.mux.create ~= "terminal"
  end
  -- external (herdr-owned) sessions win the priority race over a fresh terminal
  self.priority = self.external and 10 or 50
end

--- Create a new herdr agent and return nil (we attach to it ourselves via a
--- terminal Cmd from :attach()). If we can't create one, return a Cmd so
--- sidekick falls back to spawning the tool in a plain nvim terminal.
---@return sidekick.cli.terminal.Cmd?
function M:start()
  -- 1. Create a pane to host the agent. A new tab keeps each agent isolated
  --    (closest analog to `tmux new -s`); `pane split` is the alternative.
  local create = { "tab", "create", "--no-focus", "--cwd", self.cwd }
  local kind = self:herdr_kind()
  local label = ("sidekick-%s"):format(self.tool.name)
  vim.list_extend(create, { "--label", label })
  -- forward tool env onto the created pane's shell
  for key, value in pairs(self.tool.env or {}) do
    if value ~= false then
      vim.list_extend(create, { "--env", ("%s=%s"):format(key, tostring(value)) })
    end
  end

  local result = herdr_json(create, { notify = true })
  -- tab create returns {"type":"tab_created","tab":{...},"root_pane":{"pane_id":...}}
  local pane_id = result and (result.pane_id or (result.root_pane and result.root_pane.pane_id))
  if not pane_id then
    -- Could not create a herdr pane → let sidekick spawn a plain terminal.
    return { cmd = self.tool.cmd, env = self.tool.env }
  end
  self.herdr_pane_id = pane_id
  self.herdr_target = pane_id
  self.herdr_label = label  -- agent name; used as TARGET for `herdr agent attach`

  if kind then
    -- 2a. Promote the pane's shell into a detected herdr agent of this kind.
    --     `agent start` waits for interactive readiness and confirms detection.
    local start = { "agent", "start", label, "--kind", kind, "--pane", pane_id }
    -- pass tool CLI args after `--` (e.g. model flags)
    local extra = vim.list_slice(self.tool.cmd, 2)
    if #extra > 0 then
      table.insert(start, "--")
      vim.list_extend(start, extra)
    end
    herdr_json(start, { notify = true })
    Util.info(("Started **%s** as a herdr agent"):format(self.tool.name))
  else
    -- 2b. No known herdr kind → just run the raw command in the pane.
    --     herdr's detection manifests may still classify it as an agent.
    local run = { "pane", "run", pane_id }
    vim.list_extend(run, self.tool.cmd)
    herdr_json(run, { notify = true })
    Util.info(("Started **%s** in a herdr pane"):format(self.tool.name))
  end

  self.started = true
  -- id used by sidekick's session table; make it stable + herdr-derived
  self.id = ("herdr %s"):format(pane_id)
  return self:attach()
end

--- Attach: return the Cmd the nvim terminal buffer should run to render the
--- agent. `herdr agent attach <NAME>` takes the agent's registered name
--- (e.g. "sidekick-claude"), NOT the pane_id or terminal_id.
---@return sidekick.cli.terminal.Cmd?
function M:attach()
  local target = self.herdr_label
  if not target then
    return
  end
  return {
    cmd = { bin(), "agent", "attach", target, "--takeover" },
    env = {
      HERDR_PANE_ID = false,
      HERDR_TAB_ID = false,
      HERDR_WORKSPACE_ID = false,
    },
  }
end

function M:detach()
  return self
end

--- Liveness: ask herdr whether the agent/pane still exists.
---@return boolean
function M:is_running()
  if not self.herdr_target then
    return false
  end
  local result = herdr_json({ "agent", "get", self.herdr_target }, { notify = false })
  return result ~= nil and result.agent ~= nil
end

-- ---------------------------------------------------------------------
-- input
-- ---------------------------------------------------------------------

--- Send text to the agent without submitting. herdr's `agent prompt` submits
--- immediately, so for the "type but don't send" semantics sidekick expects
--- from send(), we use `pane send-text` (literal, no Enter).
---@param text string
function M:send(text)
  if not self.herdr_pane_id then
    return
  end
  Util.exec({ bin(), "pane", "send-text", self.herdr_pane_id, text }, { notify = false })
end

--- Submit the current input (send an Enter key press to the agent).
function M:submit()
  if not self.herdr_pane_id then
    return
  end
  Util.exec({ bin(), "agent", "send-keys", self.herdr_target, "Enter" }, { notify = false })
end

--- Read the agent's recent terminal output as ANSI text (used for dumps /
--- the scrollback preview).
---@return string?
function M:dump()
  if not self.herdr_target then
    return
  end
  local args = {
    "agent", "read", self.herdr_target,
    "--source", "recent",
    "--format", "ansi",
    "--lines", tostring(Config.cli.mux.dump),
  }
  local result = herdr_json(args, { notify = false })
  return result and result.text or nil
end

-- ---------------------------------------------------------------------
-- discovery
-- ---------------------------------------------------------------------

--- List all agents herdr currently knows about, as sidekick session states.
--- This is what lets a herdr agent you started elsewhere (or a previous nvim)
--- show up in sidekick's picker.
---@return sidekick.cli.session.State[]
function M.sessions()
  local ret = {} ---@type sidekick.cli.session.State[]
  local result = herdr_json({ "agent", "list" }, { notify = false })
  local agents = result and result.agents
  if type(agents) ~= "table" then
    return ret
  end

  local Config_tools = Config.tools()
  for _, a in ipairs(agents) do
    -- Map herdr's agent kind back to a sidekick tool. Prefer an exact name
    -- match; fall back to any tool whose is_proc would accept this kind.
    local tool_name = a.agent
    local tool = Config_tools[tool_name]
    if tool then
      ret[#ret + 1] = {
        id = ("herdr %s"):format(a.pane_id),
        cwd = a.foreground_cwd or a.cwd,
        tool = tool_name,
        herdr_pane_id = a.pane_id,
        herdr_target = a.pane_id,
        herdr_label = a.name,        -- agent name; TARGET for `herdr agent attach`
        herdr_terminal_id = a.terminal_id,
        mux_session = a.workspace_id,
      }
    end
  end
  return ret
end

return M
