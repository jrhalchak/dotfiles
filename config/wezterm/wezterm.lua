local w = require 'wezterm'
local act = w.action

local weather = require 'weather'

-- Allow working with both the current release and the nightly
local cfg = {}
if w.config_builder then
  cfg = w.config_builder()
end

-- Debug Helper
local function inspect(val, depth)
  depth = depth or 0
  if type(val) ~= "table" then
    return tostring(val)
  end
  local indent = string.rep("  ", depth)
  local s = "{\n"
  for k, v in pairs(val) do
    s = s .. indent .. "  [" .. inspect(k) .. "] = " .. inspect(v, depth + 1) .. ",\n"
  end
  return s .. indent .. "}"
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

cfg.show_new_tab_button_in_tab_bar = false

w.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local is_active = tab.is_active
  local is_first = tabs[1].tab_id == tab.tab_id
  local prefix = is_first and " " or ""

  local RIGHT_BOTTOM_TRIANGLE = w.nerdfonts.ple_lower_right_triangle
  local LEFT_TOP_TRIANGLE = w.nerdfonts.ple_upper_left_triangle

  local edge_bg = "#0b0022"
  local active_fg = "#2b2042"
  local inactive_fg = "#1b1032"
  -- local active_bg = edge_bg
  -- local inactive_bg = edge_bg

  local left_arrow = {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = is_active and active_fg or inactive_fg } },
    { Text = prefix .. RIGHT_BOTTOM_TRIANGLE },
  }

  local title = {
    { Background = { Color = is_active and active_fg or inactive_fg } },
    { Foreground = { Color = "#c0c0c0" } },
    { Text = " " .. tabtitle(tab) .. " " },
  }

  local right_arrow = {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = is_active and active_fg or inactive_fg } },
    { Text = LEFT_TOP_TRIANGLE },
  }

  w.log_info(inspect(tab))

  return w.format(left_arrow) .. w.format(title) .. w.format(right_arrow)
end)

