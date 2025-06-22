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
  -- ["░"] = "░",
  -- ["▒"] = "▒",
  -- ["▓"] = "▓",
  -- ["█"] = "█",

  -- Horizontal lines
  ["-"] = "─",   -- single
  ["="] = "═",   -- double
  ["_"] = "━",   -- thick
  ["~"] = "╌",   -- dotted

  -- Vertical lines
  ["|"] = "│",   -- single
  [":"] = "┊",   -- dotted
  ["!"] = "┃",   -- thick
  [";"] = "║",   -- double

  -- Arrows
  [">"] = "▶",
  ["<"] = "◄",
  ["^"] = "▲",
  ["v"] = "▼",

  -- Wavy lines
  ["w"] = "◠",
  ["m"] = "◡",
}

local function get_box_char(char, left, right, above, below)
  -- allow arrows next to corners
  local function is_single_h(c) return c == "-" or c == "^" or c == "v" or c == "+" end
  local function is_double_h(c) return c == "=" end
  local function is_thick_h(c) return c == "_" end
  local function is_dotted_h(c) return c == "~" end
  -- allow arrows next to corners
  local function is_single_v(c) return c == "|" or c == "<" or c == ">" or c == "+" end
  local function is_double_v(c) return c == ";" end
  local function is_thick_v(c) return c == "!" end
  local function is_dotted_v(c) return c == ":" end

  -- Contextual for '+'
  if char == "+" then
    local left_h = left and (is_single_h(left) or is_double_h(left) or is_thick_h(left) or is_dotted_h(left))
    local right_h = right and (is_single_h(right) or is_double_h(right) or is_thick_h(right) or is_dotted_h(right))
    local above_v = above and (is_single_v(above) or is_double_v(above) or is_thick_v(above) or is_dotted_v(above))
    local below_v = below and (is_single_v(below) or is_double_v(below) or is_thick_v(below) or is_dotted_v(below))

    -- Determine line types for each direction
    local function line_type_h(c)
      if is_double_h(c) then return "double"
      elseif is_thick_h(c) then return "thick"
      elseif is_dotted_h(c) then return "dotted"
      elseif is_single_h(c) then return "single"
      end
    end
    local function line_type_v(c)
      if is_double_v(c) then return "double"
      elseif is_thick_v(c) then return "thick"
      elseif is_dotted_v(c) then return "dotted"
      elseif is_single_v(c) then return "single"
      end
    end

    local lt_left = line_type_h(left)
    local lt_right = line_type_h(right)
    local lt_above = line_type_v(above)
    local lt_below = line_type_v(below)

    -- Corners
    -- Top-left: right only, nothing left, nothing above, and something below (vertical or arrow)
    if not left_h and not above_v and right_h and below_v then
      if lt_right == "double" and lt_below == "double" then
        return "╔"
      elseif lt_right == "double" and lt_below == "single" then
        return "╓"
      elseif lt_right == "single" and lt_below == "double" then
        return "╒"
      elseif lt_right == "double" then
        return "╒"
      elseif lt_right == "single" and lt_below == "single" then
        return "╭"
      elseif lt_right == "single" then
        return "╭"
      elseif lt_right == "thick" and lt_below == "thick" then
        return "┏"
      elseif lt_right == "thick" then
        return "┏"
      elseif lt_right == "dotted" then
        return "╭"
      end
    -- Top-right: left only, nothing right, nothing above, and something below (vertical or arrow)
    elseif not right_h and not above_v and left_h and below_v then
      if lt_left == "double" and lt_below == "double" then
        return "╗"
      elseif lt_left == "double" and lt_below == "single" then
        return "╖"
      elseif lt_left == "single" and lt_below == "double" then
        return "╕"
      elseif lt_left == "double" then
        return "╕"
      elseif lt_left == "single" and lt_below == "single" then
        return "╮"
      elseif lt_left == "single" then
        return "╮"
      elseif lt_left == "thick" and lt_below == "thick" then
        return "┓"
      elseif lt_left == "thick" then
        return "┓"
      elseif lt_left == "dotted" then
        return "╮"
      end
    -- Bottom-left: right only, nothing left, nothing below, and something above (vertical or arrow)
    elseif not left_h and not below_v and right_h and above_v then
      if lt_right == "double" and lt_above == "double" then
        return "╚"
      elseif lt_right == "double" and lt_above == "single" then
        return "╙"
      elseif lt_right == "single" and lt_above == "double" then
        return "╘"
      elseif lt_right == "double" then
        return "╘"
      elseif lt_right == "single" and lt_above == "single" then
        return "╰"
      elseif lt_right == "single" then
        return "╰"
      elseif lt_right == "thick" and lt_above == "thick" then
        return "┗"
      elseif lt_right == "thick" then
        return "┗"
      elseif lt_right == "dotted" then
        return "╰"
      end
    -- Bottom-right: left only, nothing right, nothing below, and something above (vertical or arrow)
    elseif not right_h and not below_v and left_h and above_v then
      if lt_left == "double" and lt_above == "double" then
        return "╝"
      elseif lt_left == "double" and lt_above == "single" then
        return "╜"
      elseif lt_left == "single" and lt_above == "double" then
        return "╛"
      elseif lt_left == "double" then
        return "╛"
      elseif lt_left == "single" and lt_above == "single" then
        return "╯"
      elseif lt_left == "single" then
        return "╯"
      elseif lt_left == "thick" and lt_above == "thick" then
        return "┛"
      elseif lt_left == "thick" then
        return "┛"
      elseif lt_left == "dotted" then
        return "╯"
      end
    -- One-way junctions (tees)
    elseif left_h and right_h and not above_v and below_v then
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
    -- Single lines
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

  return box_map[char] or char
end

return {
  box_map = box_map,
  get_box_char = get_box_char,
}
