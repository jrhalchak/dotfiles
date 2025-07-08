local neorg = require('neorg.core')
local dirman = neorg.modules.get_module('core.dirman')

local M = {}

function M.find_files(workspace)
  if not dirman then
    return nil
  end

  return vim.fn.systemlist(
    'rg "[-~] \\([^(x|_)]\\)" '.. workspace[2] .. '/**/*.norg'
  )
end

return M
