local M = {}
local drawing = require("drawing")

local minBufferPadding = 2

--- Update grid frame with bounds checking.
-- @param spoon The GridNav spoon instance
-- @param newFrame Table containing x, y, w, h values for the new frame
-- @return nil
function M.updateGridFrame(spoon, newFrame)
  -- Validate inputs
  if not spoon or not spoon.state then
    hs.logger.new('GridNav'):e('Invalid spoon state in updateGridFrame')
    return
  end

  if not newFrame or not newFrame.x or not newFrame.y or
     not newFrame.w or not newFrame.h then
    hs.logger.new('GridNav'):e('Invalid frame in updateGridFrame')
    return
  end

  local currentGridFrame = newFrame

  -- Get containing screen
  local centerPoint = hs.geometry.point(
    currentGridFrame.x + currentGridFrame.w/2,
    currentGridFrame.y + currentGridFrame.h/2
  )
  local containingScreen = hs.screen.find(centerPoint) or spoon.state.mainScreen
  local screenFrame = containingScreen:frame()

  -- Clamp to screen bounds
  currentGridFrame = hs.geometry.rect(currentGridFrame)
                      :toUnitRect(screenFrame)
                      :fromUnitRect(screenFrame)

  -- Minimum size check based on midpoint
  local minSize = spoon.config.midpointSize + minBufferPadding -- ~2.5px padding on each side
  if currentGridFrame.w < minSize then currentGridFrame.w = minSize end
  if currentGridFrame.h < minSize then currentGridFrame.h = minSize end

  spoon.state.currentGridFrame = currentGridFrame
  drawing.drawGrid(spoon)
end

--- Enter the grid navigation mode.
-- Initializes the grid to full screen and activates the modal
-- @param spoon The GridNav spoon instance
-- @return nil
function M.enterGridNavMode(spoon)
  local screenFrame = spoon.state.mainScreen:frame()
  spoon.state.isFullScreenGrid = true
  spoon.state.currentGridFrame = {
    x = screenFrame.x,
    y = screenFrame.y,
    w = screenFrame.w,
    h = screenFrame.h
  }

  spoon.state.gridNavModal:enter()
  drawing.drawGrid(spoon)
end

--- Exit the grid navigation mode.
-- Clears the gridlines and exists the grid modal
-- @param spoon The GridNav spoon instance
-- @return nil
function M.exitGridNavMode(spoon)
  drawing.clearGridDrawing(spoon)
  spoon.state.gridNavModal:exit()
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Grid operations
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- Cut the grid in half to the left w/ min-size and set isFullScreenGrid
-- @param spoon The GridNav spoon instance
-- @return nil
function M.halveLeft(spoon)
  local minSize = spoon.config.midpointSize + minBufferPadding
  if spoon.state.currentGridFrame.w <= minSize * 2 then return end

  local newFrame = {
    x = spoon.state.currentGridFrame.x,
    y = spoon.state.currentGridFrame.y,
    w = spoon.state.currentGridFrame.w / 2,
    h = spoon.state.currentGridFrame.h
  }
  spoon.state.isFullScreenGrid = false
  M.updateGridFrame(spoon, newFrame)
end

--- Cut the grid in half to the right w/ min-size and set isFullScreenGrid
-- @param spoon The GridNav spoon instance
-- @return nil
function M.halveRight(spoon)
  local minSize = spoon.config.midpointSize + minBufferPadding
  if spoon.state.currentGridFrame.w <= minSize * 2 then return end

  local newFrame = {
    x = spoon.state.currentGridFrame.x + spoon.state.currentGridFrame.w / 2,
    y = spoon.state.currentGridFrame.y,
    w = spoon.state.currentGridFrame.w / 2,
    h = spoon.state.currentGridFrame.h
  }
  spoon.state.isFullScreenGrid = false
  M.updateGridFrame(spoon, newFrame)
end

