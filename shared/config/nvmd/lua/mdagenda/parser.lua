-- mdagenda/parser.lua
-- Converts raw rg output lines into structured todo objects.
--
-- rg line format (with --line-number --with-filename --no-heading):
--   /path/to/file.md:42:  - [ ] Do the thing [due::2026-04-10] [priority::high]
--
-- Frontmatter line format (^due:\s*\S pass):
--   /path/to/file.md:3:due: 2026-04-10T14:30

local config = require("mdagenda.config")

local M = {}

-- Map rg checkbox character to state name.
local STATE_MAP = {
  [" "] = "not_started",
  ["/"] = "in_progress",
  ["!"] = "blocked",
  ["x"] = "complete",
  ["-"] = "cancelled",
}

-- Parse "YYYY-MM-DD" or "YYYY-MM-DDThh:mm" into { date, time }.
local function parse_due(raw)
  if not raw then return nil, nil end
  raw = raw:match("^%s*(.-)%s*$") -- trim
  local date, time = raw:match("^(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d)$")
  if date then return date, time end
  date = raw:match("^(%d%d%d%d%-%d%d%-%d%d)$")
  if date then return date, nil end
  return nil, nil
end

-- Parse a checkbox rg line into a todo object, or nil if malformed.
-- @param line  string  full rg output line
local function parse_checkbox_line(line)
  -- Split on first two colons to get file, lnum, content.
  local file, lnum_str, content = line:match("^(.+):(%d+):(.*)$")
  if not file then return nil end
  local lnum = tonumber(lnum_str)
  if not lnum then return nil end

  -- Extract checkbox state character.
  local state_char = content:match("^%s*%- %[([^ /!x%-])%]")
    or content:match("^%s*%- %[([ /!x%-])%]")
  if not state_char then return nil end
  local state = STATE_MAP[state_char]
  if not state then return nil end

  -- Strip the checkbox prefix to get the raw text.
  local text = content:match("^%s*%- %[.%]%s*(.*)$") or ""

  -- Extract inline tags from the text.
  local due_raw  = text:match("%[due::([^%]]+)%]")
  local priority = text:match("%[priority::([^%]]+)%]")

  -- Remove tag tokens from display text.
  text = text:gsub("%[due::[^%]]*%]", "")
  text = text:gsub("%[priority::[^%]]*%]", "")
  text = text:match("^%s*(.-)%s*$") -- trim

  local due_date, due_time = parse_due(due_raw)

  -- Normalise priority.
  if priority then
    priority = priority:lower():match("^%s*(.-)%s*$")
    if priority ~= "high" and priority ~= "medium" and priority ~= "low" then
      priority = nil
    end
  end

  return {
    file         = file,
    vault        = config.vault_for_path(file),
    lnum         = lnum,
    state        = state,
    text         = text,
    due_date     = due_date,
    due_time     = due_time,
    priority     = priority,
    is_file_todo = false,
  }
end

-- Parse a frontmatter rg line into a synthetic file-level todo, or nil.
-- We only emit a file todo for each unique file (first line wins).
-- @param line         string   full rg output line
-- @param seen_files   table    set of file paths already emitted
local function parse_frontmatter_line(line, seen_files)
  local file, lnum_str, content = line:match("^(.+):(%d+):(.*)$")
  if not file then return nil end
  if seen_files[file] then return nil end
  seen_files[file] = true

  local lnum = tonumber(lnum_str) or 1

  -- due: 2026-04-10 or due: 2026-04-10T14:30
  local due_raw = content:match("^due:%s*(%S+)")
  if not due_raw then return nil end
  local due_date, due_time = parse_due(due_raw)
  if not due_date then return nil end

  -- Derive a display text from the filename.
  local basename = file:match("([^/]+)%.md$") or file:match("([^/]+)$") or file
  -- Replace hyphens/underscores with spaces for readability.
  local text = basename:gsub("[-_]", " ")

  return {
    file         = file,
    vault        = config.vault_for_path(file),
    lnum         = lnum,
    state        = "not_started",
    text         = text .. " (file)",
    due_date     = due_date,
    due_time     = due_time,
    priority     = nil,
    is_file_todo = true,
  }
end

-- Public entry point.
-- @param checkbox_lines    string[]
-- @param frontmatter_lines string[]
-- @return todo[]
function M.parse(checkbox_lines, frontmatter_lines)
  local todos = {}

  for _, line in ipairs(checkbox_lines or {}) do
    local todo = parse_checkbox_line(line)
    if todo then
      table.insert(todos, todo)
    end
  end

  local seen_files = {}
  for _, line in ipairs(frontmatter_lines or {}) do
    local todo = parse_frontmatter_line(line, seen_files)
    if todo then
      table.insert(todos, todo)
    end
  end

  return todos
end

return M
