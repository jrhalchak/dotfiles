local workspaces = {
  omni  = '~/neorg/omni',
  work  = '~/neorg/work',
  notes = '~/neorg/notes',
}

local default_workspace = os.getenv('NEORG_DW') or 'omni'

local function pick_workspace()
  local pickers   = require('telescope.pickers')
  local finders   = require('telescope.finders')
  local conf      = require('telescope.config').values
  local actions   = require('telescope.actions')
  local astate    = require('telescope.actions.state')

  local entries = {}
  for name, path in pairs(workspaces) do
    table.insert(entries, { name = name, path = path })
  end
  table.sort(entries, function(a, b) return a.name < b.name end)

  pickers.new({}, {
    prompt_title  = 'Neorg Workspaces',
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value   = entry,
          display = entry.name .. '  ' .. entry.path,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local sel = astate.get_selected_entry()
        if sel then
          vim.cmd('Neorg workspace ' .. sel.value.name)
        end
      end)
      return true
    end,
  }):find()
end

return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1001,
    opts     = { rocks = { "magick" } },
    config   = function(_, opts)
      -- Newer versions of luarocks (3.11+) moved vendored deps (dkjson, compat53)
      -- from share/lua/5.1/ into share/lua/5.1/luarocks/vendor/. The luarocks-nvim
      -- plugin only adds the top-level share path to package.path, so require("luarocks.loader")
      -- fails when it tries to load compat53, which cascades into dkjson not being found.
      -- Explicitly prepend the vendor path so the embedded Lua environment can resolve them.
      local rocks_path = vim.fn.stdpath("data") .. "/lazy/luarocks.nvim/.rocks"
      package.path = package.path
        .. ";" .. rocks_path .. "/share/lua/5.1/luarocks/vendor/?.lua"
        .. ";" .. rocks_path .. "/share/lua/5.1/luarocks/vendor/?/init.lua"
      require("luarocks-nvim").setup(opts)
    end,
  },
  {
    "benlubas/neorg-conceal-wrap",
    lazy = true,
  },
  {
    "nvim-neorg/neorg-telescope",
    lazy = true,
  },
  {
    "kiyoon/magick.nvim",
    lazy = true,
  },
  {
    '3rd/image.nvim',
    dependencies = { "kiyoon/magick.nvim" },
    ft = { 'norg', 'markdown' },
    config = function()
      package.path = package.path
        .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
        .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

      require('image').setup({
        backend                        = 'kitty',
        editor_only_render_when_focused = true,
        tmux_show_only_in_active_window = true,
        auto_clear                     = true,
        max_height_window_percentage   = 50,
        window_overlap_clear_enabled   = false,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
        hijack_file_patterns           = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' },
        integrations = {
          markdown = {
            enabled                    = true,
            clear_in_insert_mode       = false,
            download_remote_images     = true,
            only_render_image_at_cursor = false,
            filetypes                  = { 'markdown', 'vimwiki' },
          },
          neorg = {
            enabled                    = true,
            clear_in_insert_mode       = false,
            download_remote_images     = true,
            only_render_image_at_cursor = false,
            filetypes                  = { 'norg' },
          },
        },
      })
    end,
  },
  {
    'nvim-neorg/neorg',
    priority     = 999,
    lazy         = false,
    version      = "*",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'vhyrro/luarocks.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-neorg/neorg-telescope',
      'benlubas/neorg-conceal-wrap',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('neorg').setup({
        load = {
          ['core.defaults']     = {},
          ['core.autocommands'] = {},
          ['core.neorgcmd']     = {},
          ['core.ui.calendar']  = {},
          ['core.journal'] = {
            config = { strategy = 'flat' },
          },
          ['core.keybinds'] = {
            config = { norg_leader = '<localleader>' },
          },
          ['core.export'] = {
            config = { export_dir = '~/neorg/exports/' },
          },
          ['core.concealer'] = {
            config = {
              icons = {
                heading = {
                  icons = { "", "", "󰔶", "", "󰜁", "" },
                },
                footnote = {
                  single      = { icon = "†" },
                  multi_prefix = { icon = "‡ " },
                  multi_suffix = { icon = "‡ " },
                },
                list = { icons = { "→" } },
              },
            },
          },
          ['core.dirman'] = {
            config = {
              workspaces       = workspaces,
              default_workspace = default_workspace,
            },
          },
          ['core.completion'] = {
            config = {
              engine = 'nvim-cmp',
              name   = '[Norg]',
            },
          },
          ['core.summary'] = {
            config = { strategy = 'by_path' },
          },
          ['core.integrations.telescope'] = {
            config = {
              insert_file_link = { show_title_preview = true },
            },
          },
          ['external.conceal-wrap'] = {},
        },
      })

      require('telescope').load_extension('neorg')

      require('neorg_todos')

      vim.keymap.set('n', '<leader>nw', pick_workspace, { desc = 'Neorg: Switch workspace' })
    end,
  },
  {
    dir    = vim.fn.stdpath("config") .. "/pack/dev/start/bdiagram",
    name   = "bdiagram",
    build  = "make install",
    lazy   = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      'nvim-neorg/neorg',
    },
    config = function()
      require("bdiagram").setup()
    end,
  },
}
