-- mdagenda/views/today.lua
-- Renders the Today view: sections Overdue / Today / This week / Later /
-- No due date (collapsed by default, <Tab> to expand).
-- Within each section: sorted by priority (high→medium→low→nil) then file.

local state  = require("mdagenda.state")

local M = {}

-- Priority sort order.
local PRIORITY_ORDER = { high = 1, medium = 2, low = 3 }

local function priority_rank(p)
  return PRIORITY_ORDER[p] or 4
end

-- Today's date as "YYYY-MM-DD".
local function today()
  return os.date("%Y-%m-%d")
end

-- End of current ISO week (Sunday).
local function week_end()
  local t   = os.time()
  local dow = tonumber(os.date("%w", t)) -- 0=Sun
  local days_left = (7 - dow) % 7
  if days_left == 0 then days_left = 7 end
  return os.date("%Y-%m-%d", t + days_left * 86400)
end

local SECTIONS = {
  { key = "overdue",  label = "Overdue" },
  { key = "today",    label = "Today" },
  { key = "week",     label = "This week" },
  { key = "later",    label = "Later" },
  { key = "no_due",   label = "No due date" },
}

local SECTION_HL = {
  overdue = "MdAgendaHeaderOverdue",
  today   = "MdAgendaHeaderToday",
  week    = "MdAgendaHeader",
  later   = "MdAgendaHeaderLater",
  no_due  = "MdAgendaDimmed",
}

local STATE_GLYPH = {
  not_started = "[ ]",
  in_progress = "[/]",
  blocked     = "[!]",
  complete    = "[x]",
  cancelled   = "[-]",
}

local STATE_HL = {
  not_started = "MdAgendaStateNotStarted",
  in_progress = "MdAgendaStateInProgress",
  blocked     = "MdAgendaStateBlocked",
  complete    = "MdAgendaStateDone",
  cancelled   = "MdAgendaStateCancelled",
}

local VAULT_HL = {
  notes = "MdAgendaVaultNotes",
  omni  = "MdAgendaVaultOmni",
  work  = "MdAgendaVaultWork",
}

local PRIORITY_HL = {
  high   = "MdAgendaPriorityHigh",
  medium = "MdAgendaPriorityMedium",
  low    = "MdAgendaPriorityLow",
}

local DUE_HL = {
  overdue = "MdAgendaDueOverdue",
  today   = "MdAgendaDueToday",
  week    = "MdAgendaDueSoon",
  later   = "MdAgendaDueLater",
}

-- Classify a todo into a section key.
local function classify(todo, td, we)
  if not todo.due_date then return "no_due" end
  if todo.due_date < td  then return "overdue" end
  if todo.due_date == td then return "today" end
  if todo.due_date <= we  then return "week" end
  return "later"
end

local function sort_todos(list)
  table.sort(list, function(a, b)
    local pa, pb = priority_rank(a.priority), priority_rank(b.priority)
    if pa ~= pb then return pa < pb end
    return (a.file or "") < (b.file or "")
  end)
end

-- Filter according to current state.
local function visible_todos()
  local vault_filter = state.vault_filter
  local show_done    = state.show_done
  local out = {}
  for _, t in ipairs(state.todos) do
    if vault_filter and t.vault ~= vault_filter then goto continue end
    if t.state == "cancelled" then goto continue end
    if not show_done and (t.state == "complete") then goto continue end
    table.insert(out, t)
    ::continue::
  end
  return out
end

-- Add a line to the buffer, return (1-indexed) line number.
-- @param lines   table  accumulator: array of { text, hl_chunks }
--   where hl_chunks is array of { col_start, col_end, hl_group } (byte offsets)
local function add_line(lines, text, hl_chunks)
  table.insert(lines, { text = text, hl = hl_chunks or {} })
end

