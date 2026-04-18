-- config/notes.lua
-- Note-management functions: journal, search, links, backlinks.
-- Vault paths come from mdagenda.config — never from CWD.

local M = {}

-- ---------------------------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------------------------

-- Compute the relative path from `from_dir` (absolute directory) to
-- `to_abs` (absolute file path). Returns a POSIX-style relative path string.
local function relpath(from_dir, to_abs)
  -- Normalise: strip trailing slash from dir
  from_dir = from_dir:gsub("/$", "")
  to_abs   = to_abs:gsub("/$", "")

  local function split(p)
    local parts = {}
    for seg in (p .. "/"):gmatch("([^/]+)/") do
      table.insert(parts, seg)
    end
    return parts
  end

  local from_parts = split(from_dir)
  local to_parts   = split(to_abs)

  -- Find common prefix length
  local common = 0
  for i = 1, math.min(#from_parts, #to_parts) do
    if from_parts[i] == to_parts[i] then
      common = i
    else
      break
    end
  end

  local up = #from_parts - common
  local segments = {}
  for _ = 1, up do
    table.insert(segments, "..")
  end
  for i = common + 1, #to_parts do
    table.insert(segments, to_parts[i])
  end

  if #segments == 0 then return "." end
  return table.concat(segments, "/")
end

-- Async vault resolution.
--   1. Current buffer path → mdagenda.config.vault_for_path
--   2. ZK_DEFAULT_VAULT env var → mdagenda.config.default_vault()
--   3. vim.ui.select vault picker
-- Calls cb({ name, path }) when resolved, or cb(nil) on cancel.
local function resolve_vault(cb)
  local cfg     = require("mdagenda.config")
  local bufname = vim.api.nvim_buf_get_name(0)

  -- 1. Buffer is inside a known vault
  if bufname and bufname ~= "" then
    local name = cfg.vault_for_path(bufname)
    if name then
      cb({ name = name, path = cfg.values.vaults[name] })
      return
    end
  end

  -- 2. Environment default
  local default = cfg.default_vault()
  if default then
    cb(default)
    return
  end

  -- 3. Interactive picker
  vim.ui.select(cfg.vault_list(), {
    prompt      = "Choose vault:",
    format_item = function(v) return v.name end,
  }, function(choice)
    cb(choice or nil)
  end)
end

-- Month names for journal heading ("April 10, 2026")
local MONTHS = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
}

-- Create (if needed) and open the journal file for `date_offset` days from
-- today in the given vault. date_offset: 0=today, 1=tomorrow, -1=yesterday.
local function open_journal(vault, date_offset)
  local offset = date_offset or 0
  local t = os.time() + offset * 86400
  local d = os.date("*t", t)

  local yyyy = string.format("%04d", d.year)
  local mm   = string.format("%02d", d.month)
  local dd   = string.format("%02d", d.day)
  local date_str = yyyy .. "-" .. mm .. "-" .. dd

  local dir  = vault.path .. "/journal"
  local path = dir .. "/" .. date_str .. ".md"

  -- Create journal directory if absent
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  -- Create file from template if it does not exist
  if vim.fn.filereadable(path) == 0 then
    local heading = MONTHS[d.month] .. " " .. d.day .. ", " .. d.year
    local lines = {
      "---",
      "created: " .. date_str,
      "tags: []",
      "---",
      "",
      "# " .. heading,
      "",
    }
    vim.fn.writefile(lines, path)
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

-- Shared Telescope picker for insert-link variants.
-- vault        : { name, path }
-- display_text : default text to pre-fill as display portion (may be nil)
-- on_select    : function(rel_path, display_text) called on confirm
local function link_picker(vault, display_text, on_select)
  local telescope = require("telescope.builtin")
  local actions   = require("telescope.actions")
  local state     = require("telescope.actions.state")

  telescope.find_files({
    cwd         = vault.path,
    prompt_title = "Insert Link (" .. vault.name .. ")",
    attach_mappings = function(prompt_bufnr, _map)
      actions.select_default:replace(function()
        local entry = state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then return end

        -- entry.value is relative to vault.path (Telescope find_files with cwd)
        local abs  = vault.path .. "/" .. entry.value
        -- Strip .md extension from the link target
        local link = abs:gsub("%.md$", "")

        -- Compute path relative to the current buffer's directory
        local bufdir = vim.fn.fnamemodify(
          vim.api.nvim_buf_get_name(0), ":p:h"
        )
        local rel = relpath(bufdir, link)

        on_select(rel, display_text or vim.fn.fnamemodify(entry.value, ":t:r"))
      end)
      return true
    end,
  })
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Return { name, path } for the current buffer's vault, or nil.
function M.vault_for_buf()
  local cfg     = require("mdagenda.config")
  local bufname = vim.api.nvim_buf_get_name(0)
  if not bufname or bufname == "" then return nil end
  local name = cfg.vault_for_path(bufname)
  if not name then return nil end
  return { name = name, path = cfg.values.vaults[name] }
