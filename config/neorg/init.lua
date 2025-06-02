--
-- TODO
-- Setup custom concealers for links and such: https://www.youtube.com/watch?v=8fCkt5qgHw8
-- More about treesitter here: https://www.youtube.com/watch?v=09-9LltqWLY
--

--
-- TODO
-- From the neorg discord in response to me asking about querying the tree:
-- You can query the treesitter tree. There's a query language (the scm you mention) and a few functions. :h treesitter-query for query basics, :h vim.treesitter.query.parse() for parsing a query :h lua-treesitter-query to see what you can do with that
--

--
-- In the future if you use separate configs on the code side, checkout Neovim config switcher
--

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
        editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
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
    lazy = true,
    config = function()
      vim.cmd[[
        hi Normal guibg=NONE ctermbg=NONE

        # colorscheme base16-tokyo-city-dark
        # colorscheme base16-tokyo-city-light
        # colorscheme base16-tokyo-city-terminal-dark
        # colorscheme base16-tokyo-city-terminal-light

        colorscheme base16-tokyo-night-dark

        # colorscheme base16-tokyo-night-light
        # colorscheme base16-tokyo-night-moon
        # colorscheme base16-tokyo-night-storm
        # colorscheme base16-tokyo-night-terminal-dark
        # colorscheme base16-tokyo-night-terminal-light
        # colorscheme base16-tokyo-night-terminal-storm

        # colorscheme base16-tokyodark

        # colorscheme base16-tokyodark-terminal
        # colorscheme base16-ayu-dark
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
        f = {
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
        }
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
})

-- TODO
-- to update runtimepath when passing in the config
-- to use (like with neorg alias)
local buf, win, start_win

-- local function open()
--   local path = vim.api.nvim_get_current_line()
--
--   if vim.api.nvim_win_is_valid(start_win) then
--     vim.api.nvim_set_current_win(start_win)
--     vim.api.nvim_command('edit ' .. path)
--   else
--     vim.api.nvim_command('botright vsplit ' .. path)
--     start_win = vim.api.nvim_get_current_win()
--   end
-- end
--
-- local function close()
--   if win and vim.api.nvim_win_is_valid(win) then
--     vim.api.nvim_win_close(win, true)
--   end
-- end
--
-- local function open_and_close()
--   open()
--   close()
-- end
--
-- local function preview()
--   open()
--   vim.api.nvim_set_current_win(win)
-- end
--
-- local function split(axis)
--   local path = vim.api.nvim_get_current_line()
--
--   if vim.api.nvim_win_is_valid(start_win) then
--     vim.api.nvim_set_current_win(start_win)
--     vim.api.nvim_command(axis ..'split ' .. path)
--   else
--     vim.api.nvim_command('botright ' .. axis..'split ' .. path)
--   end
--
--   close()
-- end
--
-- local function open_in_tab()
--   local path = vim.api.nvim_get_current_line()
--
--   vim.api.nvim_command('tabnew ' .. path)
--   close()
-- end

local neorg = require('neorg.core')

--- Get a list of all norg files in current workspace. Returns { workspace_path, norg_files }
--- @return table|nil
-- local function get_norg_files()
--     local dirman = neorg.modules.get_module('core.dirman')
--
--     if not dirman then
--         return nil
--     end
--
--     local current_workspace = dirman.get_current_workspace()
--
--     local norg_files = dirman.get_norg_files(current_workspace[1])
--
--     return { current_workspace[2], norg_files }
-- end

