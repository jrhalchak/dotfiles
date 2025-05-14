local wezterm = require 'wezterm'

-- test
local config = {
  front_end = "WebGpu", -- Render with Metal on macOS
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
}

return config
