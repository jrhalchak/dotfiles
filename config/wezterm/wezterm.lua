local wezterm = require 'wezterm'
local act = wezterm.action

-- test
local config = {
  front_end = "WebGpu", -- Render with Metal on macOS
  enable_kitty_graphics = true,
  window_background_opacity = 0.8,
  macos_window_background_blur = 50,
  allow_square_glyphs_to_overflow_width = 'Always',
  tab_bar_at_bottom = true,
  font_size = 11,
  font = wezterm.font_with_fallback({
    {
      family = "VictorMono Nerd Font Mono",
      weight = "Medium",
    },
    {
      -- Fallback font with all the Netd Font Symbols
      family = "Symbols Nerd Font Mono",
      scale = 0.9,
    },
  }),
  color_scheme = 'tokyonight',
  window_decorations = "RESIZE",
  hide_tab_bar_if_only_one_tab = true,
  keys = {
    -- Disable default keybindings for new tab, split, etc.
    {key="t", mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="d", mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="Enter", mods="ALT", action="DisableDefaultAssignment"},
    {key="\"", mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="%", mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    -- paste from the clipboard
    { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

    -- paste from the primary selection
    -- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' },
  },
  disable_default_key_bindings = true,
}

return config
