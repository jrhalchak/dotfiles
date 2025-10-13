local M = {}

local w = require "wezterm"

-- Tracking
local is_focused = true

w.on('window-focused-change', function(window)
  is_focused = window:is_focused()
end)

---
-- Check whether the window is focused for conditional functionality
---@return boolean: Whether the window is focused
function M.is_focused()
  return is_focused
end

---
-- Recursively inspects a Lua value, returning a string representation.
-- Useful for debugging tables and nested structures.
---@param val table: The value to inspect.
---@param depth number?: (optional) Current recursion depth.
---@return string: String representation of the value.
function M.inspect(val, depth)
  depth = depth or 0
  if type(val) ~= "table" then
    return tostring(val)
  end
  local indent = string.rep("  ", depth)
  local s = "{\n"
  for k, v in pairs(val) do
    s = s .. indent .. "  [" .. M.inspect(k) .. "] = " .. M.inspect(v, depth + 1) .. ",\n"
  end
  return s .. indent .. "}"
end

---
-- Returns the tab title if set, otherwise falls back to the active pane's title.
---@param tab table: The wezterm tab object.
---@return string: The tab or pane title.
function M.tab_title(tab)
  local title = tab.tab_title

  if title and #title > 0 then
    return title
  end

  return tab.active_pane.title
end

---
-- Returns a wezterm format item for foreground or background color.
---@param color string: The color value (hex or named).
---@param isbg boolean: If true, returns background; otherwise foreground.
---@return table: Wezterm format item for color.
function M.emit_segment(color, isbg)
  if isbg then
    return { Background = { Color = color } }
  else
    return { Foreground = { Color = color } }
  end
end

---
-- Gets the current window width in columns.
---@param window table: The wezterm window object.
---@return number: The window width in columns.
function M.get_window_width(window)
  -- Get window dimensions for responsive behavior
  local tab = window:active_tab()
  local window_dims = tab:get_size()
  local window_width = window_dims.cols

  return window_width
end

---
-- Returns the current day of the week, prefixed with a calendar icon.
---@return string: Icon and abbreviated day name.
function M.get_day_of_week()
  return tostring(w.nerdfonts.md_calendar_today) .. " " .. w.strftime('%a')
end

---
-- Returns the current date in ISO format, prefixed with a calendar icon.
---@return string: Icon and date string (YYYY-MM-DD).
function M.get_iso_date()
  return tostring(w.nerdfonts.md_calendar_month) .. " " .. w.strftime('%Y-%m-%d')
end

-- Determines if the current pane is running Neovim, based on user vars from the smart-splits.nvim plugin.
-- USE IF YOU ARE *NOT* lazy-loading smart-splits.nvim (recommended)
---@param pane table: The wezterm pane object.
---@return boolean: True if Neovim is detected, false otherwise.
function M.is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'

-- If you *ARE* lazy-loading smart-splits.nvim (not recommended)
-- you have to use this instead, but note that this will not work
-- in all cases (e.g. over an SSH connection). Also note that
-- `pane:get_foreground_process_name()` can have high and highly variable
-- latency, so the other implementation of `is_vim()` will be more
-- performant as well.
-- local function is_vim(pane)
  -- This gsub is equivalent to POSIX basename(3)
  -- Given "/foo/bar" returns "bar"
  -- Given "c:\\foo\\bar" returns "bar"
  -- local process_name = string.gsub(pane:get_foreground_process_name(), '(.*[/\\])(.*)', '%2')
  -- return process_name == 'nvim' or process_name == 'vim'
-- end
end

------------------------------------------------------------
-- Async Task Utilities
------------------------------------------------------------
-- Generic, reusable, non-blocking periodic async command runner.
-- Designed so status renderers can access cached data instantly
-- without performing IO or network work on the hot path.
--
-- Implementation strategy:
--  * Spawn background process with wezterm.background_child_process
--  * Redirect its stdout to a temp file
--  * Poll that file cheaply with call_after until content arrives or timeout
--  * Process and cache the result; schedule next run
--
-- Usage example:
-- utils.periodic_async('weather', {
--   interval = 1800, -- seconds
--   spawn = function(tmp)
--     return 'curl -s --max-time 3 "wttr.in/AKC?format=%C++%t++%f++%w" > ' .. string.format('%q', tmp)
--   end,
--   process = function(raw)
--     raw = raw and raw:gsub('^%s*(.-)%s*$', '%1') or ''
--     if raw == '' or raw:match('<html') then return nil end
--     return raw
--   end,
--   skip_when_unfocused = true,
-- })