--- Cut the grid in half toward the top w/ min-size and set isFullScreenGrid
-- @param spoon The GridNav spoon instance
-- @return nil
function M.halveUp(spoon)
  local minSize = spoon.config.midpointSize + minBufferPadding
  if spoon.state.currentGridFrame.h <= minSize * 2 then return end

  local newFrame = {
    x = spoon.state.currentGridFrame.x,
    y = spoon.state.currentGridFrame.y,
    w = spoon.state.currentGridFrame.w,
    h = spoon.state.currentGridFrame.h / 2
  }
  spoon.state.isFullScreenGrid = false
  M.updateGridFrame(spoon, newFrame)
end

--- Cut the grid in half toward the bottom w/ min-size and set isFullScreenGrid
-- @param spoon The GridNav spoon instance
-- @return nil
function M.halveDown(spoon)
  local minSize = spoon.config.midpointSize + minBufferPadding
  if spoon.state.currentGridFrame.h <= minSize * 2 then return end

  local newFrame = {
    x = spoon.state.currentGridFrame.x,
    y = spoon.state.currentGridFrame.y + spoon.state.currentGridFrame.h / 2,
    w = spoon.state.currentGridFrame.w,
    h = spoon.state.currentGridFrame.h / 2
  }
  spoon.state.isFullScreenGrid = false
  M.updateGridFrame(spoon, newFrame)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Movement operations
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


--- Move the grid to the left, if not full screen, by half of it's current width
-- @param spoon The GridNav spoon instance
-- @return nil
function M.moveLeft(spoon)
  if spoon.state.isFullScreenGrid then return end
  local newFrame = {
    x = spoon.state.currentGridFrame.x - (spoon.state.currentGridFrame.w / 2),
    y = spoon.state.currentGridFrame.y,
    w = spoon.state.currentGridFrame.w,
    h = spoon.state.currentGridFrame.h
  }
  M.updateGridFrame(spoon, newFrame)
end

--- Move the grid to the right, if not full screen, by half of it's current width
-- @param spoon The GridNav spoon instance
-- @return nil
function M.moveRight(spoon)
  if spoon.state.isFullScreenGrid then return end
  local newFrame = {
    x = spoon.state.currentGridFrame.x + (spoon.state.currentGridFrame.w / 2),
    y = spoon.state.currentGridFrame.y,
    w = spoon.state.currentGridFrame.w,
    h = spoon.state.currentGridFrame.h
  }
  M.updateGridFrame(spoon, newFrame)
end

--- Move the grid up, if not full screen, by half of it's current width
-- @param spoon The GridNav spoon instance
-- @return nil
function M.moveUp(spoon)
  if spoon.state.isFullScreenGrid then return end
  local newFrame = {
    x = spoon.state.currentGridFrame.x,
    y = spoon.state.currentGridFrame.y - (spoon.state.currentGridFrame.h / 2),
    w = spoon.state.currentGridFrame.w,
    h = spoon.state.currentGridFrame.h
  }
  M.updateGridFrame(spoon, newFrame)
end

--- Move the grid down, if not full screen, by half of it's current width
-- @param spoon The GridNav spoon instance
-- @return nil
function M.moveDown(spoon)
  if spoon.state.isFullScreenGrid then return end
  local newFrame = {
    x = spoon.state.currentGridFrame.x,
    y = spoon.state.currentGridFrame.y + (spoon.state.currentGridFrame.h / 2),
    w = spoon.state.currentGridFrame.w,
    h = spoon.state.currentGridFrame.h
  }
  M.updateGridFrame(spoon, newFrame)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Mouse actions
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- "Warp" (move) the cursor to the center of the grid's current location
-- If grid is at minimum size near screen edge, position cursor at edge instead
-- @param spoon The GridNav spoon instance
-- @return nil
function M.warpCursor(spoon)
  local cf = spoon.state.currentGridFrame
  local targetX = cf.x + cf.w / 2
  local targetY = cf.y + cf.h / 2

  -- Screen edge detection
  local screen = hs.screen.find({x = targetX, y = targetY}) or spoon.state.mainScreen
  local screenFrame = screen:frame()
  local minSize = spoon.config.midpointSize + minBufferPadding

  -- Check if grid is at minimum size and near an edge
  if cf.w <= minSize then
    if math.abs(cf.x - screenFrame.x) < 10 then -- Near left edge
      targetX = screenFrame.x
    elseif math.abs((cf.x + cf.w) - (screenFrame.x + screenFrame.w)) < 10 then -- Near right edge
      targetX = screenFrame.x + screenFrame.w - 1
    end
  end

  if cf.h <= minSize then
    if math.abs(cf.y - screenFrame.y) < 10 then -- Near top edge
      targetY = screenFrame.y
    elseif math.abs((cf.y + cf.h) - (screenFrame.y + screenFrame.h)) < 10 then -- Near bottom edge
      targetY = screenFrame.y + screenFrame.h - 1
    end
  end

  -- Move the cursor to the target position
  hs.mouse.absolutePosition({x = targetX, y = targetY})
