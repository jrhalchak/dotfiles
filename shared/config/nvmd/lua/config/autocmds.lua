local options = require "config.opts"
local M = {}

local groupopts = { clear = true }
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

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

  -- Only open actual help files in new tabs, not all .txt files
  autocmd("FileType", {
    group = "OpenHelpInTab",
    pattern = "help",
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
      vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 1000 })
    end
  })

  -- Remove whitespace on save
  autocmd('BufWritePre', {
    pattern = '*',
    command = ":%s/\\s\\+$//e"
  })

  -- Don't auto commenting new lines
  autocmd('BufEnter', {
    pattern = '*',
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

  augroup("NeorgFileType", groupopts)
  autocmd("Filetype", {
    group = "NeorgFileType",
    pattern = { "norg" },
    callback = function()
      vim.wo.foldlevel    = 99
      vim.wo.conceallevel = 3
      options.disable_colorcolumn()
      require("config.norg_folds").setup()
    end,
  })

  augroup("MarkdownFileType", groupopts)
  autocmd("Filetype", {
    group = "MarkdownFileType",
    pattern = { "markdown" },
    callback = function(ev)
      require("config.markdown_folds").setup()
      require("config.keymaps").setup_markdown(ev.buf)
    end,
  })
end

return M
