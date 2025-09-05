
local w = require "wezterm"
local M = {}

-- Minimum path length to display, regardless of window width
local MIN_LEN = 20
-- Fraction of window width to allocate for path display
local WIDTH_FRACTION = 0.25

-- Extracts the base hostname (removes domain part)
local function hostname_base(h)
  return (h and h:match("^[^.]+")) or h or ""
end

-- Truncates a path string to fit within max_len columns.
-- Always keeps the first segment (or first two if path starts with ~), and the last segment.
-- Uses /.../ to indicate omitted middle segments.
local function truncate_path(path, max_len)
  if not path or path == "" or #path <= max_len then
    -- Path is empty or already fits
    return path
  end
  -- Split path into segments
  local parts = {}
  for seg in path:gmatch("[^/]+") do parts[#parts+1] = seg end
  if #parts == 0 then return path end

  -- If path starts with ~ and has a second segment, keep both; else keep only first
  local keep_head = (parts[1] == "~" and parts[2]) and 2 or 1

  -- If only one tail segment after head, just truncate tail if needed
  if #parts <= keep_head + 1 then
    local out = path
    if #out > max_len then
      -- Truncate and add ellipsis if still too long
      out = out:sub(1, max_len - 1) .. "…"
    end
    return out
  end

  -- Build head/.../last candidate
  local head = table.concat(parts, "/", 1, keep_head)
  local last = parts[#parts]
  local candidate = head .. "/.../" .. last
  if #candidate <= max_len then
    return candidate
  end

  -- If candidate is too long, try truncating the last segment
  local prefix = head .. "/.../"
  local budget = max_len - #prefix
  if budget > 6 then
    local trunc_last = last:sub(1, budget - 3) .. "..."
    local c2 = prefix .. trunc_last
    if #c2 <= max_len then
      return c2
    end
  end

  -- If still too long, fallback to just head/...
  local minimal = head .. "/..."
  if #minimal <= max_len then
    return minimal
  end

  -- If even head/... is too long, truncate head itself
  local hb = max_len - 4 -- room for /...
  if hb > 4 then
    return head:sub(1, hb - 3) .. ".../..."
  end

  -- Last resort: hard truncate the whole path
  return path:sub(1, max_len - 1) .. "…"
end

-- Returns a string for the current working directory, truncated for display.
-- If remote, returns just the hostname.
function M.get_cwd_info(window, pane)
  local cwd_uri = pane:get_current_working_dir()
  if not cwd_uri then return nil end

  local path = ""
  local host = ""

  -- Extract path and host from URI (userdata or string)
  if type(cwd_uri) == "userdata" then
    path = cwd_uri.file_path or ""
    host = cwd_uri.host or ""
  else
    -- Parse string URI: file://host/path
    local raw = cwd_uri:sub(8)
    local slash = raw:find("/")
    if slash then
      host = raw:sub(1, slash - 1)
      local enc = raw:sub(slash)
      -- Decode percent-encoded path
      path = enc:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    end
  end

  -- Use base hostname (strip domain)
  host = hostname_base(host)
  if host == "" then host = hostname_base(w.hostname()) end

  -- Replace $HOME with ~ at the start of the path
  local home = os.getenv("HOME")
  if home and home ~= "" then
    path = path:gsub("^" .. home, "~")
  end

  -- Calculate max path length based on window width
  local cols = 0
  local tab = window:active_tab()
  if tab then
    local sz = tab:get_size()
    if sz and sz.cols then cols = sz.cols end
  end
  local max_len = math.max(MIN_LEN, math.floor(cols * WIDTH_FRACTION))

  -- If remote, show only the hostname
  local local_host = hostname_base(w.hostname())
  if host ~= "" and host ~= local_host then
    return host
  end

  -- Otherwise, show truncated local path
  return truncate_path(path, max_len)
end

return M