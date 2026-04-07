-- mdagenda/state.lua
-- Module-level singleton. All mutable runtime state lives here.

local M = {
  -- Window and buffer handles.
  win = nil,
  buf = nil,

  -- Current active view: "today" | "priority" | "calendar"
  current_view = "today",

  -- Vault filter: nil = all, or "notes" | "omni" | "work"
  vault_filter = nil,

  -- Calendar sub-state.
  calendar_mode   = "week",   -- "week" | "month"
  -- Anchor date string "YYYY-MM-DD" — the week/month being displayed.
  calendar_anchor = nil,      -- populated on first calendar open

  -- Whether to show completed todos.
  show_done = false,

  -- Whether the panel is in full-window mode.
  full_window = false,

  -- Cached todo list (array of todo objects from parser).
  todos = {},

  -- Timestamp (os.time()) of the last completed scan.
  last_scan = nil,

  -- Maps buffer line number (1-indexed) → todo object.
  -- Used by <CR> and split navigation.
  line_map = {},

  -- Maps buffer line number → { section, collapsed } for collapsible rows.
  -- Used by <Tab> expand/collapse.
  collapse_map = {},
}

-- Reset navigation maps before each render.
function M.clear_maps()
  M.line_map     = {}
  M.collapse_map = {}
end

return M
