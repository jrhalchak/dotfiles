local genplugs = require"plugins.general"
local orgplugs = require"plugins.orgmode"

return vim.tbl_merge(genplugs, orgplugs)
