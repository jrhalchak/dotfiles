local neorg = require('neorg.core')
local dirman = neorg.modules.get_module('core.dirman')
local ts_utils = require('neorg_todos.treesitter_utils')

local M = {}

local status_map = {
  [" "] = "pending",
  ["-"] = "progress",
  ["!"] = "important",
  ["?"] = "unknown",
  ["="] = "hold",
}

function M.parse_todo_line(line)
  local file, line_num, text = line:match("^(.-)%:(%d+)%:(.*)$")
  if not file or not line_num or not text then
    return nil
  end
  
  local status_char = text:match("%(([%s%-!%?=])%)")
  local status = status_map[status_char] or "pending"
  
  local todo_text = text:gsub("^%s*[-~]%s*%([^)]+%)%s*", "")
  
  return {
    file = file,
    line = tonumber(line_num),
    status = status,
    text = todo_text,
    raw = text
  }
end

function M.get_file_metadata(filepath)
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    return nil
  end
  
  return {
    modified = stat.mtime.sec,
    created = stat.birthtime.sec,
  }
end

function M.find_and_parse_todos(workspace)
  if not dirman then
    return {}
  end

  local raw_results = vim.fn.systemlist(
    'rg -n "[-~] \\([^(x|_)]\\)" '.. workspace[2] .. '/**/*.norg'
  )
  
  local todos = {}
  local file_cache = {}
  
  for _, line in ipairs(raw_results) do
    local todo = M.parse_todo_line(line)
    if todo then
      if not file_cache[todo.file] then
        file_cache[todo.file] = {
          metadata = M.get_file_metadata(todo.file),
          headings_parsed = false
        }
      end
      
      local heading_direct, heading_path = ts_utils.get_parent_heading_for_line(todo.file, todo.line - 1)
      local is_under_todo_heading = ts_utils.is_todo_heading(heading_direct)
      
      todo.heading_direct = heading_direct
      todo.heading_path = heading_path
      todo.is_under_todo_heading = is_under_todo_heading
      todo.file_metadata = file_cache[todo.file].metadata
      
      table.insert(todos, todo)
    end
  end
  
  return todos
end

function M.find_files(workspace)
  if not dirman then
    return nil
  end

  return vim.fn.systemlist(
    'rg "[-~] \\([^(x|_)]\\)" '.. workspace[2] .. '/**/*.norg'
  )
end

return M