-- @param todo    todo object
-- @param section_key  string
-- @param lines   accumulator
-- @param lnum    current 1-indexed line (after header lines)
local function render_todo_line(todo, section_key, lines)
  local glyph    = STATE_GLYPH[todo.state] or "[ ]"
  local vault    = todo.vault or "?"
  local priority = todo.priority
  local due      = todo.due_date
  local dtime    = todo.due_time

  -- Build text: "  [x] vault  text  [due]  [priority]"
  local prefix = "  " .. glyph .. " "
  local vault_tag = "[" .. vault .. "] "
  local body   = todo.text or ""
  local due_str = ""
  if due then
    due_str = "  " .. due
    if dtime then due_str = due_str .. " " .. dtime end
  end
  local prio_str = priority and ("  [" .. priority .. "]") or ""

  local text = prefix .. vault_tag .. body .. due_str .. prio_str

  -- Highlight chunks: { col_start, col_end, group } (byte offsets, 0-indexed)
  local hl = {}
  local pos = 0

  -- glyph
  local glyph_start = #"  "
  local glyph_end   = glyph_start + #glyph
  table.insert(hl, { glyph_start, glyph_end, STATE_HL[todo.state] or "Normal" })
  pos = #prefix

  -- vault tag
  table.insert(hl, { pos, pos + #vault_tag, VAULT_HL[vault] or "Normal" })
  pos = pos + #vault_tag

  -- body (no special hl, inherits Normal)
  pos = pos + #body

  -- due date
  if due_str ~= "" then
    local due_hl = DUE_HL[section_key] or "MdAgendaDueLater"
    table.insert(hl, { pos, pos + #due_str, due_hl })
    pos = pos + #due_str
  end

  -- priority
  if prio_str ~= "" then
    table.insert(hl, { pos, pos + #prio_str, PRIORITY_HL[priority] or "Normal" })
  end

  add_line(lines, text, hl)
end

-- Public: render the Today view into buf.
-- Returns array of { text, hl } lines and populates state.line_map / collapse_map.
-- Caller (ui.lua) is responsible for writing lines to the buffer.
function M.render(buf)
  local td = today()
  local we = week_end()

  local all = visible_todos()

  -- Bucket into sections.
  local buckets = { overdue = {}, today = {}, week = {}, later = {}, no_due = {} }
  for _, t in ipairs(all) do
    local sec = classify(t, td, we)
    table.insert(buckets[sec], t)
  end
  for _, sec in ipairs(SECTIONS) do
    sort_todos(buckets[sec.key])
  end

  local lines = {}
  state.clear_maps()

  -- Title line.
  add_line(lines, "  Agenda: Today  [" .. td .. "]", {
    { 2, 19, "MdAgendaHeader" },
  })
  add_line(lines, "", {})

  local no_due_collapsed = state.collapse_map._no_due_collapsed
  if no_due_collapsed == nil then no_due_collapsed = true end

  for _, sec in ipairs(SECTIONS) do
    local bucket = buckets[sec.key]
    local count  = #bucket
    local is_no_due = sec.key == "no_due"

    -- Section header.
    local hdr_text
    if is_no_due then
      local arrow = no_due_collapsed and ">" or "v"
      hdr_text = "  " .. arrow .. " " .. sec.label .. " (" .. count .. ")"
    else
      hdr_text = "  " .. sec.label .. " (" .. count .. ")"
    end

    local hdr_lnum = #lines + 1
    add_line(lines, hdr_text, {
      { 2, #hdr_text, SECTION_HL[sec.key] or "MdAgendaHeader" },
    })

    if is_no_due then
      state.collapse_map[hdr_lnum] = { section = "no_due", collapsed = no_due_collapsed }
    end

    if count == 0 then
      add_line(lines, "    (none)", { { 4, 10, "MdAgendaDimmed" } })
    elseif not (is_no_due and no_due_collapsed) then
      for _, todo in ipairs(bucket) do
        local todo_lnum = #lines + 1
        render_todo_line(todo, sec.key, lines)
        state.line_map[todo_lnum] = todo
      end
    end

    add_line(lines, "", {})
  end

  -- Write to buffer.
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  local text_lines = {}
  for _, l in ipairs(lines) do
    table.insert(text_lines, l.text)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Apply highlights.
  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
  local ns = vim.api.nvim_create_namespace("MdAgenda")
  for lnum, l in ipairs(lines) do
    for _, chunk in ipairs(l.hl) do
      vim.api.nvim_buf_add_highlight(buf, ns, chunk[3], lnum - 1, chunk[1], chunk[2])
    end
  end

  -- Persist collapsed state for <Tab> toggles.
  state.collapse_map._no_due_collapsed = no_due_collapsed
end

-- Toggle the no-due section collapse state and re-render.
function M.toggle_no_due(buf)
  local cur = state.collapse_map._no_due_collapsed
  state.collapse_map._no_due_collapsed = not cur
  M.render(buf)
end

return M