w.on('update-right-status', function(window, pane)
  local function binary_clock()
    local hour = tonumber(os.date("%H"))
    local min = tonumber(os.date("%M"))
    local sec = tonumber(os.date("%S"))
    local function to_bin(val)
      local bin = ""
      for i = 5, 0, -1 do
        bin = bin .. ((val & (1 << i)) ~= 0 and "󰄮 " or "󰢤 ")
      end
      return bin
    end
    return to_bin(hour) .. "  " .. to_bin(min) .. "  " .. to_bin(sec)
  end

  local INVERSE_RIGHT_ANGLE_DIVIDER = w.nerdfonts.pl_left_hard_divider

  local colors = {
    "#2e1850",
    "#4a2072",
    "#5c3886",
    "#6e4290",
    "#7c5295",
    -- "#9a72b0",
    "#b491c8",
  }
  local text_fg = "#c0c0c0"
  local tab_bar_bg = cfg.colors.tab_bar.background

  -- Collect all valid status cells first
  local status_cells = {}

  -- Helper function to safely add cells
  local function add_cell(content)
    if content and not (type(content) == "string" and content == "") then
      w.log_info("Adding cell #" .. (#status_cells + 1) .. ": " .. (type(content) == "table" and (content.Text or "table") or tostring(content)))
      table.insert(status_cells, content)
    else
      w.log_info("Rejected empty cell")
    end
  end

  -- Add clock
  add_cell(binary_clock())

  -- Add working directory and hostname
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = ''
    local hostname = ''
    if type(cwd_uri) == 'userdata' then
      cwd = cwd_uri.file_path or ""
      hostname = cwd_uri.host or w.hostname() or ""
    else
      cwd_uri = cwd_uri:sub(8)
      local slash = cwd_uri:find '/'
      if slash then
        hostname = cwd_uri:sub(1, slash - 1)
        cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
          return string.char(tonumber(hex, 16))
        end)
      end
    end
    local dot = hostname:find '[.]'
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    if hostname == '' then
      hostname = w.hostname() or ""
    end

    -- Replace home directory with ~
    local home = os.getenv("HOME")
    if home and cwd:sub(1, #home) == home then
      cwd = "~" .. cwd:sub(#home + 1)
    end

    add_cell(cwd)
    
    -- Only add hostname cell if it's remote
    local local_hostname = w.hostname() or ""
    if hostname and hostname ~= "" and hostname ~= local_hostname then
      add_cell(hostname)
    end
  end

  -- Add date info
  local day_of_week = w.strftime('%a')
  if day_of_week and day_of_week ~= "" then
    add_cell(tostring(w.nerdfonts.md_calendar_today) .. " " .. day_of_week)
  end
  
  local iso_date = w.strftime('%Y-%m-%d')
  if iso_date and iso_date ~= "" then
    add_cell(tostring(w.nerdfonts.md_calendar_month) .. " " .. iso_date)
  end

  -- Add battery info
  local function get_battery_icon(percent)
    if percent >= 95 then
      return w.nerdfonts.fa_battery_full
    elseif percent >= 75 then
      return w.nerdfonts.fa_battery_three_quarters
    elseif percent >= 50 then
      return w.nerdfonts.fa_battery_half
    elseif percent >= 25 then
      return w.nerdfonts.fa_battery_quarter
    else
      return w.nerdfonts.fa_battery_empty
    end
  end

  for _, b in ipairs(w.battery_info()) do
    local percent_val = b.state_of_charge and (b.state_of_charge * 100) or nil
    local percent_str = percent_val and string.format('%.0f%%', percent_val) or ""
    local icon = percent_val and get_battery_icon(percent_val) or w.nerdfonts.fa_battery_empty
    local battery_cell = percent_str ~= "" and (tostring(icon) .. " " .. percent_str) or nil
    add_cell(battery_cell)
  end

  -- Add weather info (as a single formatted unit, not individual cells)
  local weather_section_index = #status_cells + 1
  local weather_fg = text_fg
  if weather_section_index >= #colors - 1 then
    weather_fg = tab_bar_bg
  end
  
  local weather_items = weather.get_weather_cached(weather_fg)
  w.log_info("Weather returned " .. #weather_items .. " items")
  if weather_items and #weather_items > 0 then
    -- Prepend default foreground color to weather items
    local weather_with_defaults = {
      { Foreground = { Color = weather_fg } }
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
    local fg = text_fg

    -- Swap the background on the lightest colors
    if i >= #colors then
      fg = tab_bar_bg
    end

    -- Add initial divider for first cell
    if i == 1 then
      table.insert(elements, { Background = { Color = bg } })
      table.insert(elements, { Foreground = { Color = tab_bar_bg } })
      table.insert(elements, { Attribute = { Intensity = "Bold" } })
      table.insert(elements, { Text = INVERSE_RIGHT_ANGLE_DIVIDER .. " " })
    end

    -- Add the cell content
    if type(cell) == "table" and cell.Text then
      table.insert(elements, { Foreground = { Color = fg } })
      table.insert(elements, { Background = { Color = bg } })
      table.insert(elements, { Attribute = { Intensity = "Bold" } })
      table.insert(elements, cell)
    elseif type(cell) == "table" then
      table.insert(elements, { Background = { Color = bg } })
      table.insert(elements, { Attribute = { Intensity = "Bold" } })
      table.insert(elements, cell)
    else
      -- For formatted strings (like weather), we need to prepend the section colors
      -- so that text without explicit colors gets the right foreground
      table.insert(elements, { Foreground = { Color = fg } })
      table.insert(elements, { Background = { Color = bg } })
      table.insert(elements, { Attribute = { Intensity = "Bold" } })
      table.insert(elements, { Text = ' ' .. tostring(cell) .. ' ' })
    end

    -- Add divider between cells (but not after the last one)
    if i < #status_cells then
      local next_bg = colors[i+1] or colors[#colors]
      table.insert(elements, { Foreground = { Color = bg } })
      table.insert(elements, { Background = { Color = next_bg } })
      table.insert(elements, { Attribute = { Intensity = "Bold" } })
      table.insert(elements, { Text = INVERSE_RIGHT_ANGLE_DIVIDER })
    end
  end

  -- Remove any malformed FormatItems (empty tables or tables with more than one key)
  local valid_elements = {}
  for _, item in ipairs(elements) do
    print(item)
    if type(item) == "table" then
      local count = 0
      for _ in pairs(item) do print(_) count = count + 1 end
      if count == 1 then
        table.insert(valid_elements, item)
      end
    end
  end

  window:set_right_status(w.format(valid_elements))
end)
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
    key = "t",
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
