-- mdagenda/ui.lua
-- Panel creation, render dispatch, and all buffer-local keymaps.
-- Owns the window split logic (side panel vs full window).

local state    = require("mdagenda.state")
local config   = require("mdagenda.config")
local scanner  = require("mdagenda.scanner")
local parser   = require("mdagenda.parser")

local M = {}

-- ── helpers ───────────────────────────────────────────────────────────────

local function is_open()
  return state.win ~= nil
       and vim.api.nvim_win_is_valid(state.win)
       and state.buf ~= nil
       and vim.api.nvim_buf_is_valid(state.buf)
end

local function render()
  if not is_open() then return end
  local view = state.current_view
  if view == "today" then
    require("mdagenda.views.today").render(state.buf)
  elseif view == "priority" then
    require("mdagenda.views.priority").render(state.buf)
  elseif view == "calendar" then
    require("mdagenda.views.calendar").render(state.buf)
  end
end

-- ── scan + render ─────────────────────────────────────────────────────────

function M.refresh()
  if not is_open() then return end
  scanner.scan(function(cb_lines, fm_lines)
    state.todos     = parser.parse(cb_lines, fm_lines)
    state.last_scan = os.time()
    vim.schedule(render)
  end)
end

-- ── panel width ───────────────────────────────────────────────────────────

local function panel_width()
  if config.values.panel_width then
    return config.values.panel_width
  end
  return math.max(40, math.floor(vim.o.columns / 4))
end

-- ── open / close ──────────────────────────────────────────────────────────

local function set_buf_options(buf)
  local opts = {
    buftype    = "nofile",
    bufhidden  = "wipe",
    swapfile   = false,
    modifiable = false,
    filetype   = "mdagenda",
  }
  for k, v in pairs(opts) do
    vim.api.nvim_set_option_value(k, v, { buf = buf })
  end
end

local function set_win_options(win)
  local opts = {
    number         = false,
    relativenumber = false,
    signcolumn     = "no",
    foldcolumn     = "0",
    wrap           = false,
    cursorline     = true,
    winfixwidth    = true,
  }
  for k, v in pairs(opts) do
    vim.api.nvim_set_option_value(k, v, { win = win })
  end
end

local function attach_keymaps(buf)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true,
                                     silent = true, desc = desc })
  end

  -- Close.
  map("q", function() M.close() end, "Close agenda")

  -- View switching.
  map("1", function()
    state.current_view = "today"
    render()
  end, "Agenda: Today view")

  map("2", function()
    state.current_view = "priority"
    render()
  end, "Agenda: Priority view")

  map("3", function()
    state.current_view = "calendar"
    if not state.calendar_anchor then
      state.calendar_anchor = os.date("%Y-%m-%d")
    end
    render()
  end, "Agenda: Calendar view")

  -- Calendar navigation.
  map("[", function()
    if state.current_view == "calendar" then
      require("mdagenda.views.calendar").navigate(state.buf, -1)
    end
  end, "Calendar: previous")

  map("]", function()
    if state.current_view == "calendar" then
      require("mdagenda.views.calendar").navigate(state.buf, 1)
    end
  end, "Calendar: next")

  map("w", function()
    if state.current_view == "calendar" then
      require("mdagenda.views.calendar").toggle_mode(state.buf)
    end
  end, "Calendar: toggle week/month")

  -- Expand/collapse no-due section.
  map("<Tab>", function()
    if state.current_view == "today" then
      require("mdagenda.views.today").toggle_no_due(state.buf)
    end
  end, "Agenda: toggle no-due section")

  -- Vault filter: cycle all → notes → omni → work → all.
  map("v", function()
    local vaults  = config.vault_list() -- sorted by name
    local current = state.vault_filter
    if current == nil then
      state.vault_filter = vaults[1].name
    else
      local found = false
      for i, v in ipairs(vaults) do
        if v.name == current then
          if i < #vaults then
            state.vault_filter = vaults[i + 1].name
          else
            state.vault_filter = nil
          end
          found = true
          break
        end
      end
      if not found then state.vault_filter = nil end
    end
    render()
  end, "Agenda: cycle vault filter")

  -- Done toggle.
  map("d", function()
    state.show_done = not state.show_done
    render()
  end, "Agenda: toggle done items")

  -- Full/side toggle.
  map("f", function() M.toggle_full() end, "Agenda: toggle full window")

  -- Refresh.
  map("r", function() M.refresh() end, "Agenda: refresh")

  -- Jump to file.
  local function jump_todo(cmd)
    local lnum = vim.api.nvim_win_get_cursor(state.win)[1]
    local entry = state.line_map[lnum]
    if not entry then return end

    -- Month calendar: zoom to week on <CR>.
    if entry.zoom_date then
      require("mdagenda.views.calendar").zoom_to_week(state.buf, entry.zoom_date)
      return
    end

    if not entry.file then return end
    local target_win = vim.fn.win_getid(vim.fn.winnr("#"))
    if not target_win or not vim.api.nvim_win_is_valid(target_win)
        or target_win == state.win then
      -- Find any non-agenda window.
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if w ~= state.win then
          target_win = w
          break
        end
      end
    end

    if cmd == "edit" then
      if target_win and vim.api.nvim_win_is_valid(target_win) then
        vim.api.nvim_set_current_win(target_win)
      end
      vim.cmd("edit " .. vim.fn.fnameescape(entry.file))
    elseif cmd == "vsplit" then
      vim.cmd("vsplit " .. vim.fn.fnameescape(entry.file))
    elseif cmd == "split" then
      vim.cmd("split " .. vim.fn.fnameescape(entry.file))
    elseif cmd == "tab" then
      vim.cmd("tabedit " .. vim.fn.fnameescape(entry.file))
    end

    -- Jump to line.
    if entry.lnum then
      vim.api.nvim_win_set_cursor(0, { entry.lnum, 0 })
      vim.cmd("normal! zz")
    end
  end

  map("<CR>",  function() jump_todo("edit")   end, "Agenda: jump to file")
  map("<C-v>", function() jump_todo("vsplit")  end, "Agenda: open vsplit")
  map("<C-s>", function() jump_todo("split")   end, "Agenda: open split")
  map("t",     function() jump_todo("tab")     end, "Agenda: open tab")
end

-- ── open ──────────────────────────────────────────────────────────────────

function M.open()
  if is_open() then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  -- Create buffer.
  local buf = vim.api.nvim_create_buf(false, true)
  set_buf_options(buf)
  state.buf = buf

  -- Open side panel on the right.
  local width = panel_width()
  vim.cmd("botright " .. width .. "vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  set_win_options(win)
  state.win        = win
  state.full_window = false

  attach_keymaps(buf)

  -- Trigger scan → render.
  M.refresh()
end

-- ── close ─────────────────────────────────────────────────────────────────

function M.close()
  if is_open() then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

-- ── toggle full/side ──────────────────────────────────────────────────────

function M.toggle_full()
  if not is_open() then return end

  if state.full_window then
    -- Shrink back to panel width.
    vim.api.nvim_win_set_width(state.win, panel_width())
    vim.api.nvim_set_option_value("winfixwidth", true, { win = state.win })
    state.full_window = false
  else
    -- Expand to full editor width.
    vim.api.nvim_win_set_width(state.win, vim.o.columns)
    vim.api.nvim_set_option_value("winfixwidth", false, { win = state.win })
    state.full_window = true
  end
  render()
end

return M
