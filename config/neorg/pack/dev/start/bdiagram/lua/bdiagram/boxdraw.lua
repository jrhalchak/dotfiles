local box_map = {
  -- Box corner holders
  -- ["A"] = "◤",
  -- ["B"] = "◥",
  -- ["C"] = "◣",
  -- ["D"] = "◢",

  -- Block corners/fills
  -- ["▗"] = "▗",
  -- ["▖"] = "▖",
  -- ["▝"] = "▝",
  -- ["▘"] = "▘",
  ["#"] = "░",
  -- ["▒"] = "▒",
  -- ["▓"] = "▓",
  -- ["█"] = "█",

  -- Horizontal lines
  ["-"] = "─",   -- thin
  ["\""] = "╌",   -- thin dotted
  ["="] = "═",   -- double
  ["_"] = "━",   -- thick

  -- Vertical lines
  ["|"] = "│",   -- thin
  [":"] = "┊",   -- thin dotted
  ["!"] = "┃",   -- thick
  [";"] = "║",   -- double

  -- Arrows
  [">"] = "▶",
  ["<"] = "◄",
  ["'"] = "▲",
  [","] = "▼",

  -- Wavy lines
  ["~"] = "◠",
  ["^"] = "◡",
}

local function is_box_char(c)
  return c and box_map[c] ~= nil or c == "+"
end

-- allow arrows next to corners
local function is_thin_h(c)
  -- count wavy lines, and arrows as horizontal thin
  return c == "-" or c == "`" or c == "," or c == "+" or c == "~" or c == "^" or c == "\""
end
-- local function is_dotted_h(c) return c == "\"" end
local function is_double_h(c) return c == "=" end
local function is_thick_h(c) return c == "_" end

-- allow arrows next to corners
local function is_thin_v(c) return c == "|" or c == "<" or c == ">" or c == "+" or c == ":" end
-- local function is_dotted_v(c) return c == ":" end
local function is_double_v(c) return c == ";" end
local function is_thick_v(c) return c == "!" end

-- Determine line types for each direction
local function line_type_h(c)
  if is_double_h(c) then return "double"
  elseif is_thick_h(c) then return "thick"
  elseif is_thin_h(c) then return "thin"
  else
    return "none"
  end
end
local function line_type_v(c)
  if is_double_v(c) then return "double"
  elseif is_thick_v(c) then return "thick"
  elseif is_thin_v(c) then return "thin"
  else
    return "none"
  end
end

local corner_map = {
  -- Top-left (only right and below)
  ["none-thin-thin-none"]    = "╭",
  ["none-double-double-none"] = "╔",
  ["none-thick-thick-none"]   = "┏",
  ["none-double-thin-none"]   = "╒",
  ["none-thin-double-none"]   = "╓",
  ["none-thick-thin-none"]    = "┍",
  ["none-thin-thick-none"]    = "┎",

  -- Top-right (only left and below)
  ["none-none-thin-thin"]     = "╮",
  ["none-none-double-double"] = "╗",
  ["none-none-thick-thick"]   = "┓",
  ["none-none-thin-double"]   = "╕",
  ["none-none-double-thin"]   = "╖",
  ["none-none-thin-thick"]    = "┑",
  ["none-none-thick-thin"]    = "┒",

  -- Bottom-left (only right and above)
  ["thin-thin-none-none"]     = "╰",
  ["double-double-none-none"] = "╚",
  ["thick-thick-none-none"]   = "┗",
  ["double-thin-none-none"]   = "╘",
  ["thin-double-none-none"]   = "╙",
  ["thick-thin-none-none"]    = "┖",
  ["thin-thick-none-none"]    = "┕",

  -- Bottom-right (only left and above)
  ["thin-none-none-thin"]     = "╯",
  ["double-none-none-double"] = "╝",
  ["thick-none-none-thick"]   = "┛",
  ["double-none-none-thin"]   = "╛",
  ["thin-none-none-double"]   = "╜",
  ["thick-none-none-thin"]    = "┙",
  ["thin-none-none-thick"]    = "┚",
}

