local M = {}

local utils = require "utils"
local constants = require "constants"
local w = require "wezterm"

function M.format_tab_title(tab, tabs, panes, config, hover, max_width)
  local is_active = tab.is_active
  local is_first = tabs[1].tab_id == tab.tab_id
  local prefix = is_first and " " or ""

  -- TODO : move this out and unify colors
  local edge_bg = "#0b0022"
  local active_fg = "#2b2042"
  local inactive_fg = "#1b1032"
  -- local active_bg = edge_bg
  -- local inactive_bg = edge_bg

  local left_arrow = {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = is_active and active_fg or inactive_fg } },
    { Text = prefix .. constants.ICONS.RIGHT_BOTTOM_TRIANGLE },
  }

  local title = {
    { Background = { Color = is_active and active_fg or inactive_fg } },
    { Foreground = { Color = "#c0c0c0" } },
    { Text = " " .. utils.tab_title(tab) .. " " },
  }

  local right_arrow = {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = is_active and active_fg or inactive_fg } },
    { Text = constants.ICONS.LEFT_TOP_TRIANGLE },
  }

  return w.format(left_arrow) .. w.format(title) .. w.format(right_arrow)
end

return M