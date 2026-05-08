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
local function is_thin_v(c) return c == "|" or c == "<" or c == ">" or c == "+" or c == ":" or c == "v" or c == "^" end
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
  -- Swapped from neorg: ┚ is UP HEAVY AND LEFT LIGHT (above thick, left thin);
  -- ┙ is UP LIGHT AND LEFT HEAVY (above thin, left thick).
  ["thick-none-none-thin"]    = "┚",
  ["thin-none-none-thick"]    = "┙",
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

  -- Context-dependent `^`: arrow when shaft is below, otherwise fall through
  -- to the generic box_map handling (which gives the wavy `◡`).
  if char == "^" then
    if below == "|" or below == ":" or below == "!" or below == ";" or below == "+" then
      return "▲"
    end
  end

  -- Context-dependent `v`: arrow when shaft is above. Not in box_map, so
  -- otherwise return as-is so plain text `v` is preserved.
  if char == "v" then
    if above == "|" or above == ":" or above == "!" or above == ";" or above == "+" then
      return "▼"
    end
    return char
  end

  -- `<` / `>`: only conceal as arrows when the inner side (the shaft side) is
  -- adjacent to a horizontal line or a `+`. Protects `<env>`, `a > b`, etc.
  if char == "<" then
    if right == "-" or right == "=" or right == "_" or right == "\"" or right == "+" then
      return "◄"
    end
    return char
  end
  if char == ">" then
    if left == "-" or left == "=" or left == "_" or left == "\"" or left == "+" then
      return "▶"
    end
    return char
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

return {
  box_map = box_map,
  get_box_char = get_box_char,
}