local function split_str(input_str, sep)
  if sep == nil then
    sep = '%s'
  end

  local sep_index = string.find(input_str, sep) or 0

  return {
    string.sub(input_str, 0, sep_index),
    string.sub(input_str, sep_index + 1, #input_str),
  }
end

-- TODO: add a boolean to "regrep" the results and rebuild it, otherwise we
-- can just use it as a render method so it doesn't re-pull and modify
-- everything again
local function redraw()
  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })

  local dirman = neorg.modules.get_module('core.dirman')

  if not dirman then
    return nil
  end

  local files = {}
  local workspace = dirman.get_current_workspace();

  local result = vim.fn.systemlist('rg "[-~] \\([^(x|_)]\\)" '.. workspace[2] .. '/**/*.norg')
  local win_width = vim.api.nvim_win_get_width(win)

  for k in pairs(result) do
    local item = split_str(result[k], ':')
    local path = vim.trim(string.gsub(item[1], workspace[2] .. '/', ''))
    local output = vim.trim(item[2])

    if files[path] and type(files[path]) == 'table' then
      table.insert(files[path], output)
    elseif files[path] then
      files[path] = {
        files[path]
      }
      table.insert(files[path], output)
    else
      files[path] = output
    end
  end

  local lines = {
    '',
    '',
    '    * Outstanding Todos',
    '',
    '',
  }

  -- print(vim.inspect(files))

  function append_line(ln)
    local line_pad = '      '
    local cutoff = win_width - (#line_pad * 2)
    local line_item = ln:sub(0, cutoff)

    if #ln > cutoff then
      line_item = line_item .. ''
    end

    table.insert(lines, line_pad .. line_item)
  end

  -- TODO: Change this to use 1 table with lines and files that can be used
  -- to insert the entry, but also to grab the file path based on line # when
  -- <CR> is pressed
  for k,v in pairs(files) do
    -- header
    table.insert(lines, '    ** ' .. k);

    -- todos
    if type(v) == 'table' then
      for _,ln in pairs(v) do
        append_line(ln)
      end
    else
      append_line(v)
    end

    -- spacer line
    table.insert(lines, '')
  end

  if #result == 0 then
    local line_start = math.floor(vim.api.nvim_win_get_height(win) / 2) - 1
    local title = '* */No Outstanding Todos/* 🎉'
    local left_offset = math.floor(win_width / 2) - math.floor(string.len(title) / 2)

    lines = {}

    for i=1,line_start do
      table.insert(lines, '')
    end
    table.insert(lines, string.rep(' ', left_offset) .. title)
  end


  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })

  -- local items_count =  vim.api.nvim_win_get_height(win) - 1
  -- local res = {}
  -- local files = get_norg_files()
  --
  -- if not files or not files[2] then
  --   return
  -- end
  --
  -- local ts = neorg.modules.get_module('core.integrations.treesitter')
  --
  -- for _, file in pairs(files[2]) do
  --   local bufnr = dirman.get_file_bufnr(file)
  --
  --   local title = nil
  --   local title_display = ''
  --   if ts then
  --     local metadata = ts.get_document_metadata(bufnr)
  --     if metadata and metadata.title then
  --       title = metadata.title
  --       title_display = ' [' .. title .. ']'
  --     end
  --   end
  --
  --   if vim.api.nvim_get_current_buf() ~= bufnr then
  --     local links = {
  --       file = file,
  --       display = '$' .. file:sub(#files[1] + 1, -1) .. title_display,
  --       relative = file:sub(#files[1] + 1, -1):sub(0, -6),
  --       title = title,
  --     }
  --     table.insert(res, links)
  --   end
  -- end

  -- for i = #oldfiles, #oldfiles - items_count, -1 do
  --   pcall(function()
  --     local path = vim.api.nvim_call_function('fnamemodify', {oldfiles[i], ':.'})
  --     table.insert(list, #list + 1, path)
  --   end)
  -- end
  --
  -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
  -- vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function set_mappings()
  local mappings = {
    q = 'close()',
    ['<cr>'] = 'open_and_close()',
    v = 'split("v")',
    s = 'split("")',
    p = 'preview()',
    t = 'open_in_tab()'
  }

  for k,v in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"nvim-oldfile".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

local function create_win()
  start_win = vim.api.nvim_get_current_win()

  -- 2/5ths?
  local width = math.ceil(vim.api.nvim_win_get_width(start_win) / 5 * 2);
  vim.api.nvim_command('botright ' .. width .. ' vnew')

  win = vim.api.nvim_get_current_win()
  buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_name(0, 'Todos #' .. buf)

  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = 0 })
  vim.api.nvim_set_option_value('swapfile', false, { buf = 0 })
  vim.api.nvim_set_option_value('filetype', 'norg', { buf = 0 })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = 0 })

  -- vim.api.nvim_command('setlocal nowrap')
  vim.api.nvim_command('setlocal cursorline')

  set_mappings()
end

local function todos()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  else
    create_win()
  end

  redraw()
end

-- open workspace index on start
vim.cmd('Neorg index')
vim.cmd('set cursorline')
vim.cmd('set relativenumber')

todos()

local function debounce(fn)
  local timer = vim.loop.new_timer()

  return function(...)
    local argv = {...}
    local argc = select('#', ...)

    timer:start(500, 0, function()
      pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
    end)
  end, timer
end

-- vim.api.nvim_create_autocmd("VimResized", { callback = redraw })
vim.api.nvim_create_autocmd("WinResized", {
  callback = debounce(redraw)
})

--
-- TODO
-- When you add git, use this for the commit timestamp:
-- date --rfc-3339=seconds
-- Like:
-- eval "git commit --amend -m \"$(date --rfc-3339=seconds)\""
-- NOTE: You'll need to use gdate if on MacOS to keep the same command/ouput
--

--
-- TODO
-- Look at https://github.com/jbyuki/venn.nvim
--

--
-- TODO
-- Look at https://github.com/nvim-neorocks/rocks.nvim
--


vim.api.nvim_create_user_command('OpenTodos', todos, {})

-- vim.api.nvim_create_autocmd({ 'BufWritePost', 'FileWritePost'}, {
--   pattern = { '*.norg' },
--   callback = todos,
-- })

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
