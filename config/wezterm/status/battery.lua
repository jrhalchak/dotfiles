local w = require "wezterm"
local M = {}

function M.get_battery_icon(percent)
  if percent >= 95 then
    return w.nerdfonts.fa_battery_full
  elseif percent >= 75 then
    return w.nerdfonts.fa_battery_three_quarters
  elseif percent >= 50 then
    return w.nerdfonts.fa_battery_half
  elseif percent >= 25 then
    return w.nerdfonts.fa_battery_quarter
  else
    return w.nerdfonts.fa_battery_empty
  end
end

function M.get_battery_info()
  local segments = {}

  for _, b in ipairs(w.battery_info()) do
    local percent_val = b.state_of_charge and (b.state_of_charge * 100) or nil
    local percent_str = percent_val and string.format('%.0f%%', percent_val) or ""
    local icon = percent_val and M.get_battery_icon(percent_val) or w.nerdfonts.fa_battery_empty
    local battery_cell = percent_str ~= "" and (tostring(icon) .. " " .. percent_str) or nil
    table.insert(segments, battery_cell)
  end

  return segments
end

return M
