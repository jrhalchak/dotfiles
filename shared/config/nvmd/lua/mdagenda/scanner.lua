-- mdagenda/scanner.lua
-- Async two-pass rg scan across all configured vaults.
-- Pass 1: checkbox lines  ^\\s*- \\[[ /!x\\-]\\]
-- Pass 2: frontmatter due:  ^due:\\s*\\S
-- Both passes run concurrently. A shared counter triggers the callback
-- only after both complete.

local config = require("mdagenda.config")

local M = {}

-- Build the list of vault root paths to scan.
local function vault_paths()
  local paths = {}
  for _, v in ipairs(config.vault_list()) do
    table.insert(paths, v.path)
  end
  return paths
end

-- Run a single rg pass.
-- @param pattern  string  rg regex
-- @param paths    string[]  list of directories
-- @param on_done  function(lines: string[])
local function rg_pass(pattern, paths, on_done)
  local lines = {}
  local cmd = vim.list_extend(
    { "rg", "--line-number", "--no-heading", "--with-filename",
      "--glob", "*.md", pattern },
    paths
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(lines, line)
        end
      end
    end,
    on_exit = function()
      on_done(lines)
    end,
  })
end

-- Run both passes concurrently.
-- @param callback  function(checkbox_lines, frontmatter_lines)
--   Both args are string arrays in rg "file:lnum:text" format.
function M.scan(callback)
  local paths = vault_paths()
  local results = {}
  local done    = 0

  local function finish(key, lines)
    results[key] = lines
    done = done + 1
    if done == 2 then
      callback(results.checkboxes, results.frontmatter)
    end
  end

  rg_pass(
    "^\\s*- \\[[ /!x\\-]\\]",
    paths,
    function(lines) finish("checkboxes", lines) end
  )

  rg_pass(
    "^due:\\s*\\S",
    paths,
    function(lines) finish("frontmatter", lines) end
  )
end

return M
