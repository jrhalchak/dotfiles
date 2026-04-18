local M = {}

-- Custom foldexpr for markdown files.
--
-- Neovim's treesitter fold query for markdown folds sections, lists,
-- list_items, and code blocks. This causes list items to collapse
-- unexpectedly during normal navigation.
--
-- This foldexpr bypasses treesitter folds entirely for markdown and computes
-- fold levels directly from heading syntax:
--   - Heading lines (# / ## / ### etc.) open a fold at their depth
--   - Everything else continues at the current heading depth
--
-- Behavior:
--   - All heading levels fold independently and nest correctly
--   - Lists, paragraphs, code blocks, etc. do NOT create spurious folds
--   - zM / zR / zm / zr all work as expected

function M.foldexpr(lnum)
  local line = vim.fn.getline(lnum)

  local hashes = line:match("^(#+)%s")
  if hashes then
    return ">" .. #hashes
  end

  return "="
end

function M.setup()
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr   = "v:lua.require('config.markdown_folds').foldexpr(v:lnum)"
end

return M
