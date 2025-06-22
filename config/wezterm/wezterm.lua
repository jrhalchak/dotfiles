local wezterm = require 'wezterm'
local act = wezterm.action

-- Allow working with both the current release and the nightly
local cfg = {}
if wezterm.config_builder then
  cfg = wezterm.config_builder()
end

-- ========================
-- Graphics / Term / Window
-- ========================
cfg.front_end = "WebGpu" -- Render with Metal on macOS
cfg.enable_kitty_graphics = true
cfg.window_decorations = "RESIZE"
cfg.window_frame = {
  font_size = 13.0,
}
cfg.window_padding = {
    top = 10,
    bottom = 10,
    left = 10,
    right = 10,
}
cfg.term = "xterm-256color"

-- ========================
-- Visuals / Scheme
-- ========================
cfg.color_scheme = 'tokyonight'
cfg.window_background_opacity = 0.8
cfg.macos_window_background_blur = 50

-- ========================
-- UI
-- ========================
-- cfg.tab_bar_at_bottom = true
cfg.hide_tab_bar_if_only_one_tab = true

-- ========================
-- Fonts
-- ========================
cfg.font_size = 11
cfg.font = wezterm.font_with_fallback({
  {
    family = "VictorMono Nerd Font Mono",
    weight = "Medium",
  },
  {
    -- Fallback font with all the Netd Font Symbols
    family = "Symbols Nerd Font Mono",
    scale = 0.9,
  },
})
cfg.allow_square_glyphs_to_overflow_width = 'Always'

-- ========================
-- Keybinds
-- ========================
cfg.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
cfg.keys = {
  -- VI mode
  {
    key = "[",
    mods = "LEADER",
    action = act.ActivateCopyMode
  },

  -- Split Panes
  {
    key = "s",
    mods = "LEADER",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "v",
    mods = "LEADER",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },

  -- Pane Resizing
  {
    key = "LeftArrow",
    mods = "CTRL",
    action = act.AdjustPaneSize({ "Left", 5 }),
  },
  {
    key = "RightArrow",
    mods = "CTRL",
    action = act.AdjustPaneSize({ "Right", 5 }),
  },
  {
    key = "DownArrow",
    mods = "CTRL",
    action = act.AdjustPaneSize({ "Down", 5 }),
  },
  {
    key = "UpArrow",
    mods = "CTRL",
    action = act.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "m",
    mods = "LEADER",
    action = act.TogglePaneZoomState,
  },

  -- paste from the clipboard
  { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

  -- paste from the primary selection
  -- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' }

  -- Tabs
  {
    key = "c",
    mods = "LEADER",
    action = act.SpawnTab("CurrentPaneDomain"),
  },

  {
    key = "p",
    mods = "LEADER",
    action = act.ActivateTabRelative(-1),
  },
  {
    key = "n",
    mods = "LEADER",
    action = act.ActivateTabRelative(1),
  }
}
-- cfg.disable_default_key_bindings = true

return cfg
