-- mdagenda/config.lua
-- Holds user configuration after setup() is called.

local M = {}

M.defaults = {
  vaults = {
    notes = vim.fn.expand("~/vault/notes"),
    omni  = vim.fn.expand("~/vault/omni"),
    work  = vim.fn.expand("~/vault/work"),
  },
  -- Side panel width (columns). nil = winwidth / 4, minimum 40.
  panel_width = nil,
}

M.values = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

-- Return a list of { name, path } for all configured vaults.
function M.vault_list()
  local out = {}
  for name, path in pairs(M.values.vaults) do
    table.insert(out, { name = name, path = path })
  end
  table.sort(out, function(a, b) return a.name < b.name end)
  return out
end

-- Derive vault name from a file path. Returns nil if path is outside all vaults.
function M.vault_for_path(path)
  for name, root in pairs(M.values.vaults) do
    local expanded = vim.fn.expand(root)
    if path:sub(1, #expanded) == expanded then
      return name
    end
  end
  return nil
end

return M
