local w = require 'wezterm'
local M = {}

-- Weather cache variables
M.last_weather = ""
M.last_weather_time = 0
M.weather_update_interval = 1800 -- 30 minutes in seconds

-- Mapping from condition keywords to Wezterm nerdfont icons
M.weather_icons = {
  ["Clear/Sunny"] = { day = w.nerdfonts.weather_day_sunny, night = w.nerdfonts.weather_night_clear },
  ["Sunny"] = { day = w.nerdfonts.weather_day_sunny, night = w.nerdfonts.weather_night_clear },
  ["Clear"] = { day = w.nerdfonts.weather_day_sunny, night = w.nerdfonts.weather_night_clear },
  ["Partly Cloudy"] = { day = w.nerdfonts.weather_day_cloudy, night = w.nerdfonts.weather_night_alt_partly_cloudy },
  ["Partly cloudy"] = { day = w.nerdfonts.weather_day_cloudy, night = w.nerdfonts.weather_night_alt_partly_cloudy },
  ["Cloudy"] = { day = w.nerdfonts.weather_cloud, night = w.nerdfonts.weather_night_cloudy },
  ["Overcast"] = { day = w.nerdfonts.weather_cloudy, night = w.nerdfonts.weather_night_cloudy },
  ["Mist"] = { day = w.nerdfonts.weather_fog, night = w.nerdfonts.weather_night_fog },
  ["Fog"] = { day = w.nerdfonts.weather_fog, night = w.nerdfonts.weather_night_fog },
  ["Patchy rain nearby"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Light rain"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Moderate rain"] = { day = w.nerdfonts.weather_rain, night = w.nerdfonts.weather_night_rain },
  ["Heavy rain"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Torrential rain shower"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Patchy light rain"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Patchy snow nearby"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Light snow"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Moderate snow"] = { day = w.nerdfonts.weather_snow, night = w.nerdfonts.weather_night_snow },
  ["Heavy snow"] = { day = w.nerdfonts.weather_snow, night = w.nerdfonts.weather_night_snow },
  ["Blizzard"] = { day = w.nerdfonts.weather_snow_wind, night = w.nerdfonts.weather_night_snow_wind },
  ["Thundery outbreaks in nearby"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Patchy light drizzle"] = { day = w.nerdfonts.weather_day_sprinkle, night = w.nerdfonts.weather_night_sprinkle },
  ["Light drizzle"] = { day = w.nerdfonts.weather_day_sprinkle, night = w.nerdfonts.weather_night_sprinkle },
  ["Freezing fog"] = { day = w.nerdfonts.weather_fog, night = w.nerdfonts.weather_night_fog },
  ["Patchy light snow"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Patchy moderate snow"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Patchy heavy snow"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Moderate or heavy snow showers"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Light snow showers"] = { day = w.nerdfonts.weather_day_snow, night = w.nerdfonts.weather_night_snow },
  ["Moderate or heavy rain shower"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Light rain shower"] = { day = w.nerdfonts.weather_day_rain, night = w.nerdfonts.weather_night_rain },
  ["Moderate or heavy showers of ice pellets"] = { day = w.nerdfonts.weather_hail, night = w.nerdfonts.weather_night_hail },
  ["Light showers of ice pellets"] = { day = w.nerdfonts.weather_hail, night = w.nerdfonts.weather_night_hail },
  ["Ice pellets"] = { day = w.nerdfonts.weather_hail, night = w.nerdfonts.weather_night_hail },
  ["Patchy sleet nearby"] = { day = w.nerdfonts.weather_sleet, night = w.nerdfonts.weather_night_sleet },
  ["Light sleet"] = { day = w.nerdfonts.weather_sleet, night = w.nerdfonts.weather_night_sleet },
  ["Moderate or heavy sleet"] = { day = w.nerdfonts.weather_sleet, night = w.nerdfonts.weather_night_sleet },
  ["Patchy freezing drizzle nearby"] = { day = w.nerdfonts.weather_day_sprinkle, night = w.nerdfonts.weather_night_sprinkle },
  ["Freezing drizzle"] = { day = w.nerdfonts.weather_day_sprinkle, night = w.nerdfonts.weather_night_sprinkle },
  ["Heavy freezing drizzle"] = { day = w.nerdfonts.weather_day_sprinkle, night = w.nerdfonts.weather_night_sprinkle },
  ["Light freezing rain"] = { day = w.nerdfonts.weather_rain, night = w.nerdfonts.weather_night_rain },
  ["Moderate or Heavy freezing rain"] = { day = w.nerdfonts.weather_rain, night = w.nerdfonts.weather_night_rain },
  ["Patchy light snow in area with thunder"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Moderate or heavy snow in area with thunder"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Patchy light rain in area with thunder"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Moderate or heavy rain in area with thunder"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Thunderstorm"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Thundery outbreaks"] = { day = w.nerdfonts.weather_thunderstorm, night = w.nerdfonts.weather_night_thunderstorm },
  ["Snow"] = { day = w.nerdfonts.weather_snow, night = w.nerdfonts.weather_night_snow },
  ["Rain"] = { day = w.nerdfonts.weather_rain, night = w.nerdfonts.weather_night_rain },
  ["Drizzle"] = { day = w.nerdfonts.weather_day_sprinkle, night = w.nerdfonts.weather_night_sprinkle },
  ["Sleet"] = { day = w.nerdfonts.weather_sleet, night = w.nerdfonts.weather_night_sleet },
  ["Hail"] = { day = w.nerdfonts.weather_hail, night = w.nerdfonts.weather_night_hail },
  ["Freezing rain"] = { day = w.nerdfonts.weather_rain, night = w.nerdfonts.weather_night_rain },
  ["Windy"] = { day = w.nerdfonts.weather_windy, night = w.nerdfonts.weather_windy },
  ["Gale"] = { day = w.nerdfonts.weather_gale_warning, night = w.nerdfonts.weather_gale_warning },
  ["Tornado"] = { day = w.nerdfonts.weather_tornado, night = w.nerdfonts.weather_tornado },
  ["Hurricane"] = { day = w.nerdfonts.weather_hurricane, night = w.nerdfonts.weather_hurricane },
  ["Hot"] = { day = w.nerdfonts.weather_hot, night = w.nerdfonts.weather_hot },
  ["Cold"] = { day = w.nerdfonts.weather_snowflake_cold, night = w.nerdfonts.weather_snowflake_cold },
  ["Smoke"] = { day = w.nerdfonts.weather_smoke, night = w.nerdfonts.weather_smoke },
  ["Dust"] = { day = w.nerdfonts.weather_dust, night = w.nerdfonts.weather_dust },
  ["Sandstorm"] = { day = w.nerdfonts.weather_sandstorm, night = w.nerdfonts.weather_sandstorm },
  ["Volcano"] = { day = w.nerdfonts.weather_volcano, night = w.nerdfonts.weather_volcano },
  ["N/A"] = { day = w.nerdfonts.weather_na, night = w.nerdfonts.weather_na },
}

function M.get_weather_icon(condition)
  local hour = tonumber(os.date("%H"))
  local is_night = hour < 6 or hour >= 18
  -- Try exact match first
  local entry = M.weather_icons[condition]
  if entry then
    return is_night and entry.night or entry.day
  end
  -- Try partial match (case-insensitive)
  for k, v in pairs(M.weather_icons) do
    if condition:lower():find(k:lower(), 1, true) then
      return is_night and v.night or v.day
    end
  end
  return w.nerdfonts.weather_na
end

-- Temperature icon/color mapping
function M.get_temp_icon(temp)
  if type(temp) ~= "number" then
    return w.nerdfonts.md_thermometer, "#00FFFF"
  elseif temp > 90 then
    return w.nerdfonts.md_thermometer_high, "#FF0000"
  elseif temp > 80 then
    return w.nerdfonts.md_thermometer_plus, "#FFD700"
  elseif temp > 60 then
    return w.nerdfonts.md_thermometer_lines, "#00FF00"
  elseif temp > 40 then
    return w.nerdfonts.md_thermometer_minus, "#0000FF"
  elseif temp < 10 then
    return w.nerdfonts.md_thermometer_low, "#FFFFFF"
  elseif temp < 32 then
    return w.nerdfonts.md_thermometer_low, "#00FFFF"
  else
    return w.nerdfonts.md_thermometer, "#00FFFF"
  end
end

-- Feels-like icon/color mapping
function M.get_feels_icon(feels)
  if type(feels) ~= "number" then
    return w.nerdfonts.md_emoticon, "#FFFFFF"
  elseif feels > 95 or feels < 10 then
    return w.nerdfonts.md_emoticon_dead, "#FF0000"
  elseif feels > 85 then
    return w.nerdfonts.md_emoticon_frown, "#FFD700"
  elseif feels > 75 and feels <= 85 then
    return w.nerdfonts.md_emoticon, "#FFFF00"
  elseif feels > 65 and feels <= 75 then
    return w.nerdfonts.md_emoticon_excited, "#00FF00"
  elseif feels < 65 and feels > 50 then
    return w.nerdfonts.md_emoticon, "#00FF00"
  elseif feels < 50 and feels > 32 then
    return w.nerdfonts.md_emoticon_confused, "#FFA500"
  elseif feels < 32 then
    return w.nerdfonts.md_emoticon_cry, "#00BFFF"
  else
    return w.nerdfonts.md_emoticon, "#FFFFFF"
  end
end

-- Wind direction icon mapping - using direct Unicode values
M.wind_icons = {
  ["↑"] = w.nerdfonts.weather_direction_up,
  ["↓"] = w.nerdfonts.weather_direction_down,
  ["→"] = w.nerdfonts.weather_direction_right,
  ["←"] = w.nerdfonts.weather_direction_left,
  ["↗"] = w.nerdfonts.weather_direction_up_right,
  ["↖"] = w.nerdfonts.weather_direction_up_left,
  ["↘"] = w.nerdfonts.weather_direction_down_right,
  ["↙"] = w.nerdfonts.weather_direction_down_left
}

local function split_weather(str)
  local fields = {}
  local pattern = "(.-)  " -- non-greedy up to double space
  local last_end = 1
  for field, endpos in function() 
    local s, e = str:find(pattern, last_end)
    if s then
      last_end = e + 1
      return str:sub(s, e - 2), e
    end
  end do
    table.insert(fields, field)
  end
  -- Add the last field (wind), which may not be followed by double space
  local last_field = str:match(".*  (.+)$")
  if last_field then
    table.insert(fields, last_field)
  end
  return fields
end

function M.get_weather_cached(default_fg_color)
  default_fg_color = default_fg_color or "#c0c0c0" -- fallback default
  local now = os.time()
  if now - M.last_weather_time > M.weather_update_interval or M.last_weather == "" then
    local handle = io.popen('LANG=en_US.UTF-8 curl -s "wttr.in/AKC?format=%C++%t++%f++%w"')
    if handle then
      local result = handle:read("*a")
      handle:close()
      result = result and result:gsub("^%s*(.-)%s*$", "%1") or ""
      M.last_weather = result
      M.last_weather_time = now
    end
  end

  -- Robust parsing: extract each value independently
  local condition, temp, feels, wind = table.unpack(split_weather(M.last_weather))
  condition = condition or "N/A"
  temp = temp and temp:match("([%+%-]%d+)%D*") or temp
feels = feels and feels:match("([%+%-]%d+)%D*") or feels
  wind = wind or ""

  -- Condition icon
  local condition_icon = M.get_weather_icon(condition)
  local items = {
    { Text = tostring(condition_icon) .. " " },
    { Text = (condition or "") .. " " .. w.nerdfonts.pl_left_soft_divider .. " " },
  }

  -- Temperature icon and value
  local temp_icon, temp_color = M.get_temp_icon(temp)
  table.insert(items, { Foreground = { Color = temp_color } })
  table.insert(items, { Text = tostring(temp_icon) .. " "})
  table.insert(items, { Foreground = { Color = default_fg_color } }) -- Reset to default section color

  local temp_display = temp and (tostring(temp) .. "°F ") or " N/A "
  table.insert(items, { Text = temp_display .. w.nerdfonts.pl_left_soft_divider .. " " })

  -- Feels-like icon and value
  local feels_icon, feels_color = M.get_feels_icon(feels)
  table.insert(items, { Foreground = { Color = feels_color } })
  table.insert(items, { Text = tostring(feels_icon) .. " " })
  table.insert(items, { Foreground = { Color = default_fg_color } }) -- Reset to default section color

  local feels_display = feels and (tostring(feels) .. "°F ") or " N/A "
  table.insert(items, { Text = feels_display .. w.nerdfonts.pl_left_soft_divider .. " " })

  -- Wind icon and value
  local wind_speed = wind and wind:match("(%d+mph)") or ""
  
  -- Try to extract wind direction by removing the speed part
  local wind_dir_part = wind and wind:gsub("%d+mph", "") or ""
  wind_dir_part = wind_dir_part:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
  
  -- Map the corrupted character to the correct icon
  local wind_icon = ""
  -- Use the directional wind icon mapping
  if wind_dir_part ~= "" and wind_icon == "" then
    wind_icon = M.wind_icons[wind_dir_part] -- fallback for other directions
  end

  if wind_icon then
    table.insert(items, { Text = tostring(wind_icon) .. " " })
  end

  if wind_speed ~= "" then
    table.insert(items, { Text = wind_speed })
  end

  return items
end

return M