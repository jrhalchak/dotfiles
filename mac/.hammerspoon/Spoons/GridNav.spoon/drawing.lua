--- Drawing module for GridNav
-- Handles rendering of the grid interface
-- @module GridNav.drawing

local M = {}

--- Clear any existing grid canvas
-- @param spoon The GridNav spoon instance
-- @return nil
function M.clearGridDrawing(spoon)
  if spoon.state.gridCanvas then
    spoon.state.gridCanvas:delete()
    spoon.state.gridCanvas = nil
  end
end

--- Draw the grid with current settings
-- Renders the grid overlay, midpoint, and crosshairs according to configuration
-- @param spoon The GridNav spoon instance
-- @return nil
function M.drawGrid(spoon)
  -- Add input validation
  if not spoon or not spoon.state then
    hs.logger.new('GridNav'):e('Invalid spoon state in drawGrid')
    return
  end

  local currentGridFrame = spoon.state.currentGridFrame
  M.clearGridDrawing(spoon)

  if not currentGridFrame or
     currentGridFrame.x == nil or
     currentGridFrame.y == nil or
     not currentGridFrame.w or currentGridFrame.w <= 0 or
     not currentGridFrame.h or currentGridFrame.h <= 0 then
    return
  end

  -- Setup radii for container
  local radii = nil
  if type(spoon.config.radius) == "number" and spoon.config.radius > 0 then
    radii = { xRadius = spoon.config.radius, yRadius = spoon.config.radius }
  end

  -- Create canvas
  local gridCanvas = hs.canvas.new({
    x = currentGridFrame.x,
    y = currentGridFrame.y,
    w = currentGridFrame.w,
    h = currentGridFrame.h
  })

  gridCanvas:level(hs.canvas.windowLevels.overlay)

  -- Add background dimming if enabled
  if spoon.config.dimBackground then
    gridCanvas:appendElements({
      type = "rectangle",
      action = "fill",
      fillColor = spoon.config.dimColor,
      roundedRectRadii = radii,
      frame = {
        x = 0, y = 0,
        w = currentGridFrame.w,
        h = currentGridFrame.h
      }
    })
  end

  -- Add border
  gridCanvas:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = spoon.config.gridBorderColor,
    strokeWidth = spoon.config.gridBorderWidth,
    fillColor = { red = 0, blue = 0, green = 0, alpha = 0.1 },
    roundedRectRadii = radii,
    frame = {
      x = 0, y = 0,
      w = currentGridFrame.w,
      h = currentGridFrame.h
    }
  })

  -- Generate and add corner decorations
  if spoon.config.decorateCorners then
    local size = spoon.config.radius

    -- Define inset quarter-circles/squares for the corners
    local corn_lg = type(size) == "number" and size > 0 and (size * 2) or 28
    local corn_sm = corn_lg / 2

    print(size)
    print(corn_lg)
    print(corn_sm)
    local corn = math.max(
      math.min(currentGridFrame.w, currentGridFrame.h, corn_lg),
      corn_sm
    )

    local corners = {
      -- Top left
      { x = -(corn / 2), y = -(corn / 2), w = corn, h = corn },

      -- Top right
      { x = currentGridFrame.w - (corn / 2), y = -(corn / 2), w = corn, h = corn },

      -- Bottom left
      { x = -(corn / 2), y = currentGridFrame.h - (corn / 2), w = corn, h = corn },

      -- Bottom right
      { x = currentGridFrame.w - (corn / 2), y = currentGridFrame.h - (corn / 2), w = corn, h = corn },
    }

    for _, position in pairs(corners) do
      local bcolor = spoon.config.gridBorderColor
      bcolor.alpha = 0.3

      gridCanvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = bcolor,
        strokeWidth = spoon.config.gridBorderWidth,
        roundedRectRadii = radii,
        frame = position,
      })
    end
  end

  -- Add midpoint
  if spoon.config.showMidpoint then
    local midpointElement = {
      type = spoon.config.midpointShape == "circle" and "oval" or "rectangle",
      action = spoon.config.midpointStrokeWidth > 0 and "strokeAndFill" or "fill",
      fillColor = spoon.config.midpointFillColor,
      frame = {
        x = currentGridFrame.w/2 - spoon.config.midpointSize/2,
        y = currentGridFrame.h/2 - spoon.config.midpointSize/2,
        w = spoon.config.midpointSize,
        h = spoon.config.midpointSize
      }
    }

    if spoon.config.midpointStrokeWidth > 0 then
      midpointElement.strokeWidth = spoon.config.midpointStrokeWidth
      midpointElement.strokeColor = spoon.config.midpointStrokeColor
    end

    gridCanvas:appendElements(midpointElement)
  end

  -- Add vertical line
  gridCanvas:appendElements({
    type = "rectangle",
    action = "fill",
    fillColor = spoon.config.gridLineColor,
    frame = {
      x = currentGridFrame.w/2 - spoon.config.gridLineWidth/2,
      y = 0,
      w = spoon.config.gridLineWidth,
      h = currentGridFrame.h
    }
  })

  -- Add horizontal line
  gridCanvas:appendElements({
    type = "rectangle",
    action = "fill",
    fillColor = spoon.config.gridLineColor,
    frame = {
      x = 0,
      y = currentGridFrame.h/2 - spoon.config.gridLineWidth/2,
      w = currentGridFrame.w,
      h = spoon.config.gridLineWidth
    }
  })

  gridCanvas:show()
  spoon.state.gridCanvas = gridCanvas
end

return M
