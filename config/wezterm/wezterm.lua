local w = require 'wezterm'
local act = w.action

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
cfg.font_size = 10
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

-- ========================
-- Keybinds
-- ========================
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

-- if you *ARE* lazy-loading smart-splits.nvim (not recommended)
-- you have to use this instead, but note that this will not work
-- in all cases (e.g. over an SSH connection). Also note that
-- `pane:get_foreground_process_name()` can have high and highly variable
-- latency, so the other implementation of `is_vim()` will be more
-- performant as well.
local function is_vim(pane)
  -- This gsub is equivalent to POSIX basename(3)
  -- Given "/foo/bar" returns "bar"
  -- Given "c:\\foo\\bar" returns "bar"
  local process_name = string.gsub(pane:get_foreground_process_name(), '(.*[/\\])(.*)', '%2')
  return process_name == 'nvim' or process_name == 'vim'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = w.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

cfg.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
cfg.keys = {
  -- VI mode
  {
    key = "[",
    mods = "LEADER",
    action = act.ActivateCopyMode
  },

  -- move between split panes
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),

  -- resize panes
  split_nav('resize', 'h'),
  split_nav('resize', 'j'),
  split_nav('resize', 'k'),
  split_nav('resize', 'l'),

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
    action = act.ActivateTabRelative(-1),
    mods = "LEADER",
  },
  {
    key = "n",
    mods = "LEADER",
    action = act.ActivateTabRelative(1),
  }
}
-- cfg.disable_default_key_bindings = true

return cfg