end

--- Left-click on the target in the center of the grid's current location
-- @param spoon The GridNav spoon instance
-- @return nil
function M.leftClick(spoon)
  local cf = spoon.state.currentGridFrame
  local targetX = cf.x + cf.w / 2
  local targetY = cf.y + cf.h / 2
  hs.eventtap.leftClick({x = targetX, y = targetY})
  M.exitGridNavMode(spoon)
end

--- Right-click on the target in the center of the grid's current location
-- @param spoon The GridNav spoon instance
-- @return nil
function M.rightClick(spoon)
  local cf = spoon.state.currentGridFrame
  local targetX = cf.x + cf.w / 2
  local targetY = cf.y + cf.h / 2
  hs.eventtap.rightClick({x = targetX, y = targetY})

  -- Only exit grid mode if configured to do so
  if spoon.config.rightClickExitsGrid then
    M.exitGridNavMode(spoon)
  else
    -- Wait a moment for menu to appear, then focus back on grid
    -- This helps with certain applications like the Hammerspoon console
    hs.timer.doAfter(0.1, function()
      -- Temporarily disable grid modal
      spoon.state.gridNavModal:exit()

      -- Re-enter after a tiny delay to regain focus
      hs.timer.doAfter(0.05, function()
        spoon.state.gridNavModal:enter()
      end)
    end)
  end
end


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Special grid functions
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- Resize and position the grid to fit around the currently-active window
-- @param spoon The GridNav spoon instance
-- @return nil
function M.resizeToWindow(spoon)
  local focusedWindow = hs.window.focusedWindow()
  if focusedWindow then
    local windowFrame = focusedWindow:frame()
    local newFrame = {
      x = windowFrame.x,
      y = windowFrame.y,
      w = windowFrame.w,
      h = windowFrame.h
    }
    spoon.state.isFullScreenGrid = false
    M.updateGridFrame(spoon, newFrame)
  end
end

--- Resize and position the grid to 200x200, placed with the center of the grid
-- directly over the cursor's current location
-- @param spoon The GridNav spoon instance
-- @return nil
function M.centerAroundCursor(spoon)
  local mousePos = hs.mouse.absolutePosition()
  local gridSize = 200
  local newFrame = {
    x = mousePos.x - gridSize/2,
    y = mousePos.y - gridSize/2,
    w = gridSize,
    h = gridSize
  }
  spoon.state.isFullScreenGrid = false
  M.updateGridFrame(spoon, newFrame)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Scroll functions
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- Send a scroll-wheel down signal for wherever the cursor is currently placed
-- @return nil
function M.scrollDown()
  hs.eventtap.scrollWheel({0, 3}, {}, "line")
end

--- Send a scroll-wheel up signal for wherever the cursor is currently placed
-- @return nil
function M.scrollUp()
  hs.eventtap.scrollWheel({0, -3}, {}, "line")
end

--- Send a scroll-wheel left signal for wherever the cursor is currently placed
-- @return nil
function M.scrollLeft()
  hs.eventtap.scrollWheel({-3, 0}, {}, "line")
end

--- Send a scroll-wheel right signal for wherever the cursor is currently placed
-- @return nil
function M.scrollRight()
  hs.eventtap.scrollWheel({3, 0}, {}, "line")
end

return M

