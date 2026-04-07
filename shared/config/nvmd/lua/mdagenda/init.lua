-- mdagenda/init.lua
-- Public API: setup(config), open(), refresh(), close().
-- This is the only module external code should require.

local M = {}

-- Called once from the plugin spec (or user config).
-- @param opts table  merged into config.defaults
function M.setup(opts)
  require("mdagenda.config").setup(opts or {})
  require("mdagenda.highlights").setup()
  require("mdagenda.highlights").attach_autocmd()

  -- BufWritePost autocmd: refresh panel if it's open.
  vim.api.nvim_create_autocmd("BufWritePost", {
    group   = vim.api.nvim_create_augroup("MdAgendaAutoRefresh", { clear = true }),
    pattern = "*.md",
    callback = function()
      local ui = require("mdagenda.ui")
      local s  = require("mdagenda.state")
      if s.win and vim.api.nvim_win_is_valid(s.win) then
        ui.refresh()
      end
    end,
  })
end

function M.open()
  require("mdagenda.ui").open()
end

function M.close()
  require("mdagenda.ui").close()
end

function M.refresh()
  require("mdagenda.ui").refresh()
end

-- Toggle: open if closed, focus if open.
function M.toggle()
  local s = require("mdagenda.state")
  local ui = require("mdagenda.ui")
  if s.win and vim.api.nvim_win_is_valid(s.win) then
    -- If already focused, close it; otherwise focus it.
    if vim.api.nvim_get_current_win() == s.win then
      ui.close()
    else
      vim.api.nvim_set_current_win(s.win)
    end
  else
    ui.open()
  end
end

return M