local function get_box_char(char, left, right, above, below)
  -- Contextual for '+'
  if char == "+" then
    local left_h = left and (is_thin_h(left) or is_double_h(left) or is_thick_h(left))
    local right_h = right and (is_thin_h(right) or is_double_h(right) or is_thick_h(right))
    local above_v = above and (is_thin_v(above) or is_double_v(above) or is_thick_v(above))
    local below_v = below and (is_thin_v(below) or is_double_v(below) or is_thick_v(below))

    local lt_left = line_type_h(left)
    local lt_right = line_type_h(right)
    local lt_above = line_type_v(above)
    local lt_below = line_type_v(below)
    local key = table.concat({
      lt_above, lt_right, lt_below, lt_left
    }, "-")

    print(key)

    -- Corners
    if corner_map[key] then
      return corner_map[key]
    end

    -- One-way junctions (tees)
    if left_h and right_h and not above_v and below_v then
      -- Tee up
      if lt_left == "double" or lt_right == "double" or lt_below == "double" then return "╦"
      elseif lt_left == "thick" or lt_right == "thick" or lt_below == "thick" then return "┳"
      elseif lt_left == "dotted" or lt_right == "dotted" or lt_below == "dotted" then return "┰"
      else return "┬"
      end
    elseif left_h and right_h and above_v and not below_v then
      -- Tee down
      if lt_left == "double" or lt_right == "double" or lt_above == "double" then return "╩"
      elseif lt_left == "thick" or lt_right == "thick" or lt_above == "thick" then return "┻"
      elseif lt_left == "dotted" or lt_right == "dotted" or lt_above == "dotted" then return "┸"
      else return "┴"
      end
    elseif above_v and below_v and not left_h and right_h then
      -- Tee left: prefer vertical type for the junction
      if lt_above == "double" or lt_below == "double" then
        return "╠"
      elseif lt_above == "thick" or lt_below == "thick" then
        return "┣"
      elseif lt_above == "dotted" or lt_below == "dotted" then
        return "┝"
      elseif lt_right == "double" then
        return "╠"
      elseif lt_right == "thick" then
        return "┣"
      elseif lt_right == "dotted" then
        return "┝"
      else
        return "├"
      end
    -- Tee right: prefer vertical type for the junction
    elseif above_v and below_v and left_h and not right_h then
      if lt_above == "double" or lt_below == "double" then
        return "╣"
      elseif lt_above == "thick" or lt_below == "thick" then
        return "┫"
      elseif lt_above == "dotted" or lt_below == "dotted" then
        return "┥"
      elseif lt_left == "double" then
        return "╣"
      elseif lt_left == "thick" then
        return "┫"
      elseif lt_left == "dotted" then
        return "┥"
      else
        return "┤"
      end

    -- Crossbars (all four directions)
    elseif left_h and right_h and above_v and below_v then
      if lt_left == "double" or lt_right == "double" or lt_above == "double" or lt_below == "double" then return "╬"
      elseif lt_left == "thick" or lt_right == "thick" or lt_above == "thick" or lt_below == "thick" then return "╋"
      elseif lt_left == "dotted" or lt_right == "dotted" or lt_above == "dotted" or lt_below == "dotted" then return "╪"
      else return "┼"
      end
    -- thin lines
    elseif left_h and right_h and not above_v and not below_v then
      if lt_left == "double" or lt_right == "double" then return "═"
      elseif lt_left == "thick" or lt_right == "thick" then return "━"
      elseif lt_left == "dotted" or lt_right == "dotted" then return "╌"
      else return "─"
      end
    elseif above_v and below_v and not left_h and not right_h then
      if lt_above == "double" or lt_below == "double" then return "║"
      elseif lt_above == "thick" or lt_below == "thick" then return "┃"
      elseif lt_above == "dotted" or lt_below == "dotted" then return "┊"
      else return "│"
      end
    end
    return "+"
  end

  -- TODO - Enable `+` to conceal when directly next to an arrow (as a corner in the direction of the arrow, maybe a join/cross next to box character?)

  -- Don't replace characters just next to normal text or in-between words
  if box_map[char] and (
    line_type_h(char) ~= nil and (
      is_box_char(left) or is_box_char(right)
    )
  ) or (
    line_type_v(char) ~= nil and (
      is_box_char(above) or is_box_char(below)
    )
  ) then
    return box_map[char]
  else
    return char
  end
