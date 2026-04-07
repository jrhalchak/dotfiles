-- mdagenda/convert.lua
-- Convert a checkbox line into a standalone task file with YAML frontmatter,
-- then replace the line with a wikilink.

local config = require("mdagenda.config")
local edit   = require("mdagenda.edit")

local M = {}

local STATE_MAP = {
  [" "] = "not_started",
  ["/"] = "in_progress",
  ["!"] = "blocked",
  ["x"] = "complete",
  ["-"] = "cancelled",
}

-- Convert todo text to a filename slug.
-- Lowercase, keep alphanumeric and spaces, collapse to hyphens, max 60 chars.
local function slugify(text)
  local s = text:lower()
  s = s:gsub("[^%w%s%-]", "")   -- strip non-alphanumeric (keep hyphens and spaces)
  s = s:gsub("%s+", "-")        -- spaces → hyphens
  s = s:gsub("%-+", "-")        -- collapse multiple hyphens
  s = s:gsub("^%-+", "")        -- strip leading hyphens
  s = s:gsub("%-+$", "")        -- strip trailing hyphens
  return s:sub(1, 60)
end

-- Build YAML frontmatter lines.
local function build_frontmatter(title, state_name, due_raw, priority)
  local lines = { "---" }
  table.insert(lines, "title: " .. title)
  table.insert(lines, "status: " .. state_name)
  if due_raw and due_raw ~= "" then
    table.insert(lines, "due: " .. due_raw)
  end
  if priority and priority ~= "" then
    table.insert(lines, "priority: " .. priority)
  end
  table.insert(lines, "---")
  table.insert(lines, "")
  return lines
end

function M.todo_to_task()
  local line = vim.api.nvim_get_current_line()
  local state_char = edit.checkbox_char(line)
  if not state_char then
    vim.notify("mdagenda: cursor is not on a checkbox line", vim.log.levels.WARN)
    return
  end

  -- Determine vault from current file.
  local current_file = vim.fn.expand("%:p")
  local vault_name   = config.vault_for_path(current_file)
  if not vault_name then
    vim.notify("mdagenda: current file is not inside a configured vault", vim.log.levels.WARN)
    return
  end
  local vault_root = config.values.vaults[vault_name]

  -- Extract todo text (everything after the checkbox prefix).
  local raw_text = line:match("^%s*%- %[.%]%s*(.-)%s*$") or ""

  -- Extract and strip inline tags from display text.
  local due_raw  = raw_text:match("%[due::([^%]]+)%]")
  local priority = raw_text:match("%[priority::([^%]]+)%]")
  local todo_text = raw_text
    :gsub("%[due::[^%]]*%]", "")
    :gsub("%[priority::[^%]]*%]", "")
    :match("^%s*(.-)%s*$")

  if todo_text == "" then
    vim.notify("mdagenda: checkbox line has no text to use as task title", vim.log.levels.WARN)
    return
  end

  local state_name = STATE_MAP[state_char] or "not_started"
  local slug       = slugify(todo_text)
  if slug == "" then
    vim.notify("mdagenda: could not generate a slug from: " .. todo_text, vim.log.levels.WARN)
    return
  end

  local tasks_dir = vault_root .. "/tasks"
  local task_file = tasks_dir .. "/" .. slug .. ".md"

  if vim.fn.filereadable(task_file) == 1 then
    vim.notify("mdagenda: task file already exists: " .. task_file, vim.log.levels.WARN)
    return
  end

  -- Create tasks/ directory if needed.
  vim.fn.mkdir(tasks_dir, "p")

  -- Write the task file.
  local fm_lines = build_frontmatter(todo_text, state_name, due_raw, priority)
  -- Add a placeholder body so the file isn't completely empty.
  table.insert(fm_lines, "")
  local ok = vim.fn.writefile(fm_lines, task_file)
  if ok ~= 0 then
    vim.notify("mdagenda: failed to write task file: " .. task_file, vim.log.levels.ERROR)
    return
  end

  -- Preserve original indentation, keep checkbox state.
  local indent = line:match("^(%s*)") or ""
  local wikilink_line = indent .. "- [" .. state_char .. "] [[tasks/" .. slug .. "]]"
  vim.api.nvim_set_current_line(wikilink_line)

  vim.notify("mdagenda: created " .. task_file, vim.log.levels.INFO)
end

return M
