-- calendar.lua: action dispatch for mattn/calendar-vim
--
-- Usage:
--   Set _G._calendar_mode = "date"         before :Calendar — insert date at cursor position
--   Set _G._calendar_mode = "journal"      before :Calendar — open/create journal entry
--   Set _G._calendar_mode = "due_date"     before :Calendar — set [due::YYYY-MM-DD] on checkbox line
--   Set _G._calendar_mode = "due_datetime" before :Calendar — set [due::YYYY-MM-DDThh:mm] on checkbox line
--
-- calendar-vim calls g:calendar_action(day, month, year, week, mode).
-- The vimscript bridge in plugins/markdown.lua routes that call here.

local M = {}

-- Zero-pad a number to at least 2 digits.
local function pad(n)
  return string.format("%02d", n)
end

-- Build an ISO date string from calendar-vim's integer args.
local function iso_date(day, month, year)
  return string.format("%d-%s-%s", year, pad(month), pad(day))
end

-- Insert a date string at the current cursor position in normal mode.
local function insert_date(date_str)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local new_line = line:sub(1, col) .. date_str .. line:sub(col + 1)
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  -- move cursor to end of inserted text
  vim.api.nvim_win_set_cursor(0, { row, col + #date_str })
end

-- Open or create a journal entry for the given date.
local function open_journal(date_str)
  require("config.notes").journal_for_date(date_str)
end

-- Entry point called from the vimscript bridge.
---@param day    integer
---@param month  integer
---@param year   integer
---@param week   integer   (unused)
---@param mode   string    (unused — calendar-vim horizontal/vertical mode)
function M.action(day, month, year, _week, _mode)
  local date_str = iso_date(day, month, year)
  local cal_mode = _G._calendar_mode or "date"

  -- close the calendar window before acting
  vim.cmd("quit")

  if cal_mode == "journal" then
    open_journal(date_str)
  elseif cal_mode == "due_date" then
    require("mdagenda.edit").set_due(date_str, nil)
  elseif cal_mode == "due_datetime" then
    vim.schedule(function()
      vim.ui.input({ prompt = "Time (HH:MM, blank to skip): " }, function(input)
        local time_str = nil
        if input and input:match("^%d%d:%d%d$") then
          time_str = input
        end
        require("mdagenda.edit").set_due(date_str, time_str)
      end)
    end)
  else
    insert_date(date_str)
  end
end

return M
