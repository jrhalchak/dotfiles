local constants = require"constants"

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      auto_install = true,
      ensure_installed = 'all',
      ignore_install = { 'org' },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.8",
    -- or                          , branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    priority = 999,
    lazy = false
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
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources(
          {
            { name = 'orgmode' },
            -- { name = "nvim_lsp" },
            -- { name = "vsnip" }, -- For vsnip users.
            -- { name = "luasnip" }, -- For luasnip users.
            -- { name = "ultisnips" }, -- For ultisnips users.
            -- { name = "snippy" }, -- For snippy users.
          },
          {
            { name = "buffer" },
          }
        )
      }
    end
  },
  {
  "RRethy/base16-nvim",
  lazy = true,
  config = function()
    vim.cmd[[
      hi Normal guibg=NONE ctermbg=NONE
      colorscheme base16-ayu-dark
    ]]
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
      local wk = require("which-key")

      -- Normal Mode Bindings
      wk.register({
        {
          name = "Win resize",
          ["<up>"] = { ":resize -2<CR>", "+/- Win v-size" },
          ["<down>"] = { ":resize +2<CR>", "+/- Win v-size" },
          ["<left>"] = { ":vertical resize -2<CR>", "+/- Win h-size" },
          ["<right>"] = { ":vertical resize +2<CR>", "+/- Win h-size" },
        },
        {
          name = "Win traversal",
          ["<C-h>"] = { "<C-w>h", "Move left" },
          ["<C-j>"] = { "<C-w>j", "Move right" },
          ["<C-k>"] = { "<C-w>k", "Move up" },
          ["<C-l>"] = { "<C-w>l", "Move down" },
        },
        ["<leader>"] = {
          h = { ":nohl<CR>", "Clear highlights" },
          -- e = { ":NvimTreeToggle<CR>", "Toggle NvimTree" },
          r = {
            ":Telescope orgmode refile_heading<CR>", "Refile heading"
          },
          l = { ":Telescope orgmode insert_link" },
          f = {
            {
              name = "Telescope",
              f = { ":Telescope find_files<CR>", "Find files" },
              g = { ":Telescope live_grep<CR>", "Grep files" },
              h = {
                ":Telescope orgmode search_headings<CR>",
                "Search headings"
              }
            },
            {
              name = "Fold levels",
              ["0"] = { ":set foldlevel=0<CR>", "Set fold lvl 0" },
              ["1"] = { ":set foldlevel=1<CR>", "Set fold lvl 1" },
              ["2"] = { ":set foldlevel=2<CR>", "Set fold lvl 2" },
              ["3"] = { ":set foldlevel=3<CR>", "Set fold lvl 3" },
              ["4"] = { ":set foldlevel=4<CR>", "Set fold lvl 4" },
              ["5"] = { ":set foldlevel=5<CR>", "Set fold lvl 5" },
              ["6"] = { ":set foldlevel=6<CR>", "Set fold lvl 6" },
              ["7"] = { ":set foldlevel=7<CR>", "Set fold lvl 7" },
              ["8"] = { ":set foldlevel=8<CR>", "Set fold lvl 8" },
              ["9"] = { ":set foldlevel=9<CR>", "Set fold lvl 9" },
            }
          },
        },
      }, { mode = "n" })

      -- Helper for sync scrolling and Diffing
      -- Mark current buffer for syncing view
      -- map("n", "<leader>wv", ":set scb<CR>")
      -- Mark current buffer for diffing
      -- map("n", "<leader>wd", ":diffthis<CR>")

      -- Visual Mode Bindings
      wk.register({
        {
          name = "Horizontal scrolling",
          zL = { "zL", "Scroll right "},
          zH = { "zH", "Scroll left "},
        },
        p = { '"_dP', "Better paste" },
        ["<"] = { "<gv", "Better decrease indent"},
        [">"] = { ">gv", "Better increase indent"},
        [";"] = { ":", "Command in visual mode" },
        f = {
          name = "Fold levels",
          ["0"] = { ":set foldlevel=0<CR>", "Set fold lvl 0" },
          ["1"] = { ":set foldlevel=1<CR>", "Set fold lvl 1" },
          ["2"] = { ":set foldlevel=2<CR>", "Set fold lvl 2" },
          ["3"] = { ":set foldlevel=3<CR>", "Set fold lvl 3" },
          ["4"] = { ":set foldlevel=4<CR>", "Set fold lvl 4" },
          ["5"] = { ":set foldlevel=5<CR>", "Set fold lvl 5" },
          ["6"] = { ":set foldlevel=6<CR>", "Set fold lvl 6" },
          ["7"] = { ":set foldlevel=7<CR>", "Set fold lvl 7" },
          ["8"] = { ":set foldlevel=8<CR>", "Set fold lvl 8" },
          ["9"] = { ":set foldlevel=9<CR>", "Set fold lvl 9" },
        },
        ["<C-L>"] = { ":Telescope orgmode insert_link" }
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
}
