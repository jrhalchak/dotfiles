-- mdagenda/views/calendar.lua
-- Week view: 7-column day grid with timed items shown inline.
-- Month view: date grid; <CR> on a day zooms to week view.
-- [ / ] navigates weeks or months depending on calendar_mode.

local state = require("mdagenda.state")

local M = {}

local DAY_NAMES   = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local MONTH_NAMES = {
  "January","February","March","April","May","June",
  "July","August","September","October","November","December",
}

-- ── date helpers ──────────────────────────────────────────────────────────

-- Parse "YYYY-MM-DD" → { year, month, day }
local function parse_date(s)
  if not s then return nil end
  local y, m, d = s:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not y then return nil end
  return { year = tonumber(y), month = tonumber(m), day = tonumber(d) }
end

-- { year, month, day } → os.time()
local function to_time(t)
  return os.time({ year = t.year, month = t.month, day = t.day,
                   hour = 0, min = 0, sec = 0 })
end

-- os.time() → "YYYY-MM-DD"
local function fmt_date(ts)
  return os.date("%Y-%m-%d", ts)
end

-- Return "YYYY-MM-DD" for Monday of the week containing ds ("YYYY-MM-DD").
local function week_start(ds)
  local t   = parse_date(ds)
  local ts  = to_time(t)
  local dow = tonumber(os.date("%w", ts)) -- 0=Sun
  -- We want Mon as the first column; shift Sun to be col 7.
  local offset = (dow == 0) and 6 or (dow - 1)
  return fmt_date(ts - offset * 86400)
end

-- Return "YYYY-MM-DD" for the first day of the month containing ds.
local function month_start(ds)
  local t = parse_date(ds)
  return string.format("%04d-%02d-01", t.year, t.month)
end

-- Add N days to a "YYYY-MM-DD" string.
local function add_days(ds, n)
  local t  = parse_date(ds)
  local ts = to_time(t)
  return fmt_date(ts + n * 86400)
end

-- Add N months (clamping day to last day of target month).
local function add_months(ds, n)
  local t  = parse_date(ds)
  local m  = t.month + n
  local y  = t.year
  while m > 12 do m = m - 12; y = y + 1 end
  while m < 1  do m = m + 12; y = y - 1 end
  -- days in target month
  local last = tonumber(os.date("%d", os.time({ year=y, month=m+1, day=0,
                                                hour=0, min=0, sec=0 })))
  local d = math.min(t.day, last)
  return string.format("%04d-%02d-%02d", y, m, d)
end

-- Number of days in a given month.
local function days_in_month(year, month)
  return tonumber(os.date("%d", os.time({ year=year, month=month+1, day=0,
                                          hour=0, min=0, sec=0 })))
end

-- ── todo helpers ──────────────────────────────────────────────────────────

-- Build a table: date_str → list of todos.
local function build_date_index()
  local idx          = {}
  local vault_filter = state.vault_filter
  local show_done    = state.show_done

  for _, t in ipairs(state.todos) do
    if vault_filter and t.vault ~= vault_filter then goto continue end
    if t.state == "cancelled" then goto continue end
    if not show_done and t.state == "complete" then goto continue end
    if t.due_date then
      if not idx[t.due_date] then idx[t.due_date] = {} end
      table.insert(idx[t.due_date], t)
    end
    ::continue::
  end

  -- Sort each day's list by time then file.
  for _, list in pairs(idx) do
    table.sort(list, function(a, b)
      local at = a.due_time or "99:99"
      local bt = b.due_time or "99:99"
      if at ~= bt then return at < bt end
      return (a.file or "") < (b.file or "")
    end)
  end

  return idx
end

-- ── highlight helpers ─────────────────────────────────────────────────────

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

local function add_line(lines, text, hl_chunks)
  table.insert(lines, { text = text, hl = hl_chunks or {} })
end

-- ── week view ─────────────────────────────────────────────────────────────