end

--[[
LIGHT HORIZONTAL: ─
HEAVY HORIZONTAL: ━
LIGHT VERTICAL: │
HEAVY VERTICAL: ┃
LIGHT TRIPLE DASH HORIZONTAL: ┄
HEAVY TRIPLE DASH HORIZONTAL: ┅
LIGHT TRIPLE DASH VERTICAL: ┆
HEAVY TRIPLE DASH VERTICAL: ┇
LIGHT QUADRUPLE DASH HORIZONTAL: ┈
HEAVY QUADRUPLE DASH HORIZONTAL: ┉
LIGHT QUADRUPLE DASH VERTICAL: ┊
HEAVY QUADRUPLE DASH VERTICAL: ┋
LIGHT DOWN AND RIGHT: ┌
DOWN LIGHT AND RIGHT HEAVY: ┍
DOWN HEAVY AND RIGHT LIGHT: ┎
HEAVY DOWN AND RIGHT: ┏
LIGHT DOWN AND LEFT: ┐
DOWN LIGHT AND LEFT HEAVY: ┑
DOWN HEAVY AND LEFT LIGHT: ┒
HEAVY DOWN AND LEFT: ┓
LIGHT UP AND RIGHT: └
UP LIGHT AND RIGHT HEAVY: ┕
UP HEAVY AND RIGHT LIGHT: ┖
HEAVY UP AND RIGHT: ┗
LIGHT UP AND LEFT: ┘
UP LIGHT AND LEFT HEAVY: ┙
UP HEAVY AND LEFT LIGHT: ┚
HEAVY UP AND LEFT: ┛
LIGHT VERTICAL AND RIGHT: ├
VERTICAL LIGHT AND RIGHT HEAVY: ┝
UP HEAVY AND RIGHT DOWN LIGHT: ┞
DOWN HEAVY AND RIGHT UP LIGHT: ┟
VERTICAL HEAVY AND RIGHT LIGHT: ┠
DOWN LIGHT AND RIGHT UP HEAVY: ┡
UP LIGHT AND RIGHT DOWN HEAVY: ┢
HEAVY VERTICAL AND RIGHT: ┣
LIGHT VERTICAL AND LEFT: ┤
VERTICAL LIGHT AND LEFT HEAVY: ┥
UP HEAVY AND LEFT DOWN LIGHT: ┦
DOWN HEAVY AND LEFT UP LIGHT: ┧
VERTICAL HEAVY AND LEFT LIGHT: ┨
DOWN LIGHT AND LEFT UP HEAVY: ┩
UP LIGHT AND LEFT DOWN HEAVY: ┪
HEAVY VERTICAL AND LEFT: ┫
LIGHT DOWN AND HORIZONTAL: ┬
LEFT HEAVY AND RIGHT DOWN LIGHT: ┭
RIGHT HEAVY AND LEFT DOWN LIGHT: ┮
DOWN LIGHT AND HORIZONTAL HEAVY: ┯
DOWN HEAVY AND HORIZONTAL LIGHT: ┰
RIGHT LIGHT AND LEFT DOWN HEAVY: ┱
LEFT LIGHT AND RIGHT DOWN HEAVY: ┲
HEAVY DOWN AND HORIZONTAL: ┳
LIGHT UP AND HORIZONTAL: ┴
LEFT HEAVY AND RIGHT UP LIGHT: ┵
RIGHT HEAVY AND LEFT UP LIGHT: ┶
UP LIGHT AND HORIZONTAL HEAVY: ┷
UP HEAVY AND HORIZONTAL LIGHT: ┸
RIGHT LIGHT AND LEFT UP HEAVY: ┹
LEFT LIGHT AND RIGHT UP HEAVY: ┺
HEAVY UP AND HORIZONTAL: ┻
LIGHT VERTICAL AND HORIZONTAL: ┼
LEFT HEAVY AND RIGHT VERTICAL LIGHT: ┽
RIGHT HEAVY AND LEFT VERTICAL LIGHT: ┾
VERTICAL LIGHT AND HORIZONTAL HEAVY: ┿
UP HEAVY AND DOWN HORIZONTAL LIGHT: ╀
DOWN HEAVY AND UP HORIZONTAL LIGHT: ╁
VERTICAL HEAVY AND HORIZONTAL LIGHT: ╂
LEFT UP HEAVY AND RIGHT DOWN LIGHT: ╃
RIGHT UP HEAVY AND LEFT DOWN LIGHT: ╄
LEFT DOWN HEAVY AND RIGHT UP LIGHT: ╅
RIGHT DOWN HEAVY AND LEFT UP LIGHT: ╆
DOWN LIGHT AND UP HORIZONTAL HEAVY: ╇
UP LIGHT AND DOWN HORIZONTAL HEAVY: ╈
RIGHT LIGHT AND LEFT VERTICAL HEAVY: ╉
LEFT LIGHT AND RIGHT VERTICAL HEAVY: ╊
HEAVY VERTICAL AND HORIZONTAL: ╋
LIGHT DOUBLE DASH HORIZONTAL: ╌
HEAVY DOUBLE DASH HORIZONTAL: ╍
LIGHT DOUBLE DASH VERTICAL: ╎
HEAVY DOUBLE DASH VERTICAL: ╏
DOUBLE HORIZONTAL: ═
DOUBLE VERTICAL: ║
DOWN SINGLE AND RIGHT DOUBLE: ╒
DOWN DOUBLE AND RIGHT SINGLE: ╓
DOUBLE DOWN AND RIGHT: ╔
DOWN SINGLE AND LEFT DOUBLE: ╕
DOWN DOUBLE AND LEFT SINGLE: ╖
DOUBLE DOWN AND LEFT: ╗
UP SINGLE AND RIGHT DOUBLE: ╘
UP DOUBLE AND RIGHT SINGLE: ╙
DOUBLE UP AND RIGHT: ╚
UP SINGLE AND LEFT DOUBLE: ╛
UP DOUBLE AND LEFT SINGLE: ╜
DOUBLE UP AND LEFT: ╝
VERTICAL SINGLE AND RIGHT DOUBLE: ╞
VERTICAL DOUBLE AND RIGHT SINGLE: ╟
DOUBLE VERTICAL AND RIGHT: ╠
VERTICAL SINGLE AND LEFT DOUBLE: ╡
VERTICAL DOUBLE AND LEFT SINGLE: ╢
DOUBLE VERTICAL AND LEFT: ╣
DOWN SINGLE AND HORIZONTAL DOUBLE: ╤
DOWN DOUBLE AND HORIZONTAL SINGLE: ╥
DOUBLE DOWN AND HORIZONTAL: ╦
UP SINGLE AND HORIZONTAL DOUBLE: ╧
UP DOUBLE AND HORIZONTAL SINGLE: ╨
DOUBLE UP AND HORIZONTAL: ╩
VERTICAL SINGLE AND HORIZONTAL DOUBLE: ╪
VERTICAL DOUBLE AND HORIZONTAL SINGLE: ╫
DOUBLE VERTICAL AND HORIZONTAL: ╬
LIGHT ARC DOWN AND RIGHT: ╭
LIGHT ARC DOWN AND LEFT: ╮
LIGHT ARC UP AND LEFT: ╯
LIGHT ARC UP AND RIGHT: ╰
LIGHT DIAGONAL UPPER RIGHT TO LOWER LEFT: ╱
LIGHT DIAGONAL UPPER LEFT TO LOWER RIGHT: ╲
LIGHT DIAGONAL CROSS: ╳
LIGHT LEFT: ╴
LIGHT UP: ╵
LIGHT RIGHT: ╶
LIGHT DOWN: ╷
HEAVY LEFT: ╸
HEAVY UP: ╹
HEAVY RIGHT: ╺
HEAVY DOWN: ╻
LIGHT LEFT AND HEAVY RIGHT: ╼
LIGHT UP AND HEAVY DOWN: ╽
HEAVY LEFT AND LIGHT RIGHT: ╾
HEAVY UP AND LIGHT DOWN: ╿
]]--


return {
  box_map = box_map,
  get_box_char = get_box_char,
}
