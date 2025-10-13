local M = {}

local w = require "wezterm"

local utils = require "utils"

local act = w.action

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
      if utils.is_vim(pane) then
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

function M.get_keybinds()
  return {
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
end

return M