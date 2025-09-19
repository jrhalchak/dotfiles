local keymaps = require("config.keymaps")
local utils = require("config.utils")

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
      -- 'custom_elements_ls',

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

            if server_name == "custom_elements_ls" and not is_real_file(bufnr) then
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
      -- ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
          utils.update_cmp_sel() -- custom kind highlights
        else
          fallback()
        end
      end, { 'i', 's' }),
      -- ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
          utils.update_cmp_sel() -- custom kind highlights
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<CR>'] = cmp.mapping(function(fallback)
        if cmp.visible() and cmp.get_selected_entry() then
          cmp.confirm({ select = false })
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-Space>'] = cmp.mapping(function(_) -- param is fallback for inserting newline
        if cmp.visible() then
          cmp.abort()
        else
          cmp.complete()
        end
      end, { 'i', 'c' }),
    }),
    window = {
      completion = {
        col_offset = -3,
        side_padding = 1,
        -- This character/highlight combo is undocumented, but supported
        border = {
          { "╭", "CmpBorder" },
          { "─", "CmpBorder" },
          { "╮", "CmpBorder" },
          { "│", "CmpBorder" },
          { "╯", "CmpBorder" },
          { "━", "CmpBorder" },
          { "╰", "CmpBorder" },
          { "│", "CmpBorder" },
        },
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
        scrollbar = true
      },
      documentation = {
        -- This character/highlight combo is undocumented, but supported
        border = {
          { "╭", "CmpBorder" },
          { "╌", "CmpBorder" },
          { "╮", "CmpBorder" },
          { "┆", "CmpBorder" },
          { "╯", "CmpBorder" },
          { "╍", "CmpBorder" },
          { "╰", "CmpBorder" },
          { "┆", "CmpBorder" },
        },
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
        scrollbar = "󰇙"
      }
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, item)
        local kinds = constants.CMP_KINDS
        local icon = kinds[item.kind].icon

        -- set highlihgt group before overriding
        item.kind_hl_group = "CmpItemKind" .. item.kind

        item.kind = icon and " " .. icon .. " " or "   "

        item.menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[LaTeX]",
        })[entry.source.name]

        return item
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
