local M = {}

local w = require "wezterm"

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

return M