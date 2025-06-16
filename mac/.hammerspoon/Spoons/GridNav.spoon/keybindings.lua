--- Keybinding module for GridNav
-- Manages keyboard shortcuts for grid navigation
-- @module GridNav.keybindings

local M = {}
local logic = require("logic")

--- Helper for conditional binding with/without alerts
-- @param spoon The GridNav spoon instance
-- @param modifiers Table of key modifiers
-- @param key String key to bind
-- @param message Alert message to display (if showModalAlert is true)
-- @param pressedfn Function to call when key is pressed
-- @param releasedfn Function to call when key is released (optional)
-- @param repeatfn Function to call when key repeats (optional)
-- @return nil
local function cbind(spoon, modifiers, key, message, pressedfn, releasedfn, repeatfn)
  if not spoon or not spoon.state or not spoon.state.gridNavModal then
    hs.logger.new('GridNav'):e('Invalid spoon state in cbind')
    return
  end

  if not key or type(pressedfn) ~= "function" then
    hs.logger.new('GridNav'):e('Invalid parameters in cbind')
    return
  end

  if spoon.config.showModalAlert then
    spoon.state.gridNavModal:bind(modifiers, key, message, pressedfn, releasedfn, repeatfn)
  else
    spoon.state.gridNavModal:bind(modifiers, key, pressedfn, releasedfn, repeatfn)
  end
end

--- Setup all keybindings
-- Initializes all keyboard shortcuts for the grid navigation
-- @param spoon The GridNav spoon instance
-- @return nil
function M.setup(spoon)
  -- Basic navigation
  cbind(spoon, {}, "escape", "Exit GridNav", function()
    logic.exitGridNavMode(spoon)
  end)

  local keys = spoon.config.keys or {}

  -- Extract key definitions with defaults
  local halveLeftKey = keys.halveLeft or "h"
  local halveRightKey = keys.halveRight or "l"
  local halveUpKey = keys.halveUp or "k"
  local halveDownKey = keys.halveDown or "j"

  local moveLeftMods = keys.moveLeft and keys.moveLeft[1] or {"shift"}
  local moveLeftKey = keys.moveLeft and keys.moveLeft[2] or "h"
  local moveRightMods = keys.moveRight and keys.moveRight[1] or {"shift"}
  local moveRightKey = keys.moveRight and keys.moveRight[2] or "l"
  local moveUpMods = keys.moveUp and keys.moveUp[1] or {"shift"}
  local moveUpKey = keys.moveUp and keys.moveUp[2] or "k"
  local moveDownMods = keys.moveDown and keys.moveDown[1] or {"shift"}
  local moveDownKey = keys.moveDown and keys.moveDown[2] or "j"

  local warpCursorKey = keys.warpCursor or "w"
  local leftClickKey = keys.leftClick or "space"
  local leftClickAltKey = keys.leftClickAlt or "return"
  local rightClickMods = keys.rightClick and keys.rightClick[1] or {"shift"}
  local rightClickKey = keys.rightClick and keys.rightClick[2] or "space"
  local rightClickAltMods = keys.rightClickAlt and keys.rightClickAlt[1] or {"shift"}
  local rightClickAltKey = keys.rightClickAlt and keys.rightClickAlt[2] or "return"

  local resizeToWindowKey = keys.resizeToWindow or "t"
  local centerAroundCursorKey = keys.centerAroundCursor or "c"

  -- Direction keys
  cbind(spoon, {}, halveLeftKey, "Halve Left", function()
    logic.halveLeft(spoon)
  end)

  cbind(spoon, {}, halveRightKey, "Halve Right", function()
    logic.halveRight(spoon)
  end)

  cbind(spoon, {}, halveUpKey, "Halve Up", function()
    logic.halveUp(spoon)
  end)

  cbind(spoon, {}, halveDownKey, "Halve Down", function()
    logic.halveDown(spoon)
  end)

  -- Movement bindings
  cbind(spoon, moveLeftMods, moveLeftKey, "Move Left", function()
    logic.moveLeft(spoon)
  end)

  cbind(spoon, moveRightMods, moveRightKey, "Move Right", function()
    logic.moveRight(spoon)
  end)

  cbind(spoon, moveUpMods, moveUpKey, "Move Up", function()
    logic.moveUp(spoon)
  end)

  cbind(spoon, moveDownMods, moveDownKey, "Move Down", function()
    logic.moveDown(spoon)
  end)

  -- Mouse actions
  cbind(spoon, {}, warpCursorKey, "Warp Cursor", function()
    logic.warpCursor(spoon)
  end)

  cbind(spoon, {}, leftClickKey, "Left Click", function()
    logic.leftClick(spoon)
  end)

  cbind(spoon, {}, leftClickAltKey, "Left Click", function()
    logic.leftClick(spoon)
  end)

  cbind(spoon, rightClickMods, rightClickKey, "Right Click", function()
    logic.rightClick(spoon)
  end)

  cbind(spoon, rightClickAltMods, rightClickAltKey, "Right Click", function()
    logic.rightClick(spoon)
  end)

  -- Special functions
  cbind(spoon, {}, resizeToWindowKey, "Resize to Window", function()
    logic.resizeToWindow(spoon)
  end)

  cbind(spoon, {}, centerAroundCursorKey, "Center Around Cursor", function()
    logic.centerAroundCursor(spoon)
  end)

  -- Special functions
  cbind(spoon, {}, resizeToWindowKey, "Resize to Window", function()
    logic.resizeToWindow(spoon)
  end)

  cbind(spoon, {}, centerAroundCursorKey, "Center Around Cursor", function()
    logic.centerAroundCursor(spoon)
  end)

  -- Scroll commands with configurable bindings
  local scrollEnabled = keys.scrollEnabled ~= false -- Default to true if not specified

  if scrollEnabled then
    -- Extract scroll key configurations with defaults
    local scrollDownMods = keys.scrollDown and keys.scrollDown[1] and keys.scrollDown[1] or {"cmd", "shift"}
    local scrollDownKey = keys.scrollDown and keys.scrollDown[2] and keys.scrollDown[2] or "j"

    local scrollUpMods = keys.scrollUp and keys.scrollUp[1] and keys.scrollUp[1] or {"cmd", "shift"}
    local scrollUpKey = keys.scrollUp and keys.scrollUp[2] and keys.scrollUp[2] or "k"

    local scrollLeftMods = keys.scrollLeft and keys.scrollLeft[1] and keys.scrollLeft[1] or {"cmd", "shift"}
    local scrollLeftKey = keys.scrollLeft and keys.scrollLeft[2] and keys.scrollLeft[2] or "h"

    local scrollRightMods = keys.scrollRight and keys.scrollRight[1] and keys.scrollRight[1] or {"cmd", "shift"}
    local scrollRightKey = keys.scrollRight and keys.scrollRight[2] and keys.scrollRight[2] or "l"

    -- Bind scroll commands
    cbind(spoon, scrollDownMods, scrollDownKey, "Scroll Down", function()
      logic.scrollDown()
    end)

    cbind(spoon, scrollUpMods, scrollUpKey, "Scroll Up", function()
      logic.scrollUp()
    end)

    cbind(spoon, scrollLeftMods, scrollLeftKey, "Scroll Left", function()
      logic.scrollLeft()
    end)

    cbind(spoon, scrollRightMods, scrollRightKey, "Scroll Right", function()
      logic.scrollRight()
    end)
  end
end

return M