local function render_week(buf)
  local anchor = state.calendar_anchor or fmt_date(os.time())
  local ws     = week_start(anchor)
  local td     = fmt_date(os.time())
  local idx    = build_date_index()

  local lines  = {}
  state.clear_maps()

  -- Title
  local we = add_days(ws, 6)
  add_line(lines, "  Calendar: Week  " .. ws .. " — " .. we, {
    { 2, 17, "MdAgendaHeader" },
  })
  add_line(lines, "  [ prev ]  [ next ]  [m] month view", {
    { 2, 10, "MdAgendaDimmed" }, { 12, 20, "MdAgendaDimmed" },
  })
  add_line(lines, "", {})

  -- Column headers: Mon Tue Wed Thu Fri Sat Sun
  local DAY_ORDER = { "Mon","Tue","Wed","Thu","Fri","Sat","Sun" }
  local header = "  "
  for _, d in ipairs(DAY_ORDER) do
    header = header .. string.format("%-12s", d)
  end
  add_line(lines, header, { { 2, #header, "MdAgendaHeader" } })
  add_line(lines, "", {})

  -- Date row.
  local date_row = "  "
  local date_hl  = {}
  for i = 0, 6 do
    local ds   = add_days(ws, i)
    local dp   = parse_date(ds)
    local cell = string.format("%-12s", dp.day)
    local col  = #date_row
    if ds == td then
      table.insert(date_hl, { col, col + #cell, "MdAgendaCalToday" })
    else
      local dow = tonumber(os.date("%w", to_time(dp)))
      if dow == 0 or dow == 6 then
        table.insert(date_hl, { col, col + #cell, "MdAgendaCalWeekend" })
      end
    end
    date_row = date_row .. cell
  end
  add_line(lines, date_row, date_hl)
  add_line(lines, "", {})

  -- Find the max number of todos across all 7 days.
  local max_rows = 0
  for i = 0, 6 do
    local ds = add_days(ws, i)
    local c  = idx[ds] and #idx[ds] or 0
    if c > max_rows then max_rows = c end
  end
  if max_rows == 0 then max_rows = 1 end

  -- Render todo rows.
  for row = 1, max_rows do
    local row_text = "  "
    local row_hl   = {}
    for col = 0, 6 do
      local ds       = add_days(ws, col)
      local day_todos = idx[ds] or {}
      local todo      = day_todos[row]
      local cell_text
      if todo then
        local glyph = STATE_GLYPH[todo.state] or "[ ]"
        local time  = todo.due_time and (todo.due_time .. " ") or ""
        -- truncate to fit column width (10 chars + glyph)
        local avail = 9 - #time
        local short = todo.text:sub(1, avail)
        cell_text = string.format("%-12s", glyph .. " " .. time .. short)

        local base = #row_text
        table.insert(row_hl, { base, base + 3, STATE_HL[todo.state] or "Normal" })
        if todo.vault then
          -- vault colour on the text portion
          table.insert(row_hl, { base + 4, base + 4 + #time + #short,
                                  VAULT_HL[todo.vault] or "Normal" })
        end

        local lnum = #lines + 1
        -- We store the todo; we'll correct lnum after add_line below.
        -- Use a sentinel and patch after.
        state.line_map["__pending_" .. lnum .. "_" .. col] = { lnum = lnum, col = col, todo = todo }
      else
        cell_text = string.rep(" ", 12)
      end
      row_text = row_text .. cell_text
    end
    add_line(lines, row_text, row_hl)
  end

  -- Write buffer.
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  local text_lines = {}
  for _, l in ipairs(lines) do table.insert(text_lines, l.text) end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Highlights.
  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
  local ns = vim.api.nvim_create_namespace("MdAgenda")
  for lnum, l in ipairs(lines) do
    for _, chunk in ipairs(l.hl) do
      vim.api.nvim_buf_add_highlight(buf, ns, chunk[3], lnum - 1, chunk[1], chunk[2])
    end
  end

  -- Resolve pending line_map entries to simple todo lookups.
  -- Since the week view has todos distributed across columns in a single line,
  -- we map a line to the first todo on that line for <CR> to use.
  local cleaned = {}
  for k, v in pairs(state.line_map) do
    if type(k) == "string" and k:match("^__pending_") then
      local lnum = tonumber(k:match("^__pending_(%d+)_"))
      if not cleaned[lnum] then
        cleaned[lnum] = v.todo
      end
    end
  end
  state.line_map = cleaned
end

-- ── month view ────────────────────────────────────────────────────────────

local function render_month(buf)
  local anchor = state.calendar_anchor or fmt_date(os.time())
  local ms     = month_start(anchor)
  local mp     = parse_date(ms)
  local td     = fmt_date(os.time())
  local idx    = build_date_index()

  local lines = {}
  state.clear_maps()

  -- Title
  local title = "  Calendar: " .. MONTH_NAMES[mp.month] .. " " .. mp.year
  add_line(lines, title, { { 2, #title, "MdAgendaHeader" } })
  add_line(lines, "  [ prev ]  [ next ]  [w] week view", {
    { 2, 10, "MdAgendaDimmed" }, { 12, 20, "MdAgendaDimmed" },
  })
  add_line(lines, "", {})

  -- Weekday headers (Mon–Sun).
  local DAY_ORDER = { "Mon","Tue","Wed","Thu","Fri","Sat","Sun" }
  local hdr = "  "
  for _, d in ipairs(DAY_ORDER) do hdr = hdr .. string.format("%-6s", d) end
  add_line(lines, hdr, { { 2, #hdr, "MdAgendaHeader" } })

  -- First day of month: what weekday?
  local first_dow = tonumber(os.date("%w", to_time(mp))) -- 0=Sun
  local col_offset = (first_dow == 0) and 6 or (first_dow - 1) -- Mon=0..Sun=6

  local dim        = days_in_month(mp.year, mp.month)
  local row_text   = "  " .. string.rep("      ", col_offset)
  local row_hl     = {}
  local row_col    = col_offset -- which weekday column (0=Mon)

  local function flush_row()
    add_line(lines, row_text, row_hl)
    row_text = "  "
    row_hl   = {}
    row_col  = 0
  end

  for day = 1, dim do
    local ds  = string.format("%04d-%02d-%02d", mp.year, mp.month, day)
    local has = idx[ds] and #idx[ds] > 0
    local lbl = string.format("%2d", day)

    local base = #row_text
    local cell = string.format("%-6s", lbl .. (has and "+" or " "))

    local hl_group
    if ds == td then
      hl_group = "MdAgendaCalToday"
    elseif has then
      hl_group = "MdAgendaCalHasTodo"
    elseif row_col == 5 or row_col == 6 then
      hl_group = "MdAgendaCalWeekend"
    else
      hl_group = "MdAgendaCalDay"
    end
    table.insert(row_hl, { base, base + #cell, hl_group })

    -- Map this line (after flush) to the first todo of this day for <CR>.
    -- We store a "pending" entry and resolve after the loop.
    local tentative_lnum = #lines + 1 -- will be the flushed line
    if idx[ds] and #idx[ds] > 0 then
      state.line_map["__month_" .. ds] = { ds = ds, tentative_lnum = tentative_lnum }
    end

    row_text = row_text .. cell
    row_col  = row_col + 1

    if row_col == 7 then flush_row() end
  end

  -- Flush remaining partial row.
  if row_col > 0 then flush_row() end

  -- Write buffer.
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  local text_lines = {}
  for _, l in ipairs(lines) do table.insert(text_lines, l.text) end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Highlights.
  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
  local ns = vim.api.nvim_create_namespace("MdAgenda")
  for lnum, l in ipairs(lines) do
    for _, chunk in ipairs(l.hl) do
      vim.api.nvim_buf_add_highlight(buf, ns, chunk[3], lnum - 1, chunk[1], chunk[2])
    end
  end

  -- Resolve month day line_map: <CR> on a day line zooms to that week.
  local cleaned = {}
  for k, v in pairs(state.line_map) do
    if type(k) == "string" and k:match("^__month_") then
      -- store { zoom_date = ds } so ui.lua can switch to week view
      cleaned[v.tentative_lnum] = { zoom_date = v.ds }
    end
  end
  state.line_map = cleaned
end

-- ── public API ────────────────────────────────────────────────────────────

function M.render(buf)
  if state.calendar_mode == "month" then
    render_month(buf)
  else
    render_week(buf)
  end
end

-- Navigate: direction is +1 or -1.
function M.navigate(buf, direction)
  local anchor = state.calendar_anchor or fmt_date(os.time())
  if state.calendar_mode == "week" then
    state.calendar_anchor = add_days(anchor, direction * 7)
  else
    state.calendar_anchor = add_months(anchor, direction)
  end
  M.render(buf)
end

-- Toggle week/month mode.
function M.toggle_mode(buf)
  if state.calendar_mode == "week" then
    state.calendar_mode = "month"
  else
    state.calendar_mode = "week"
  end
  M.render(buf)
end

-- Zoom from month view into week view for a given date.
function M.zoom_to_week(buf, ds)
  state.calendar_mode   = "week"
  state.calendar_anchor = ds
  M.render(buf)
end

return M
