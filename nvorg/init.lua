local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  print(vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }))
end
vim.opt.rtp:prepend(lazypath)

--------------------------------
-- Mapping setup
--------------------------------
local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Remap leader to <Space>
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- set background for colorscheme
-- vim.opt.background = "light"
vim.opt.background = "dark"

--------------------------------
-- /Mapping setup
--------------------------------
require"lazy".setup(
  require"allplugins"
)

-- open workspace index on start
-- vim.cmd("index")
vim.cmd[[
  set cursorline
  set relativenumber
  set conceallevel=2
  set conceallevel=nc
]]

