--- Configuration module for GridNav
-- Provides default values and config management functions
-- @module GridNav.config

local M = {}

--- Default configuration values
-- @field gridLineColor Color table for grid lines (RGBA values from 0-1)
-- @field gridBorderColor Color table for grid border (RGBA values from 0-1)
-- @field gridLineWidth Width of grid lines in pixels
-- @field gridBorderWidth Width of grid border in pixels
-- @field showMidpoint Boolean to toggle midpoint visibility
-- @field midpointSize Size of midpoint indicator in pixels
-- @field midpointShape Shape of midpoint indicator ("square" or "circle")
-- @field midpointFillColor Color table for midpoint fill (RGBA values from 0-1)
-- @field midpointStrokeColor Color table for midpoint stroke (RGBA values from 0-1)
-- @field midpointStrokeWidth Width of midpoint stroke in pixels
-- @field dimBackground Boolean to toggle background dimming
-- @field dimColor Color table for background dim (RGBA values from 0-1)
-- @field mainModifiers Table of modifiers for main hotkey
-- @field mainKey Key for main hotkey
-- @field showModalAlert Boolean to toggle modal alert messages
-- @field rightClickExitsGrid Boolean to close overlay on right click
M.defaults = {
  gridLineColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7},
  gridBorderColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7},
  gridLineWidth = 1,
  gridBorderWidth = 3,
  radius = 12,
  decorateCorners = true,
  showMidpoint = true,
  midpointSize = 10,
  midpointShape = "circle", -- "square" or "circle"
  midpointFillColor = {red = 1, green = 1, blue = 1, alpha = 0.2},
  midpointStrokeColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7},
  midpointStrokeWidth = 0,
  dimBackground = true,
  dimColor = {red = 0, green = 0, blue = 0, alpha = 0.3},
  mainModifiers = {"cmd"},
  mainKey = ";",
  showModalAlert = false,
  rightClickExitsGrid = false,  -- When false, right-click keeps the grid active

  -- Add default key mappings
  keys = {
    -- Grid division
    halveLeft = "h",
    halveRight = "l",
    halveUp = "k",
    halveDown = "j",

    -- Grid movement
    moveLeft = {"shift", "h"},
    moveRight = {"shift", "l"},
    moveUp = {"shift", "k"},
    moveDown = {"shift", "j"},

    -- Mouse actions
    warpCursor = "w",
    leftClick = "space",
    leftClickAlt = "return",
    rightClick = {"shift", "space"},
    rightClickAlt = {"shift", "return"},

    -- Special functions
    resizeToWindow = "t",
    centerAroundCursor = "c",

    -- Scroll actions (can be set to false to disable)
    scrollEnabled = true,
    scrollDown = {"cmd", "shift", "j"},
    scrollUp = {"cmd", "shift", "k"},
    scrollLeft = {"cmd", "shift", "h"},
    scrollRight = {"cmd", "shift", "l"}
  }
}

--- Update configuration with user values
-- @param spoon The GridNav spoon instance
-- @param userConfig Table containing user configuration values
function M.update(spoon, userConfig)
  -- Add validation
  if not spoon or not spoon.config then
    hs.logger.new('GridNav'):e('Invalid spoon in config.update')
    return
  end

  if type(userConfig) ~= "table" then
    hs.logger.new('GridNav'):e('userConfig must be a table')
    return
  end

  -- Extend the defaults with user config values
  for key, value in pairs(userConfig) do
    if key == "keys" and type(value) == "table" then
      -- Special handling for keys table - merge instead of replace
      spoon.config.keys = spoon.config.keys or {}
      for k, v in pairs(value) do
        spoon.config.keys[k] = v
      end
    elseif spoon.config[key] ~= nil then
      spoon.config[key] = value
    end
  end
end

--- Get a copy of the current config
-- @param spoon The GridNav spoon instance
-- @return table Copy of current configuration
function M.get(spoon)
  local configCopy = {}
  for k, v in pairs(spoon.config) do
    configCopy[k] = v
  end
  return configCopy
end

return M
