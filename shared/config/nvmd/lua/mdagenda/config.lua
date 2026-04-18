-- mdagenda/config.lua
-- Holds user configuration after setup() is called.

local M = {}

M.defaults = {
  -- Environment variable whose value names the default vault (e.g. "omni").
  -- Set on a per-machine basis so the picker is skipped when not in a vault.
  -- Example: export ZK_DEFAULT_VAULT=omni
  default_vault_env = "ZK_DEFAULT_VAULT",
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

-- Return the default vault { name, path } from the configured env var, or nil.
function M.default_vault()
  local env_name = M.values.default_vault_env
  local val = env_name and vim.env[env_name]
  if not val or val == "" then return nil end
  local path = M.values.vaults[val]
  if not path then
    vim.notify(
      string.format("mdagenda: %s=%q does not match a configured vault", env_name, val),
      vim.log.levels.WARN
    )
    return nil
  end
  return { name = val, path = path }
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
