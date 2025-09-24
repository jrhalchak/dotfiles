local w = require "wezterm"

local status = require "status"

local tabs = require "tabs"
local keybinds = require "keybinds"
local constants = require "constants"

-- Allow working with both the current release and the nightly
local cfg = {}
if w.config_builder then
  cfg = w.config_builder()
end

-- ========================
-- Graphics / Term / Window
-- ========================
cfg.front_end = "WebGpu" -- Render with Metal on macOS
cfg.enable_kitty_graphics = true
cfg.window_decorations = "RESIZE"
cfg.window_frame = {
  font_size = 11.0,
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
cfg.window_background_opacity = 0.7
cfg.macos_window_background_blur = 60

cfg.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.4,
}

-- ========================
-- UI / Tab bar / right-bar
-- ========================
-- cfg.tab_bar_at_bottom = true
-- cfg.hide_tab_bar_if_only_one_tab = false

cfg.use_fancy_tab_bar = false

cfg.colors = {
  -- Same options available for all tabs
  tab_bar = constants.TAB_COLORS,
}

cfg.show_new_tab_button_in_tab_bar = false

w.on("format-tab-title", tabs.format_tab_title)
w.on("update-right-status", status.render)

-- ========================
-- Fonts
-- ========================
cfg.font_size = 11
cfg.font = w.font_with_fallback({
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

cfg.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
cfg.keys = keybinds.get_keybinds()
-- cfg.disable_default_key_bindings = true

return cfg
