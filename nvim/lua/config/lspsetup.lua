vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', {clear = true}),
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
    vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
  end,
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'vtsls', 'bashls', 'awk_ls', 'clangd', 'cmake', 'css_variables',
    'cssls', 'cssmodules_ls', 'tailwindcss', 'docker_compose_language_service',
    'dockerls', 'jinja_lsp', 'ast_grep', 'html', 'biome', -- 'denols',
    'typos_lsp', 'harper_ls', 'eslint', 'yamlls', 'lwc_ls', 'jsonls', 'lua_ls',
    'marksman', 'perlnavigator', 'pyright', 'ruff', 'sqls', 'vimls',
    'custom_elements_ls'

    -- 'ts_ls',
    -- textlsp | Grammar/spellcheck w/ AI integrations, needs config
  },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({
        capabilities = lsp_capabilities,
      })
    end,
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        capabilities = lsp_capabilities,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT'
            },
            diagnostics = {
              globals = {'vim'},
            },
            workspace = {
              library = {
                vim.env.VIMRUNTIME,
              }
            }
          }
        }
      })
    end,
    vtsls = function()
      require('lspconfig').vtsls.setup({
        capabilities = lsp_capabilities,
        settings = {
          typescript = {
            tsdk = "./node_modules/typescript/lib",
          },
          vtsls = {
            autoUseWorkspaceTsdk = true,
          },
        },
      })
    end,
    -- ts_ls = function()
    --   require('lspconfig').tsserver.setup({
    --     -- Use node_modules version
    --     cmd = { "node", "./node_modules/.bin/tsserver", "--stdio" }
    --   })
    -- end,
  }
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local constants = require('config.constants')

cmp.setup({
  sources = cmp.config.sources({
    {name = 'nvim_lsp'},
    {name = 'luasnip'},
  }, {
    {name = 'buffer'},
  }, {
    {
      name="lazydev",
      group_index = 0,
    }
  }),
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({select = true}),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  formatting = {
    fields = { "kind", "abbr" },
    format = function(_, vim_item)
      vim_item.kind = constants.CMP_KIND_ICONS[vim_item.kind] or ""
      return vim_item
    end,
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})