end

-- Open/create journal for today (0), tomorrow (1), or yesterday (-1).
function M.journal(date_offset)
  resolve_vault(function(vault)
    if not vault then return end
    open_journal(vault, date_offset or 0)
  end)
end

-- Open/create journal for a specific YYYY-MM-DD date string.
-- Used by the calendar picker.
function M.journal_for_date(date_str)
  -- Parse date_str "YYYY-MM-DD" into a time offset from today
  local y, mo, d = date_str:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
  if not y then
    vim.notify("notes: invalid date: " .. tostring(date_str), vim.log.levels.ERROR)
    return
  end
  resolve_vault(function(vault)
    if not vault then return end
    -- Use the vault + date directly rather than offset arithmetic
    local dir  = vault.path .. "/journal"
    local path = dir .. "/" .. date_str .. ".md"
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    if vim.fn.filereadable(path) == 0 then
      local t    = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d) })
      local dt   = os.date("*t", t)
      local heading = MONTHS[dt.month] .. " " .. dt.day .. ", " .. dt.year
      local lines = {
        "---",
        "created: " .. date_str,
        "tags: []",
        "---",
        "",
        "# " .. heading,
        "",
      }
      vim.fn.writefile(lines, path)
    end
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end

-- Telescope find_files in vault/journal/
function M.journal_list()
  resolve_vault(function(vault)
    if not vault then return end
    require("telescope.builtin").find_files({
      cwd          = vault.path .. "/journal",
      prompt_title = "Journal (" .. vault.name .. ")",
    })
  end)
end

-- Telescope find_files scoped to vault root
function M.find()
  resolve_vault(function(vault)
    if not vault then return end
    require("telescope.builtin").find_files({
      cwd          = vault.path,
      prompt_title = "Notes (" .. vault.name .. ")",
    })
  end)
end

-- Telescope live_grep scoped to vault root
function M.grep(initial_query)
  resolve_vault(function(vault)
    if not vault then return end
    require("telescope.builtin").live_grep({
      cwd           = vault.path,
      prompt_title  = "Grep Notes (" .. vault.name .. ")",
      default_text  = initial_query or "",
    })
  end)
end

-- Telescope live_grep pre-filled with "#" to search for tags
function M.grep_tags()
  resolve_vault(function(vault)
    if not vault then return end
    require("telescope.builtin").live_grep({
      cwd          = vault.path,
      prompt_title = "Tags (" .. vault.name .. ")",
      default_text = "#",
    })
  end)
end

