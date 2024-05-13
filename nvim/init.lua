local utils = require"utils"
local autocmds = require"core.autocmds"
local options = require"core.options"

-- ============================================================
-- Set leaders before lazy & plugins to ensure they"re correct
-- ============================================================
utils.keymap("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ============================================================
-- Setup lazy
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
require"lazy".setup("plugins", { --[[ options ]] });

-- ============================================================
-- Setup core modules
-- ============================================================
options.setup()
autocmds.setup()


