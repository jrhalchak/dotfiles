local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  print(vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }))
end
vim.opt.rtp:prepend(lazypath)

--------------------------------
-- Mapping setup
--------------------------------
local isMac = vim.loop.os_uname().sysname == "Darwin"

local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Remap leader to <Space>
map('', '<Space>', '<Nop>')
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- set background for colorscheme
-- vim.opt.background = "light"
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus"

--------------------------------
-- /Mapping setup
--------------------------------

require('lazy').setup({
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- this plugin needs to run before anything else
    config = true,
    opts = {
      rocks = { "magick" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                          , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    priority = 999,
    lazy = false
  },
  -- neorg link-length-fix plugin w/ no config
  { "benlubas/neorg-conceal-wrap" },
  {
    'nvim-neorg/neorg',
    priority = 999,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'luarocks.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-neorg/neorg-telescope'
    },
    version = "*",
    config = function()
      local dirman_config = {
        config = {
          workspaces = {
            omni = '~/neorg/omni',
            work = '~/neorg/work',
            notes = '~/neorg/notes',
          },
          default_workspace = os.getenv('NEORG_DW') or 'omni',
        },
      }
      local opts = {
        load = {
          ['core.journal'] = {
            config = { strategy = 'flat' },
          },
          ['core.defaults'] = {},
          ['core.ui.calendar'] = {},
          ['core.autocommands'] = {},
          ['core.neorgcmd'] = {},
          ['core.keybinds'] = {
            config = { norg_leader = '<leader>' },
          },
          ['core.export'] = {
            config = { export_dir = '~/neorg/exports/' },
          },
          ['core.concealer'] = {
            config = {
              -- icon_preset = 'diamond',
              icons = {
                heading = {
                  -- icons = { "◈", "◇", "◆", "", "❖", "" },
                  -- icons = { "󰉫", "󰉬", "󰉭", "󰉮", "󰉯", "󰉰" },
                  icons = { "", "", "󰔶", "", "󰜁", "" },
                },

                footnote = {
                  single = {
                    icon = "†",
                  },
                  multi_prefix = {
                    icon = "‡ ",
                  },
                  multi_suffix = {
                    icon = "‡ ",
                  },
                },
                -- list = { icons = { "" } },
                -- list = { icons = { "" } },
                -- list = { icons = { "⁃" } },
                list = { icons = { "→" } },
              }
            },
          },
          ['core.dirman'] = dirman_config,
          ['core.completion'] = {
            config = {
              engine = 'nvim-cmp',
              name = '[Norg]',
            },
          },
          ['core.summary'] = {
            config = {
              strategy = 'by_path',
            },
          },
          ["core.integrations.telescope"] = {
            config = {
              insert_file_link = {
                -- Whether to show the title preview in telescope. Affects performance with a large
                -- number of files.
                show_title_preview = true,
              }
            }
          },
          -- link-length-fix plugin
          ["external.conceal-wrap"] = {},
        }
      }

      require('neorg').setup(opts)

      require("neorg_todos")

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 3

      vim.cmd('cd ' .. dirman_config.config.workspaces[dirman_config.config.default_workspace])
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },
  {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require('cmp')
      cmp.setup {
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn['UltiSnips#Anon'](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
            { name = 'neorg' },
            -- { name = 'nvim_lsp' },
            -- { name = 'vsnip' }, -- For vsnip users.
            -- { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
          },
          {
            { name = 'buffer' },
          })
      }
    end
  },
  {
    '3rd/image.nvim',
    dependencies = {
      "kiyoon/magick.nvim"
    },
    config = function()
      -- Image.nvim luarocks magick
      -- Example for configuring Neovim to load user-installed installed Lua rocks:
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

      require('image').setup({
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { 'markdown', 'vimwiki' }, -- markdown extensions (ie. quarto) can go here
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { 'norg' },
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
        editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
        auto_clear = true,
        hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' }, -- render image files as images when opened
      })
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = { enable = true },
    },
  },
  {
    "RRethy/base16-nvim",
    lazy = false,
    config = function()
      vim.cmd[[
        hi Normal guibg=NONE ctermbg=NONE

        " colorscheme base16-tokyo-city-dark
        " colorscheme base16-tokyo-city-light
        " colorscheme base16-tokyo-city-terminal-dark
        " colorscheme base16-tokyo-city-terminal-light

        colorscheme base16-tokyo-night-dark

        " colorscheme base16-tokyo-night-light
        " colorscheme base16-tokyo-night-moon
        " colorscheme base16-tokyo-night-storm
        " colorscheme base16-tokyo-night-terminal-dark
        " colorscheme base16-tokyo-night-terminal-light
        " colorscheme base16-tokyo-night-terminal-storm

        " colorscheme base16-tokyodark

        " colorscheme base16-tokyodark-terminal
        " colorscheme base16-ayu-dark
      ]]
      print("in base16 setup")
    end
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function()
      local wk = require('which-key')

      -- Normal Mode Bindings
      wk.register({
        {
          name = 'Win resize',
          ['<up>'] = { ':resize -2<CR>', '+/- Win v-size' },
          ['<down>'] = { ':resize +2<CR>', '+/- Win v-size' },
          ['<left>'] = { ':vertical resize -2<CR>', '+/- Win h-size' },
          ['<right>'] = { ':vertical resize +2<CR>', '+/- Win h-size' },
        },
        {
          name = 'Win traversal',
          ['<C-h>'] = { '<C-w>h', 'Move left' },
          ['<C-j>'] = { '<C-w>j', 'Move right' },
          ['<C-k>'] = { '<C-w>k', 'Move up' },
          ['<C-l>'] = { '<C-w>l', 'Move down' },
        },
        {
          name = 'Buffer switching',
          L = { ':bnext<CR>', 'Next buffer' },
          H = { ':bprevious<CR>', 'Previous buffer' },
        },
        {
          name = 'Tab traversal',
          [isMac and 'Ò' or '<A-L>'] = { ':tabn<CR>', 'Next tab' },
          [isMac and 'Ó' or '<A-H>'] = { ':tabp<CR>', 'Previous tab' },
        },
        {
          name = 'Move lines',
          [isMac and '∆' or '<A-j>'] = { '<Esc>:m .+1<CR>==gi', 'Move line up' },
          [isMac and '˚' or '<A-k>'] = { '<Esc>:m .-2<CR>==gi', 'Move line down' },
        },
        ['<leader>'] = {
          h = { ':nohl<CR>', 'Clear highlights' },
          t = {
            name = 'Split Orientation',
            k = { '<C-w>t<C-w>K', 'V to H' },
            h = { '<C-w>t<C-w>H', 'H to V' },
          },
          lf = { '<cmd>lua vim.lsp.buf.format{ async = true }<cr>', 'Format buffer' },
          e = { ':NvimTreeToggle<CR>', 'Toggle NvimTree' },
          f = {
            name = 'Telescope',
            f = { ':Telescope find_files<CR>', 'Find files' },
            l = { ':Telescope find_linkable<CR>', 'Find linkable' },
            i = { ':Telescope insert_file_link<CR>', 'Find/Insert link' },
            h = { ':Telescope search_headings<CR>', 'Search headings (file)' },
            g = { ':Telescope live_grep<CR>', 'Grep files' },
            b = { ':Telescope find_backlinks<CR>', 'Find backlinks' },
            a = { ':Telescope find_header_backlinks<CR>', 'Find all backlinks (headers incl)' }
          },
	  z = {
	    name = 'Fold levels',
	    ['0'] = { ':set foldlevel=0<CR>', 'Set fold lvl 0' },
	    ['1'] = { ':set foldlevel=1<CR>', 'Set fold lvl 1' },
	    ['2'] = { ':set foldlevel=2<CR>', 'Set fold lvl 2' },
	    ['3'] = { ':set foldlevel=3<CR>', 'Set fold lvl 3' },
	    ['4'] = { ':set foldlevel=4<CR>', 'Set fold lvl 4' },
	    ['5'] = { ':set foldlevel=5<CR>', 'Set fold lvl 5' },
	    ['6'] = { ':set foldlevel=6<CR>', 'Set fold lvl 6' },
	    ['7'] = { ':set foldlevel=7<CR>', 'Set fold lvl 7' },
	    ['8'] = { ':set foldlevel=8<CR>', 'Set fold lvl 8' },
	    ['9'] = { ':set foldlevel=9<CR>', 'Set fold lvl 9' },
	  },
          m = {
            name = 'Neorg Mode',
            h = { ':Neorg mode traverse-heading<CR>', 'Traverse headings' },
            n = { ':Neorg mode norg<CR>', 'Normal norg traversal' },
            l = { ':Neorg mode traverse-link<CR>', 'Traverse links' },
          },
          j = {
            name = 'Neorg Journal',
            c = { ':Neorg journal custom<CR>', 'Custom entry calendar picker' },
            t = { ':Neorg journal today<CR>', 'Today\'s entry' },
            n = { ':Neorg journal tomorrow<CR>', '(Next) Tomorrow\'s entry' },
            p = { ':Neorg journal yesterday<CR>', '(Prev) Yesterday\'s entry' },
            io = { ':Neorg journal toc open<CR>', '(Open) Journal Index' },
            iu = { ':Neorg journal toc update<CR>', '(Update) Journal Index' },
          },
          i = { ':Neorg index<CR>', 'Index' },
          I = { ':Neorg inject-metadata<CR>', 'Inject metadata' },
          o = { ':OpenTodos<CR>', 'Open outstanding todos' },
        },
      }, { mode = "n" })

      -- Helper for sync scrolling and Diffing
      -- Mark current buffer for syncing view
      -- map('n', '<leader>wv', ':set scb<CR>')
      -- Mark current buffer for diffing
      -- map('n', '<leader>wd', ':diffthis<CR>')

      -- Visual Mode Bindings
      wk.register({
        {
          name = 'Horizontal scrolling',
          zL = { 'zL', 'Scroll right '},
          zH = { 'zH', 'Scroll left '},
        },
        p = { '"_dP', 'Better paste' },
        ['<'] = { '<gv', 'Better decrease indent'},
        ['>'] = { '>gv', 'Better increase indent'},
        [';'] = { ':', 'Command in visual mode' },
      }, { mode = "v" })
    end
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      'nvim-neorg/neorg',
    },
    dir = vim.fn.stdpath("config") .. "/pack/dev/start/bdiagram",
    name = "bdiagram",
    build = "make install",
    lazy = false,
    config = function()
      require("bdiagram").setup()
    end,
  }
})

-- vim.cmd('Neorg index')
vim.cmd('set cursorline')
vim.cmd('set relativenumber')

-- Remap ; to : in visual mode
map('v', '<leader>f0', ':set foldlevel=0<CR>')
map('v', '<leader>f1', ':set foldlevel=1<CR>')
map('v', '<leader>f2', ':set foldlevel=2<CR>')
map('v', '<leader>f3', ':set foldlevel=3<CR>')
map('v', '<leader>f4', ':set foldlevel=4<CR>')
map('v', '<leader>f5', ':set foldlevel=5<CR>')
map('v', '<leader>f6', ':set foldlevel=6<CR>')
map('v', '<leader>f7', ':set foldlevel=7<CR>')
map('v', '<leader>f8', ':set foldlevel=8<CR>')
map('v', '<leader>f9', ':set foldlevel=9<CR>')
