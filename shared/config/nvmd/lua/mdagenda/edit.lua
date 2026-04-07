-- mdagenda/edit.lua
-- Pure buffer-editing helpers for checkbox lines.
-- No UI state, no agenda panel dependencies.
-- All functions operate on the current line under the cursor.

local M = {}

-- Returns the checkbox state character if the line is a checkbox line,
-- nil otherwise. Recognises: [ ] [/] [!] [x] [-]
function M.checkbox_char(line)
  return line:match("^(%s*%- %[)([ /!x%-])(%])")
    and line:match("^%s*%- %[([ /!x%-])%]")
end

local function warn(msg)
  vim.notify("mdagenda: " .. msg, vim.log.levels.WARN)
end

-- Set or replace the [due::...] tag on the current checkbox line.
-- date_str: "YYYY-MM-DD"
-- time_str: "HH:MM" or nil
function M.set_due(date_str, time_str)
  local line = vim.api.nvim_get_current_line()
  if not M.checkbox_char(line) then
    warn("cursor is not on a checkbox line")
    return
  end

  local tag
  if time_str and time_str ~= "" then
    tag = "[due::" .. date_str .. "T" .. time_str .. "]"
  else
    tag = "[due::" .. date_str .. "]"
  end

  local new_line
  if line:find("%[due::[^%]]*%]") then
    -- Replace existing tag.
    new_line = line:gsub("%[due::[^%]]*%]", tag, 1)
  else
    -- Append before end of line, separated by a space.
    new_line = line:gsub("%s*$", " " .. tag)
  end

  vim.api.nvim_set_current_line(new_line)
end

-- Cycle [priority::...] on the current checkbox line.
-- Cycle order: none → high → medium → low → none
function M.cycle_priority()
  local line = vim.api.nvim_get_current_line()
  if not M.checkbox_char(line) then
    warn("cursor is not on a checkbox line")
    return
  end

  local current = line:match("%[priority::([^%]]+)%]")

  local new_line
  if not current then
    -- No tag: append high.
    new_line = line:gsub("%s*$", " [priority::high]")
  elseif current == "high" then
    new_line = line:gsub("%[priority::[^%]]*%]", "[priority::medium]", 1)
  elseif current == "medium" then
    new_line = line:gsub("%[priority::[^%]]*%]", "[priority::low]", 1)
  else
    -- low → remove tag entirely, clean up any leading space before the tag.
    new_line = line:gsub("%s*%[priority::[^%]]*%]", "", 1)
  end

  vim.api.nvim_set_current_line(new_line)
end

return M
