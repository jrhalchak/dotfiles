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
  tab_bar = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = '#0b0022',

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = '#2b2042',
      -- The color of the text for the tab
      fg_color = '#c0c0c0',

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = 'Normal',

      -- Specify whether you want "None", "Single" or "Double" underline for
      -- label shown for this tab.
      -- The default is "None"
      underline = 'None',

      -- Specify whether you want the text to be italic (true) or not (false)
      -- for this tab.  The default is false.
      italic = false,

      -- Specify whether you want the text to be rendered with strikethrough (true)
      -- or not for this tab.  The default is false.
      strikethrough = false,
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab_hover`.
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab_hover`.
    },
  },
}

local function tabtitle(tab)
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end

  return tab.active_pane.title
end

w.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local is_active = tab.is_active
  local SOLID_LEFT_ARROW = w.nerdfonts.pl_right_hard_divider
  local SOLID_RIGHT_ARROW = w.nerdfonts.pl_left_hard_divider

  local edge_bg = "#0b0022"
  local active_fg = "#2b2042"
  local inactive_fg = "#1b1032"
  local active_bg = edge_bg
  local inactive_bg = edge_bg

  local left_arrow = {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = is_active and active_fg or inactive_fg } },
    { Text = SOLID_LEFT_ARROW },
  }

  local title = {
    { Background = { Color = is_active and active_fg or inactive_fg } },
    { Foreground = { Color = "#c0c0c0" } },
    { Text = " " .. tabtitle(tab) .. " " },
  }

  local right_arrow = {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = is_active and active_fg or inactive_fg } },
    { Text = SOLID_RIGHT_ARROW },
  }

  return w.format(left_arrow) .. w.format(title) .. w.format(right_arrow)
end)

w.on("update-right-status", function(window, pane)
	local cwd = " "..pane:get_current_working_dir():sub(8).." "; -- remove file:// uri prefix
	local date = w.strftime(" %I:%M %p  %A  %B %-d ");
	local hostname = " "..w.hostname().." ";

	window:set_right_status(
		w.format({
			{Foreground={Color="#ffffff"}},
			{Background={Color="#005f5f"}},
			{Text=cwd},
		})..
		w.format({
			{Foreground={Color="#00875f"}},
			{Background={Color="#005f5f"}},
			{Text=""},
		})..
		w.format({
			{Foreground={Color="#ffffff"}},
			{Background={Color="#00875f"}},
			{Text=date},
		})..
		w.format({
			{Foreground={Color="#00af87"}},
			{Background={Color="#00875f"}},
			{Text=""},
		})..
		w.format({
			{Foreground={Color="#ffffff"}},
			{Background={Color="#00af87"}},
			{Text=hostname},
		})
	);
end);

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
