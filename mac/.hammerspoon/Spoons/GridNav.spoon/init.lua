--[[

░░      ░░░       ░░░        ░░       ░░░   ░░░  ░░░      ░░░  ░░░░  ░
▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒
▓  ▓▓▓   ▓▓       ▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓  ▓▓  ▓  ▓  ▓▓  ▓▓▓▓  ▓▓▓  ▓▓  ▓▓
█  ████  ██  ███  ██████  █████  ████  ██  ██    ██        ████    ███
██      ███  ████  ██        ██       ███  ███   ██  ████  █████  ████

]]--

--- GridNav Spoon for Hammerspoon.
-- Mouse grid navigation system inspired by the keynav app for X11
-- (https://github.com/jordansissel/keynav)
--
-- This spoon provides keyboard-driven mouse pointer control using
-- a grid that can be navigated and subdivided.
--
-- @module GridNav
-- @author Jonathan Halchak
-- @copyright 2025
-- @license MIT - https://opensource.org/licenses/MIT
-- @homepage https://github.com/jrhalchak/GridNav.spoon
-- @usage
-- ```lua
-- -- Basic usage with defaults
-- local gridNav = hs.loadSpoon("GridNav")
-- gridNav:start()
--
-- -- Advanced usage with custom configuration
-- local gridNav = hs.loadSpoon("GridNav")
--
-- -- Configure visual appearance
-- gridNav:configure({
--   gridLineColor = {red = 0.2, green = 0.8, blue = 0.2, alpha = 0.7},
--   midpointShape = "circle",
--   midpointSize = 15,
--   showModalAlert = true
-- })
--
-- -- Customize keybindings
-- gridNav:bindHotkeys({
--   activate = {{"cmd", "alt"}, "g"}, -- Change activation key
--   halveLeft = "a",                  -- Use WASD instead of HJKL
--   halveRight = "d",
--   halveUp = "w",
--   halveDown = "s",
--   scrollEnabled = false,            -- Disable scroll functionality
--   centerAroundCursor = "c"          -- Keep default key for this function
-- })
--
-- gridNav:start()
-- ```

-- Set up the package path to find the modules in this Spoon's directory
local spoonPath = debug.getinfo(1, "S").source:sub(2):match("(.*/)"):sub(1, -2)
if spoonPath:sub(-1) ~= "/" then spoonPath = spoonPath .. "/" end
package.path = spoonPath .. "?.lua;" .. package.path

-- Load all modules
local obj = {}
local config = require("config")
local logic = require("logic")
local keybindings = require("keybindings")

-- Set metadata
obj.name = "GridNav"
obj.version = "0.1"
obj.author = "Jonathan Halchak"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/jrhalchak/GridNav.spoon"

--- Initialize GridNav's initial state and configuration
-- @param userConfig Table containing configuration options
-- @return self
function obj:init(userConfig)
  -- Skip if already initialized
  if self._initialized then return self end

  -- Initialize shared state
  self.state = {
    currentGridFrame = {},
    gridCanvas = nil,
    isFullScreenGrid = true,
    mainScreen = hs.screen.mainScreen(),
    gridNavModal = hs.hotkey.modal.new()
  }

  -- Set up default config and apply any user overrides
  self.config = config.defaults
  if userConfig then
    config.update(self, userConfig)
  end

  self._initialized = true
  return self
end

--- Configure the GridNav spoon with user settings.
-- @param userConfig Table containing configuration options
-- @return self
function obj:configure(userConfig)
  if not userConfig or type(userConfig) ~= "table" then
    hs.logger.new('GridNav'):e('userConfig must be a table in configure()')
    return self
  end

  config.update(self, userConfig)
  return self
end

--- Get a copy of the current configuration.
-- @return table Current configuration settings
function obj:getConfig()
  return config.get(self)
end

function obj:bindHotkeys(mapping)
  if not mapping or type(mapping) ~= "table" then
    hs.logger.new('GridNav'):e('mapping must be a table in bindHotkeys()')
    return self
  end

  -- Main activation binding
  if mapping.activate then
    self.config.mainModifiers = mapping.activate[1]
    self.config.mainKey = mapping.activate[2]
  end

  -- Grid navigation keys
  local navKeys = {
    halveLeft = "h",
    halveRight = "l",
    halveUp = "k",
    halveDown = "j",
    moveLeft = {"shift", "h"},
    moveRight = {"shift", "l"},
    moveUp = {"shift", "k"},
    moveDown = {"shift", "j"},
    warpCursor = "w",
    leftClick = "space",
    leftClickAlt = "return",
    rightClick = {"shift", "space"},
    rightClickAlt = {"shift", "return"},
    resizeToWindow = "t",
    centerAroundCursor = "c"
  }

  -- Scroll keys
  local scrollKeys = {
    scrollEnabled = true,
    scrollDown = {"cmd", "shift", "j"},
    scrollUp = {"cmd", "shift", "k"},
    scrollLeft = {"cmd", "shift", "h"},
    scrollRight = {"cmd", "shift", "l"}
  }

  -- Update the keybinding configuration
  self.config.keys = self.config.keys or {}

  for action, defaultBinding in pairs(navKeys) do
    if mapping[action] then
      self.config.keys[action] = mapping[action]
    end
  end

  -- Handle scroll keys/enable separately
  if mapping.scrollEnabled ~= nil then
    self.config.keys.scrollEnabled = mapping.scrollEnabled
  end

  for action, defaultBinding in pairs(scrollKeys) do
    if mapping[action] then
      self.config.keys[action] = mapping[action]
    end
  end

  return self
end

--- Set up key bindings for grid navigation.
-- @return self
function obj:setupBindings()
  keybindings.setup(self)
end

--- Start GridNav and activate hotkeys.
-- Creates a fresh modal and binds the main activation hotkey
-- @return self
function obj:start()
  -- Call init if needed
  if not self._initialized then
    self:init()
  end

  -- Create fresh modal and bindings with current config
  self.state.gridNavModal = hs.hotkey.modal.new()
  self:setupBindings()

  -- Bind the main hotkey
  local mainBinding = function()
    if self.state.gridNavModal:entered() then
      logic.exitGridNavMode(self)
    else
      logic.enterGridNavMode(self)
    end
  end

  if self.config.showModalAlert then
    hs.hotkey.bind(self.config.mainModifiers, self.config.mainKey,
                  "Enter GridNav Mode", mainBinding)
  else
    hs.hotkey.bind(self.config.mainModifiers, self.config.mainKey, mainBinding)
  end

  return self
end

--- Stop GridNav and deactivate hotkeys.
-- Exits grid navigation mode and unbinds the main hotkey
-- @return self
function obj:stop()
  if self.state.gridNavModal:entered() then
    logic.exitGridNavMode(self)
  end
  hs.hotkey.unbind(self.config.mainModifiers, self.config.mainKey)
end

return obj

