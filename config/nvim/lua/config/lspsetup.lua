local keymaps = require("config.keymaps")

local M = {}

M.setup = function()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user_lsp_attach', {clear = true}),
    callback = function(event)
      -- Detach LSP if buffer is not a normal file
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
      local bufname = vim.api.nvim_buf_get_name(event.buf)
      if buftype ~= "" or bufname == "" then
        vim.schedule(function()
          local clients = vim.lsp.get_active_clients({ bufnr = event.buf })
          for _, client in ipairs(clients) do
            vim.lsp.buf_detach_client(event.buf, client.id)
          end
        end)
        return
      end

      keymaps.setup_lsp(event.buf)
    end,
  })

  local function is_real_file(bufnr)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    return buftype == "" and bufname ~= ""
  end

  local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

  require('mason').setup({})
  require('mason-lspconfig').setup({
    automatic_enable = true,
    ensure_installed = {
      'vtsls', 'bashls', 'clangd', 'cmake', 'css_variables',
      'cssls', 'cssmodules_ls', 'tailwindcss', 'docker_compose_language_service',
      'dockerls', 'jinja_lsp', 'ast_grep', 'html', 'biome', -- 'denols',
      'eslint', 'yamlls', 'lwc_ls', 'jsonls', 'lua_ls',
      'marksman', 'perlnavigator', 'pyright', 'ruff', 'sqls', 'vimls',
      'custom_elements_ls',

      -- test which to use
      -- 'harper_ls',
      'typos_lsp',

      -- 'awk_ls', -- Always fails to install and throws errors
      -- 'ts_ls',
      -- textlsp | Grammar/spellcheck w/ AI integrations, needs config
    },
    handlers = {
      function(server_name)
        require('lspconfig')[server_name].setup({
          capabilities = lsp_capabilities,
          autostart = function(bufnr)
            if vim.b[bufnr].lsp_disable then
              return false
            end

            return true
          end,
          on_init = function(client)
            local bufnr = vim.api.nvim_get_current_buf()
            if not is_real_file(bufnr) then
              client.stop()
              return false
            end
          end,
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
      {name = 'buffer'},
      {name = 'codecompanion'},
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
end

return M
