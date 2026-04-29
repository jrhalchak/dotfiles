local M = {}

-- Custom foldexpr for markdown files.
--
-- Assigns fold levels based on heading depth only. Lists, code blocks,
-- paragraphs, and horizontal rules do NOT create folds.
--
-- Special case (Option B): a thematic break (---, ***, ___) that is
-- immediately followed (ignoring blank lines) by a heading is assigned
-- fold level 0 — outside all folds — so it remains visible as a section
-- separator even when the surrounding sections are collapsed.
--
-- foldlevel is set to 2 on setup so files open with h1+h2 visible and
-- h3+ folded, matching org-mode outline navigation. zm/zr adjust one
-- level at a time; zM/zR open or close everything.

-- ---------------------------------------------------------------------------
-- foldexpr
-- ---------------------------------------------------------------------------

local function is_thematic_break(s)
  return s:match("^%-%-%-+%s*$") or s:match("^%*%*%*+%s*$") or s:match("^___%s*$")
end

function M.foldexpr(lnum)
  local line = vim.fn.getline(lnum)
  local total = vim.fn.line("$")

  -- Heading → open a fold at heading depth
  local hashes = line:match("^(#+)%s")
  if hashes then
    return ">" .. #hashes
  end

  -- Thematic break → level 0 if the next non-blank line is a heading
  if is_thematic_break(line) then
    local next = lnum + 1
    while next <= total and vim.fn.getline(next):match("^%s*$") do
      next = next + 1
    end
    if next <= total and vim.fn.getline(next):match("^#+%s") then
      return "0"
    end
  end

  -- Blank line → level 0 if it borders a section boundary:
  --   immediately before a heading
  --   immediately before a thematic break
  --   immediately after a thematic break
  if line:match("^%s*$") then
    local next_line = lnum < total and vim.fn.getline(lnum + 1) or ""
    local prev_line = lnum > 1    and vim.fn.getline(lnum - 1) or ""
    if next_line:match("^#+%s")
      or is_thematic_break(next_line)
      or is_thematic_break(prev_line)
    then
      return "0"
    end
  end

  return "="
end

-- ---------------------------------------------------------------------------
-- Virtual blank lines between fold groups
--
-- A blank virt_line is placed below a closed fold when the next visible
-- line is at a shallower fold level than the fold that just ended — i.e.
-- we are leaving a group of peer folds and returning to a parent or a new
-- section. Peer siblings (same level, next fold at same depth) get no blank.
--
-- The scan covers the full buffer but only attaches extmarks; it is
-- debounced via CursorHold so it does not run on every keystroke.
-- ---------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("markdown_fold_gaps")

local function fold_level_at(lnum)
  -- foldlevel() returns the fold level of a line as seen by the expr.
  -- For our purposes we want the heading depth that owns this line.
  -- We walk backwards to find the most recent heading.
  local line = vim.fn.getline(lnum)
  local h = line:match("^(#+)%s")
  if h then return #h end
  -- For non-heading lines use vim's computed fold level
  return vim.fn.foldlevel(lnum)
end

local function refresh_gaps(buf)
  -- Don't disrupt search, operator-pending, or visual operations
  local mode = vim.fn.mode()
  if mode:match("[vVoO\x16]") then return end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    local total = vim.api.nvim_buf_line_count(buf)
    local lnum = 1

    while lnum <= total do
      local fold_start = vim.fn.foldclosed(lnum)
      local fold_end   = vim.fn.foldclosedend(lnum)

      if fold_start == lnum and fold_end > fold_start then
        local this_level = fold_level_at(lnum)

        local next_visible = fold_end + 1
        local next_level = 0
        if next_visible <= total then
          local nv_line = vim.fn.getline(next_visible)
          local nv_h = nv_line:match("^(#+)%s")
          if nv_h then
            next_level = #nv_h
          else
            next_level = vim.fn.foldlevel(next_visible)
          end
        end

        if next_visible > total or next_level < this_level then
          vim.api.nvim_buf_set_extmark(buf, ns, fold_end - 1, 0, {
            virt_lines = { { { "", "Normal" } } },
            virt_lines_above = false,
          })
        end

        lnum = fold_end + 1
      else
        lnum = lnum + 1
      end
    end
  end)
end

-- ---------------------------------------------------------------------------
-- setup
-- ---------------------------------------------------------------------------

function M.setup()
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr   = "v:lua.require('config.markdown_folds').foldexpr(v:lnum)"
  vim.wo.foldlevel  = 2

  local buf = vim.api.nvim_get_current_buf()

  -- Initial pass after the buffer is fully loaded.
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      refresh_gaps(buf)
    end
  end)

  -- Recompute only when switching back to the buffer, not on every cursor move.
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer  = buf,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) then
        refresh_gaps(buf)
      end
    end,
  })
end

return M
