local genplugs = require"plugs.general"
local orgplugs = require"plugs.orgmode"

return vim.list_extend(genplugs, orgplugs)
