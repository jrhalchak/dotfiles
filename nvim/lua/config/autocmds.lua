local options = require"config.opts"
local M = {}

local groupopts = { clear = true }
local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

M.setup = function()
  --[[ Lua Autocmd Example
  -- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  --   pattern = {"*.c", "*.h"},
  --   callback = function(ev)
  --     print(string.format('event fired: %s', vim.inspect(ev)))
  --   end
  -- })
  --]]

  -- ============================================================
  -- Help
  -- ============================================================
  augroup("OpenHelpInTab", groupopts)
  -- NOTE This applies to any *.txt file, which I don't use 
  -- (intentionally) myself so it will open any help txt in a new
  -- tab. If any help is triggered again it can cause notice
  -- messages since help is confined to 1 window and the buffers
  -- aren't treated as separate "real' buffers
  autocmd("BufEnter", {
    group = "OpenHelpInTab",
    pattern = "*.txt",
    command = "wincmd T"
  })

  -- ============================================================
  -- General helpers / Common behaviors
  -- ============================================================
  -- Highlight on yank
  augroup('YankHighlight', { clear = true })
  autocmd('TextYankPost', {
    group = 'YankHighlight',
    callback = function()
      vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
    end
  })

  -- Remove whitespace on save
  autocmd('BufWritePre', {
    pattern = '',
    command = ":%s/\\s\\+$//e"
  })

  -- Don't auto commenting new lines
  autocmd('BufEnter', {
    pattern = '',
    command = 'set fo-=c fo-=r fo-=o'
  })


  -- ============================================================
  -- Filetype-specific settings
  -- ============================================================
  augroup("DisableColorColumn", groupopts)
  autocmd("Filetype", {
    group = "DisableColorColumn",
    pattern = { "help", "markdown", "json" },
    callback = options.disable_colorcolumn,
  })
end

return M
