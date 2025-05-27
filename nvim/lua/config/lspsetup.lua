local keymaps = require("config.keymaps")

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', {clear = true}),
  callback = function(event)
    keymaps.setup_lsp(event.buf)
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
