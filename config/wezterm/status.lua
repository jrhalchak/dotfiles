local M = {}

local w = require "wezterm"

local weather = require "status/weather"
local cwd = require "status/cwd"
local clock = require "status/clock"
local battery = require "status/battery"

local utils = require "utils"

local constants = require "constants"

function M.render(window, pane)
  local colors = constants.STATUS.PALETTE
  local tab_bar_bg = constants.TAB_COLORS.background

  local window_width = utils.get_window_width(window)
  -- Collect all valid status cells first
  local status_cells = {}

  -- Helper function to safely add cells
  local function add_cell(content)
    if content and not (type(content) == "string" and content == "") then
      table.insert(status_cells, content)
    else
      w.log_info("Rejected empty for statusbar cell")
    end
  end

  -- Add clock only if window is wide enough (120+ columns)
  -- TODO : maybe base on window width instead of fixed column count?
  if window_width >= 120 then
    add_cell(clock.binary_clock())
  end

  local cwdcell = cwd.get_cwd_info(window, pane)
  if cwdcell then
    add_cell(cwdcell)
  end

  -- Add date info
  local day_of_week = utils.get_day_of_week()
  local iso_date = utils.get_iso_date()

  add_cell(day_of_week)
  add_cell(iso_date)

  -- Add battery info
  local battery_info = battery.get_battery_info()
  for _, b in ipairs(battery_info) do
    add_cell(b)
  end

  -- Add weather info (as a single formatted unit, not individual cells)
  local weather_section_index = #status_cells + 1
  local weather_fg = constants.STATUS.TEXT_FG
  if weather_section_index >= #colors - 1 then
    weather_fg = constants.TAB_COLORS.background
  end

  local weather_items = weather.get_weather_cached(weather_fg)
  if weather_items and #weather_items > 0 then
    -- Prepend default foreground color to weather items
    local weather_with_defaults = {
      utils.emit_segment(weather_fg)
    }
    for _, item in ipairs(weather_items) do
      table.insert(weather_with_defaults, item)
    end

    local formatted_weather = w.format(weather_with_defaults)
    add_cell(formatted_weather)
  end

  -- Now build the elements with proper dividers
  local elements = {}

  for i, cell in ipairs(status_cells) do
    local bg = colors[i] or colors[#colors]
    local fg = constants.STATUS.TEXT_FG

    -- Swap the background on the lightest colors
    if i >= #colors then
      fg = constants.TAB_COLORS.background
    end

    -- Add initial divider for first cell
    if i == 1 then
      table.insert(elements, utils.emit_segment(bg, true))
      table.insert(elements, utils.emit_segment(tab_bar_bg))
      table.insert(elements, constants.STATUS.BOLD_INTENSITY)
      table.insert(elements, { Text = constants.ICONS.INVERSE_RIGHT_ANGLE_DIVIDER .. " " })
    end

    -- Add the cell content
    if type(cell) == "table" and cell.Text then
      table.insert(elements, utils.emit_segment(fg))
      table.insert(elements, utils.emit_segment(bg, true))
      table.insert(elements, constants.STATUS.BOLD_INTENSITY)
      table.insert(elements, cell)
    elseif type(cell) == "table" then
      table.insert(elements, utils.emit_segment(bg, true))
      table.insert(elements, constants.STATUS.BOLD_INTENSITY)
      table.insert(elements, cell)
    else
      -- For formatted strings (like weather), we need to prepend the section colors
      -- so that text without explicit colors gets the right foreground
      table.insert(elements, utils.emit_segment(fg))
      table.insert(elements, utils.emit_segment(bg, true))
      table.insert(elements, constants.STATUS.BOLD_INTENSITY)
      table.insert(elements, { Text = ' ' .. tostring(cell) .. ' ' })
    end

    -- Add divider between cells (but not after the last one)
    if i < #status_cells then
      local next_bg = colors[i+1] or colors[#colors]
      table.insert(elements, utils.emit_segment(bg)) -- current bg is foreground
      table.insert(elements, utils.emit_segment(next_bg, true))
      table.insert(elements, constants.STATUS.BOLD_INTENSITY)
      table.insert(elements, { Text = constants.ICONS.INVERSE_RIGHT_ANGLE_DIVIDER })
    end
  end

  window:set_right_status(w.format(elements))
end

return M