local w = require "wezterm"

local M = {
  ICONS = {
    INVERSE_RIGHT_ANGLE_DIVIDER = w.nerdfonts.pl_left_hard_divider,
    RIGHT_BOTTOM_TRIANGLE = w.nerdfonts.ple_lower_right_triangle,
    LEFT_TOP_TRIANGLE = w.nerdfonts.ple_upper_left_triangle,
  },
  STATUS = {
    PALETTE = {
      "#2e1850",
      "#4a2072",
      "#5c3886",
      "#6e4290",
      "#7c5295",
      -- "#9a72b0",
      "#b491c8",
    },
    TEXT_FG = "#c0c0c0",
    BOLD_INTENSITY = { Attribute = { Intensity = "Bold" } }
  },
  TAB_COLORS = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = '#0b0022',
    active_tab = {
      bg_color = '#2b2042',
      fg_color = '#c0c0c0',

      -- "Half", "Normal" or "Bold" intensity
      intensity = 'Normal', -- default = "Normal"

      -- "None", "Single" or "Double" underline
      underline = 'None', -- default = "None"
      italic = false, -- default = false.
      strikethrough = false, -- default = false.
    },
    inactive_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',
    },
    inactive_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,
    },
    new_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',
    },
    new_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,
    },
  },
}

M.TAB_BAR_BG = M.TAB_COLORS.background

return M