-- live_grep for backlinks: search for [[<vault-relative-path-without-ext>
-- Using the vault-relative path avoids false matches from files that share
-- only a filename stem but live in different directories (e.g. two index.md).
function M.backlinks()
  resolve_vault(function(vault)
    if not vault then return end
    local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
    local vpath   = vim.fn.expand(vault.path) .. "/"

    -- Strip vault prefix and .md extension to get the relative path used in links
    local rel
    if bufname:sub(1, #vpath) == vpath then
      rel = bufname:sub(#vpath + 1):gsub("%.md$", "")
    else
      -- Buffer is outside the vault — fall back to stem only
      rel = vim.fn.fnamemodify(bufname, ":t:r")
    end

    require("telescope.builtin").live_grep({
      cwd          = vault.path,
      prompt_title = "Backlinks → " .. rel,
      default_text = "[[" .. rel,
    })
  end)
end

-- Parse [[...]] links from current buffer; show in vim.ui.select; jump to chosen.
function M.note_links()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local seen  = {}
  local links = {}
  for _, line in ipairs(lines) do
    for raw in line:gmatch("%[%[([^%]]+)%]%]") do
      -- strip alias after "|" and anchor after "#"
      local target = raw:match("^([^|#]+)") or raw
      target = vim.trim(target)
      if not seen[target] then
        seen[target] = true
        table.insert(links, target)
      end
    end
  end

  if #links == 0 then
    vim.notify("No [[links]] found in buffer", vim.log.levels.INFO)
    return
  end

  vim.ui.select(links, {
    prompt = "Links in note:",
  }, function(choice)
    if not choice then return end
    require("mkdnflow").links.followLink({ path = choice })
  end)
end

-- Insert link at cursor position. Opens Telescope picker; inserts [[rel|cword]].
function M.insert_link()
  local display = vim.fn.expand("<cword>")
  resolve_vault(function(vault)
    if not vault then return end
    link_picker(vault, display, function(rel, disp)
      local link = "[[" .. rel .. "|" .. disp .. "]]"
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
      local new_line = line:sub(1, col) .. link .. line:sub(col + 1)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
      vim.api.nvim_win_set_cursor(0, { row, col + #link })
    end)
  end)
end

-- Insert link, replacing current visual selection with [[rel|selection]].
function M.insert_link_visual()
  -- Capture selection before picker opens (it will clear visual mode)
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")
  local s_row = start_pos[2]
  local s_col = start_pos[3] - 1  -- 0-indexed
  local e_col = end_pos[3]        -- exclusive end for byte slice

  local line         = vim.api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]
  local display_text = line:sub(s_col + 1, e_col)

  resolve_vault(function(vault)
    if not vault then return end
    link_picker(vault, display_text, function(rel, disp)
      local link    = "[[" .. rel .. "|" .. disp .. "]]"
      local cur_line = vim.api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]
      local new_line = cur_line:sub(1, s_col) .. link .. cur_line:sub(e_col + 1)
      vim.api.nvim_buf_set_lines(0, s_row - 1, s_row, false, { new_line })
    end)
  end)
end

-- Prompt for a title; create a new note in the current buffer's directory;
-- open it. If the current buffer is not in a vault, defaults to vault root.
function M.new_note()
  vim.ui.input({ prompt = "Note title: " }, function(title)
    if not title or vim.trim(title) == "" then return end
    title = vim.trim(title)

    local bufname = vim.api.nvim_buf_get_name(0)
    local dest_dir
    if bufname and bufname ~= "" then
      dest_dir = vim.fn.fnamemodify(bufname, ":p:h")
    else
      resolve_vault(function(vault)
        if not vault then return end
        dest_dir = vault.path
      end)
    end
    if not dest_dir then return end

    -- filename: lowercase, spaces → hyphens
    local filename = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "") .. ".md"
    local path     = dest_dir .. "/" .. filename
    local date_str = os.date("%Y-%m-%d")

    if vim.fn.filereadable(path) == 0 then
      vim.fn.writefile({
        "---",
        "title: " .. title,
        "created: " .. date_str,
        "tags: []",
        "---",
        "",
        "# " .. title,
        "",
      }, path)
    end
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end

-- Use visual selection as the note title. Prompt for a filename slug.
-- Create the note, then replace the selection with [[rel|title]].
function M.new_from_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")
  local s_row = start_pos[2]
  local s_col = start_pos[3] - 1
  local e_col = end_pos[3]

  local line  = vim.api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]
  local title = line:sub(s_col + 1, e_col)
  if not title or vim.trim(title) == "" then return end

  local default_slug = vim.trim(title):lower():gsub("%s+", "-"):gsub("[^%w%-]", "")

  vim.ui.input({ prompt = "Filename slug: ", default = default_slug }, function(slug)
    if not slug or vim.trim(slug) == "" then return end
    slug = vim.trim(slug)

    local bufname  = vim.api.nvim_buf_get_name(0)
    local dest_dir = bufname and bufname ~= ""
      and vim.fn.fnamemodify(bufname, ":p:h")
      or nil

    if not dest_dir then
      vim.notify("notes: cannot determine destination directory", vim.log.levels.ERROR)
      return
    end

    local filename = slug:gsub("%.md$", "") .. ".md"
    local path     = dest_dir .. "/" .. filename
    local date_str = os.date("%Y-%m-%d")

    if vim.fn.filereadable(path) == 0 then
      vim.fn.writefile({
        "---",
        "title: " .. title,
        "created: " .. date_str,
        "tags: []",
        "---",
        "",
        "# " .. title,
        "",
      }, path)
    end

    -- Replace the selection with a wiki link
    local rel      = relpath(dest_dir, path:gsub("%.md$", ""))
    local link     = "[[" .. rel .. "|" .. title .. "]]"
    local cur_line = vim.api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]
    local new_line = cur_line:sub(1, s_col) .. link .. cur_line:sub(e_col + 1)
    vim.api.nvim_buf_set_lines(0, s_row - 1, s_row, false, { new_line })

    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end

return M