local async_tasks = {}

--- Start (once) a periodic asynchronous background fetch.
--- Subsequent calls with the same name are ignored.
---@param name string Unique task name
---@param opts table Options
--  opts.interval (number) seconds between successful runs (default 60)
--  opts.spawn (fun(tmpfile:string):string|table) command string (shell) or argv table (no shell) MUST write to tmpfile
--  opts.process (fun(raw:string):any) optional transform; return nil to discard
--  opts.timeout (number) max seconds to wait for file (default 5)
--  opts.poll_interval (number) (default 0.25)
--  opts.initial any initial cached value
--  opts.skip_when_unfocused boolean skip fetch cycle if window unfocused
function M.periodic_async(name, opts)
  if async_tasks[name] then return end
  opts = opts or {}
  local interval = opts.interval or 60
  local timeout = opts.timeout or 5
  local poll_interval = opts.poll_interval or 0.25
  local tmpfile = (os.getenv('TMPDIR') or '/tmp') .. '/wezterm_async_' .. name .. '.txt'

  async_tasks[name] = {
    value = opts.initial,
    last_update = 0,
    tmpfile = tmpfile,
    fetching = false,
  }

  local function schedule_next()
    if async_tasks[name] then
      w.time.call_after(interval, function()
        if async_tasks[name] then
          async_tasks[name].fetching = false -- ensure state reset
          async_tasks[name].last_error = nil
          -- trigger next fetch
          async_tasks[name]._fetch()
        end
      end)
    end
  end

  local function poll_file(start_time)
    local state = async_tasks[name]
    if not state then return end
    local f = io.open(tmpfile, 'r')
    local data = nil
    if f then
      data = f:read('*a')
      f:close()
    end
    if data and #data > 0 then
      local processed = opts.process and opts.process(data) or data
      if processed ~= nil then
        state.value = processed
        state.last_update = os.time()
      end
      state.fetching = false
      schedule_next()
      return
    end
    if os.difftime(os.time(), start_time) >= timeout then
      state.fetching = false
      state.last_error = 'timeout'
      schedule_next()
      return
    end
    w.time.call_after(poll_interval, function() poll_file(start_time) end)
  end

  local function fetch()
    local state = async_tasks[name]
    if not state or state.fetching then return end
    if opts.skip_when_unfocused and not M.is_focused() then
      -- Try again later without doing work
      w.time.call_after(interval, fetch)
      return
    end
    state.fetching = true
    os.remove(tmpfile) -- remove stale file
    local cmd = opts.spawn(tmpfile)
    local ok, err
    if type(cmd) == 'string' then
      ok, err = pcall(function()
        w.background_child_process({ 'bash', '-lc', cmd })
      end)
    elseif type(cmd) == 'table' then
      -- Ensure the command itself handles redirection to tmpfile
      ok, err = pcall(function()
        w.background_child_process(cmd)
      end)
    else
      state.fetching = false
      state.last_error = 'invalid spawn return'
      schedule_next()
      return
    end
    if not ok then
      state.fetching = false
      state.last_error = tostring(err)
      schedule_next()
      return
    end
    poll_file(os.time())
  end

  async_tasks[name]._fetch = fetch
  -- Kick off initial fetch shortly after startup so it doesn't block init
  w.time.call_after(0.1, fetch)
end

--- Retrieve cached value for an async task.
---@param name string
---@return any value, number last_update
function M.get_async(name)
  local t = async_tasks[name]
  if t then return t.value, t.last_update end
  return nil, 0
end

--- Whether a named async task is currently fetching.
function M.async_fetching(name)
  local t = async_tasks[name]
  return t and t.fetching or false
end

--- Simple spinner utility (unicode braille) for placeholder cells.
local spinner_frames = { '⠋','⠙','⠚','⠞','⠖','⠦','⠴','⠲','⠳','⠓' }
function M.spinner()
  local now = os.time()
  local idx = (now % #spinner_frames) + 1
  return spinner_frames[idx]
end

return M
