local M = {}

local g = vim.g       -- Global variables
local opt = vim.opt   -- Set options (global/buffer/windows-scoped)

-- ============================================================
-- Utilities / Callbaccks
-- ============================================================
M.disable_colorcolumn = function()
  -- Disable line-length column
  opt.colorcolumn = ""
end

M.set_full_conceal = function()
  opt.conceallevel = 3
end

-- ============================================================
-- Setup
-- ============================================================
M.setup = function()
  -- ============================================================
  -- General
  -- ============================================================
  opt.mouse = "a"                                -- Enable mouse support
  opt.clipboard = "unnamedplus"                  -- Use system clipboard
  opt.swapfile = false                           -- Don"t use swapfile
  opt.completeopt = "menuone,noinsert,noselect"  -- Autocomplete options

  -- ============================================================
  -- Neovim UI
  -- ============================================================
  opt.number = true           -- Show line numbers
  opt.relativenumber = true   -- Make line relative numbers
  opt.showmatch = true        -- Highlight matching parenthesis
  opt.foldmethod = "marker"   -- Enable folding (default "foldmarker")
  opt.colorcolumn = "80"      -- Line length marker at 80 columns
  opt.splitright = true       -- Vertical split to the right
  opt.splitbelow = true       -- Horizontal split to the bottom
  opt.ignorecase = true       -- Ignore case letters when search
  opt.smartcase = true        -- Ignore lowercase for the whole pattern
  opt.linebreak = true        -- Wrap on word boundary
  opt.termguicolors = true    -- Enable 24-bit RGB colors
  opt.laststatus = 3          -- Set global statusline

  -- ============================================================
  -- Netrw
  -- ============================================================
  g.netrw_banner = 0                  -- Disable the header banner
  g.netrw_sort_sequence = [[[\/]$,*]] -- Sort dirs first
  g.netrw_liststyle = 3               -- Tree view by default
  g.netrw_sizestyle = "H"             -- Human readable file size
  -- TODO this may be causing trouble?
  -- g.netrw_keepdir = 0                 -- Keep view/browse dir synced, avoid move error

  -- Patterns for hiding files, e.g. node_modules
  -- NOTE: this works by reading '.gitignore' file
  g.netrw_list_hide = vim.fn["netrw_gitignore#Hide"]()

  -- Preview files in a vertical split window
  -- vim.g.netrw_preview = 1

  -- Open files in split
  -- 0 : re-use the same window (default)
  -- 1 : horizontally splitting the window first
  -- 2 : vertically   splitting the window first
  -- 3 : open file in new tab
  -- 4 : act like "P" (ie. open previous window)
  -- g.netrw_browse_split = 4

  -- FROM DOOM
  -- See more https://github.com/doom-neovim/doom-nvim/blob/d878cd9a69eb86ad10177d3f974410317ab9f2fe/lua/doom/modules/features/netrw/init.lua

  -- Setup file operations commands
  -- TODO: figure out how to add these feature in Windows
  if package.config:sub(1, 1) == "/" then
    -- Enable recursive copy of directories in *nix systems
    vim.g.netrw_localcopydircmd = "cp -r"

    -- Enable recursive creation of directories in *nix systems
    vim.g.netrw_localmkdir = "mkdir -p"

    -- Enable recursive removal of directories in *nix systems
    -- NOTE: we use 'rm' instead of 'rmdir' (default) to be able to remove non-empty directories
    vim.g.netrw_localrmdir = "rm -r"
  end

  -- ============================================================
  -- Tabs, indent
  -- ============================================================
  opt.expandtab = true        -- Use spaces instead of tabs
  opt.shiftwidth = 2          -- Shift 4 spaces when tab
  opt.tabstop = 2             -- 1 tab == 4 spaces
  opt.smartindent = true      -- Autoindent new lines

  -- ============================================================
  -- Memory, CPU
  -- ============================================================
  opt.hidden = true           -- Enable background buffers
  opt.history = 100           -- Remember N lines in history
  -- This doesn't work with noice
  -- opt.lazyredraw = true       -- Faster scrolling
  opt.synmaxcol = 240         -- Max column for syntax highlight
  opt.updatetime = 250        -- ms to wait for trigger an event

  -- ============================================================
  -- Migrated
  -- ============================================================
  opt.backup = false                           -- creates a backup file
  opt.background = "dark"                      -- set background for colorscheme
  opt.cmdheight = 1                            -- more space in the neovim command line for displaying messages
  opt.completeopt = { "menuone", "noselect" }  -- mostly just for cmp
  opt.conceallevel = 0                         -- so that `` is visible in markdown files
  opt.fileencoding = "utf-8"                   -- the encoding written to a file
  opt.hlsearch = true                          -- highlight all matches on previous search pattern
  opt.pumheight = 10                           -- pop up menu height
  opt.showmode = false                         -- we don"t need to see things like -- INSERT -- anymore
  opt.showtabline = 1                          -- show tabs when there's >1
  opt.timeoutlen = 1000                        -- time to wait for a mapped sequence to complete (in milliseconds)
  opt.undofile = true                          -- enable persistent undo
  opt.writebackup = false                      -- if a file is being edited by another program (or was written to file while editing with another program) it is not allowed to be edited
  opt.cursorline = true                        -- highlight the current line
  opt.showcmd = false                          -- hide (partial) command in the last line of the screen (for performance)
  opt.ruler = false                            -- hide the line and column number of the cursor position
  opt.numberwidth = 4                          -- minimal number of columns to use for the line number {default 4}
  opt.signcolumn = "yes"                       -- always show the sign column, otherwise it would shift the text each time
  opt.scrolloff = 8                            -- minimal number of screen lines to keep above and below the cursor
  opt.sidescrolloff = 8                        -- minimal number of screen columns to keep to the left and right of the cursor if wrap is `false`
  -- opt.guifont = "monospace:h17"                -- the font used in graphical neovim applications
  opt.foldmethod = "expr"
  opt.foldexpr = "nvim_treesitter#foldexpr()"
  opt.foldlevel = 999
  -- TODO: This isn"t the proper place to set this
  -- nofoldenable = true

  -- Sub options
  opt.fillchars.eob=" "                        -- show empty lines at the end of a buffer as ` ` {default `~`}
  opt.shortmess:append "c"                     -- hide all the completion messages, e.g. "-- XXX completion (YYY)", "match 1 of 2", "The only match", "Pattern not found"
  opt.whichwrap:append("<,>,[,],h,l")          -- keys allowed to move to the previous/next line when the beginning/end of line is reached
  opt.iskeyword:append("-")                    -- treats words with `-` as single words
  opt.formatoptions:remove({ "c", "r", "o" })  -- This is a sequence of letters which describes how automatic formatting is to be done

  -- ============================================================
  -- Startup
  -- ============================================================
  -- Disable nvim intro
  -- opt.shortmess:append "sI"

  -- Disable builtin plugins
  local disabled_built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    -- "netrw",
    -- "netrwPlugin",
    -- "netrwSettings",
    -- "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
    "tutor",
    "rplugin",
    "synmenu",
    "optwin",
    "compiler",
    "bugreport",
    "ftplugin",
  }

  for _, plugin in pairs(disabled_built_ins) do
     g["loaded_" .. plugin] = 1
  end
end

return M
