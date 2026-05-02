local M = {}

-- Markdown fold setup.
--
-- Uses treesitter's foldexpr (the same one your regular nvim uses).
-- Treesitter's markdown fold query trims trailing blank lines from each
-- section fold via `#trim!`, so blank lines between sections remain as
-- visible buffer lines and provide natural gaps between folded headings.
--
-- foldlevel=2: files open with h1+h2 visible, h3+ folded.

function M.setup()
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr   = "nvim_treesitter#foldexpr()"
  vim.wo.foldlevel  = 2
end

return M
