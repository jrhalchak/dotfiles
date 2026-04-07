-- mdagenda/views/priority.lua
-- Renders the Priority view: all outstanding todos grouped High / Medium / Low / Unset.
-- Within each group: sorted by due date (ascending, nil last) then file.

local state = require("mdagenda.state")

local M = {}

local GROUPS = {
  { key = "high",   label = "High priority",   hl = "MdAgendaPriorityHigh" },
  { key = "medium", label = "Medium priority",  hl = "MdAgendaPriorityMedium" },
  { key = "low",    label = "Low priority",     hl = "MdAgendaPriorityLow" },
  { key = "unset",  label = "No priority",      hl = "MdAgendaPriorityUnset" },
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

local DUE_HL_MAP = {
  overdue = "MdAgendaDueOverdue",
  today   = "MdAgendaDueToday",
  soon    = "MdAgendaDueSoon",
  later   = "MdAgendaDueLater",
}

local function today()
  return os.date("%Y-%m-%d")
end

local function due_hl(due_date, td)
  if not due_date then return "MdAgendaDueLater" end
  if due_date < td  then return DUE_HL_MAP.overdue end
  if due_date == td then return DUE_HL_MAP.today end
  -- within 7 days
  local cutoff = os.date("%Y-%m-%d", os.time() + 7 * 86400)
  if due_date <= cutoff then return DUE_HL_MAP.soon end
  return DUE_HL_MAP.later
end

local function sort_group(list)
  table.sort(list, function(a, b)
    -- nil due dates sort last
    if a.due_date and b.due_date then
      if a.due_date ~= b.due_date then return a.due_date < b.due_date end
    elseif a.due_date then
      return true
    elseif b.due_date then
      return false
    end
    return (a.file or "") < (b.file or "")
  end)
end

local function visible_todos()
  local vault_filter = state.vault_filter
  local show_done    = state.show_done
  local out = {}
  for _, t in ipairs(state.todos) do
    if vault_filter and t.vault ~= vault_filter then goto continue end
    if t.state == "cancelled" then goto continue end
    if not show_done and t.state == "complete" then goto continue end
    table.insert(out, t)
    ::continue::
  end
  return out
end

local function add_line(lines, text, hl_chunks)
  table.insert(lines, { text = text, hl = hl_chunks or {} })
end

local function render_todo_line(todo, lines, td)
  local glyph   = STATE_GLYPH[todo.state] or "[ ]"
  local vault   = todo.vault or "?"
  local due     = todo.due_date
  local dtime   = todo.due_time

  local prefix    = "  " .. glyph .. " "
  local vault_tag = "[" .. vault .. "] "
  local body      = todo.text or ""
  local due_str   = ""
  if due then
    due_str = "  " .. due
    if dtime then due_str = due_str .. " " .. dtime end
  end

  local text = prefix .. vault_tag .. body .. due_str

  local hl  = {}
  local pos = 0

  local glyph_start = #"  "
  local glyph_end   = glyph_start + #glyph
  table.insert(hl, { glyph_start, glyph_end, STATE_HL[todo.state] or "Normal" })
  pos = #prefix

  table.insert(hl, { pos, pos + #vault_tag, VAULT_HL[vault] or "Normal" })
  pos = pos + #vault_tag + #body

  if due_str ~= "" then
    table.insert(hl, { pos, pos + #due_str, due_hl(due, td) })
  end

  add_line(lines, text, hl)
end

function M.render(buf)
  local td  = today()
  local all = visible_todos()

  local buckets = { high = {}, medium = {}, low = {}, unset = {} }
  for _, t in ipairs(all) do
    local key = t.priority or "unset"
    if not buckets[key] then key = "unset" end
    table.insert(buckets[key], t)
  end
  for _, g in ipairs(GROUPS) do
    sort_group(buckets[g.key])
  end

  local lines = {}
  state.clear_maps()

  add_line(lines, "  Agenda: Priority", { { 2, 18, "MdAgendaHeader" } })
  add_line(lines, "", {})

  for _, grp in ipairs(GROUPS) do
    local bucket = buckets[grp.key]
    local count  = #bucket
    local hdr    = "  " .. grp.label .. " (" .. count .. ")"
    add_line(lines, hdr, { { 2, #hdr, grp.hl } })

    if count == 0 then
      add_line(lines, "    (none)", { { 4, 10, "MdAgendaDimmed" } })
    else
      for _, todo in ipairs(bucket) do
        local lnum = #lines + 1
        render_todo_line(todo, lines, td)
        state.line_map[lnum] = todo
      end
    end

    add_line(lines, "", {})
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  local text_lines = {}
  for _, l in ipairs(lines) do table.insert(text_lines, l.text) end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
  local ns = vim.api.nvim_create_namespace("MdAgenda")
  for lnum, l in ipairs(lines) do
    for _, chunk in ipairs(l.hl) do
      vim.api.nvim_buf_add_highlight(buf, ns, chunk[3], lnum - 1, chunk[1], chunk[2])
    end
  end
end

return M
