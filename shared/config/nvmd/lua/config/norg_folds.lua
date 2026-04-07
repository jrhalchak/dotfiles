local M = {}

-- Custom foldexpr for norg files.
--
-- Neovim's treesitter fold engine mishandles nested @fold captures: when a
-- ranged_verbatim_tag (@data meta ... @end) is a child of a heading node,
-- both are marked @fold in neorg's folds.scm. The fold engine loses track of
-- the outer heading fold once the inner tag fold closes, causing headings to
-- fold incorrectly and list items to sprout unexpected folds.
--
-- This foldexpr bypasses treesitter folds entirely for norg and computes fold
-- levels directly from the raw text:
--   - Heading lines (* / ** / ***  etc.) open a fold at their depth
--   - @data meta ... @end blocks fold at heading-depth + 1
--   - Everything else continues at the current heading depth
--
-- Neorg behavior that is preserved:
--   - All heading levels fold independently and nest correctly
--   - @data meta blocks fold as a unit within their heading
--   - List items, paragraphs, etc. do NOT create spurious folds
--   - zM / zR / zm / zr all work as expected

function M.foldexpr(lnum)
  local line = vim.fn.getline(lnum)

  local stars = line:match("^(%*+)%s")
  if stars then
    return ">" .. #stars
  end

  if line:match("^%s+@%w+") or line:match("^@%w+") then
    local heading_level = M._current_heading_level(lnum)
    return ">" .. (heading_level + 1)
  end

  if line:match("^%s+@end%s*$") or line:match("^@end%s*$") then
    local heading_level = M._current_heading_level(lnum)
    return "<" .. (heading_level + 1)
  end

  return "="
end

function M._current_heading_level(lnum)
  for i = lnum - 1, 1, -1 do
    local l = vim.fn.getline(i)
    local stars = l:match("^(%*+)%s")
    if stars then
      return #stars
    end
  end
  return 0
end

function M.setup()
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr   = "v:lua.require('config.norg_folds').foldexpr(v:lnum)"
end

return M
