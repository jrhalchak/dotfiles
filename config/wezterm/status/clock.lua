local w = require("wezterm")
local M = {}

-- Number to binary string with icons
function M.to_bin(val)
  local bin = {}
  for i = 5, 0, -1 do
    -- originally 󰄮/󰢤
    table.insert(bin, ((val & (1 << i)) ~= 0 and w.nerdfonts.fa_square .. " " or w.nerdfonts.oct_square .. " "))
  end
  return table.concat(bin)
end

function M.binary_clock()
  local hour = tonumber(os.date("%H"))
  local min = tonumber(os.date("%M"))
  local sec = tonumber(os.date("%S"))
  return M.to_bin(hour) .. w.nerdfonts.pl_left_soft_divider .. " " .. M.to_bin(min) .. w.nerdfonts.pl_left_soft_divider .. " " .. M.to_bin(sec)
end

return M