return {
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- Ensure it loads first
    config = function()
      require("tokyonight").setup {
        style = "night",
        transparent = true,
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { bold = true, italic = true },
          identifiers = { italic = true }, -- style for identifiers
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark", -- style for sidebars, see below
          floats = "dark", -- style for floating windows
        },
        dim_inactive = true,

        on_colors = function(colors)
          -- local util = require("tokyonight.util")

          -- aplugin.background = colors.bg_dark
          -- aplugin.my_error = util.lighten(colors.red1, 0.3) -- number between 0 and 1. 0 results in white, 1 results in red1
          -- colors = {
          --   yellow = color.darken("yellow", 7, "onelight"),
          --   orange = color.darken("orange", 7, "onelight"),
          --   comment_color = color.darken("gray", 10, "onelight"),
          --   -- my_new_green = "require('onedarkpro.helpers').darken('green', 10, 'onedark')"
          -- }
        end,
        on_highlights = function(highlights, colors)
          -- highlights = {
          --   Comment = { fg = "${comment_color}", italic = true, bold = true }
          --   CocFloating = { bg = "${white}" },
          --   CocFloatingBorder = { fg = "${gray}", bg = "${white}" },
          -- --   Error = {
          -- --     fg = "${my_new_red}",
          -- --     bg = "${my_new_green}"
          -- --   },
          -- }
        end
      }
      vim.cmd("colorscheme tokyonight-night")
    end
  },
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
        -- snippet = {
        --   -- REQUIRED - you must specify a snippet engine
        --   expand = function(args)
        --     -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        --     -- require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
        --     -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
        --     -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        --   end,
        -- },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
	  -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
        { "", group = "Win traversal" },
        { "", group = "Tab traversal" },
        { "", group = "Win resize" },
        { "", group = "quickfix" },
        { "", group = "Diagnostics" },
        { "", group = "Buffer switching" },
        { "", group = "Move lines" },
        { "-", ":Neotree current<CR>", desc = "Jump up to Netrw" },
        { "<A-H>", ":tabp<CR>", desc = "Previous tab" },
        { "<A-L>", ":tabn<CR>", desc = "Next tab" },
        { "<A-j>", "<Esc>:m .+1<CR>==gi", desc = "Move line up" },
        { "<A-k>", "<Esc>:m .-2<CR>==gi", desc = "Move line down" },
        { "<C-h>", "<C-w>h", desc = "Move left" },
        { "<C-j>", "<C-w>j", desc = "Move right" },
        { "<C-k>", "<C-w>k", desc = "Move up" },
        { "<C-l>", "<C-w>l", desc = "Move down" },
        { "<down>", ":resize +2<CR>", desc = "+/- Win v-size" },
        { "<leader>", group = "Explore with Neotree" },
        { "<leader>el", ":Neotree left<CR>", desc = "Explore (tree left)" },
        { "<leader>er", ":Neotree right<CR>", desc = "Explore (tree right)" },
        { "<leader>es", ":split | Neotree current<CR>", desc = "Explore (horizontal split)" },
        { "<leader>ev", ":vsplit | Neotree current<CR>", desc = "Explore (vertical split)" },
        { "<leader>ew", ":Neotree current<CR>", desc = 'Explore in window (also "-")' },
        { "<leader>fa", "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", desc = "find all" },
        { "<leader>fb", "<cmd> Telescope buffers <CR>", desc = "find buffers" },
        { "<leader>fch", "<cmd> Telescope command_history <CR>", desc = "command history" },
        { "<leader>fe", "<cmd> Telescope symbols <CR>", desc = "find emojis & symbols" },
        { "<leader>ff", "<cmd> Telescope find_files <CR>", desc = "find files" },
        { "<leader>fga", "<cmd> Telescope git_commits <CR>", desc = "all git commits" },
        { "<leader>fgc", "<cmd> Telescope git_bcommits <CR>", desc = "buffer git commits" },
        { "<leader>fgs", "<cmd> Telescope git_status <CR>", desc = "git status" },
        { "<leader>fh", "<cmd> Telescope help_tags <CR>", desc = "help page" },
        { "<leader>fll", "<cmd> Telescope loclist <CR>", desc = "loclist items" },
        { "<leader>fqf", "<cmd> Telescope quickfix <CR>", desc = "quickfix items" },
        { "<leader>fqfa", "<cmd> Telescope quickfixhistory <CR>", desc = "quickfix history" },
        { "<leader>fsh", "<cmd> Telescope search_history <CR>", desc = "search history" },
        { "<leader>fw", "<cmd> Telescope live_grep <CR>", desc = "live grep" },
        { "<leader>fz", "<cmd> Telescope current_buffer_fuzzy_find <CR>", desc = "find in current buffer" },
        { "<leader>g", group = "git" },
        { "<leader>gb", ":CocCommand git.showBlameDoc<CR>", desc = "git blame" },
        { "<leader>h", ":nohl<CR>", desc = "Clear highlights" },
        { "<leader>t", group = "Split Orientation" },
        { "<leader>th", "<C-w>t<C-w>H", desc = "H to V" },
        { "<leader>tk", "<C-w>t<C-w>K", desc = "V to H" },
        { "<left>", ":vertical resize -2<CR>", desc = "+/- Win h-size" },
        { "<right>", ":vertical resize +2<CR>", desc = "+/- Win h-size" },
        { "<up>", ":resize -2<CR>", desc = "+/- Win v-size" },
        { "H", ":bprevious<CR>", desc = "Previous buffer" },
        { "L", ":bnext<CR>", desc = "Next buffer" },
        { "[c", ":cprevious<CR>", desc = "previous" },
        { "]c", ":cnext<CR>", desc = "next" },
      })

      -- Helper for sync scrolling and Diffing
      -- Mark current buffer for syncing view
      -- map("n", "<leader>wv", ":set scb<CR>")
      -- Mark current buffer for diffing
      -- map("n", "<leader>wd", ":diffthis<CR>")

      -- Visual Mode Bindings
      wk.register({
        {
          mode = { "v" },
          { "", group = "Horizontal scrolling" },
          { ";", ":", desc = "Command in visual mode" },
          { "<", "<gv", desc = "Better decrease indent" },
          { "<leader>fgc", "<cmd> Telescope git_bcommits_range <CR>", desc = "(visual) range git commits" },
          { ">", ">gv", desc = "Better increase indent" },
          { "f", group = "Fold levels" },
          { "f0", ":set foldlevel=0<CR>", desc = "Set fold lvl 0" },
          { "f1", ":set foldlevel=1<CR>", desc = "Set fold lvl 1" },
          { "f2", ":set foldlevel=2<CR>", desc = "Set fold lvl 2" },
          { "f3", ":set foldlevel=3<CR>", desc = "Set fold lvl 3" },
          { "f4", ":set foldlevel=4<CR>", desc = "Set fold lvl 4" },
          { "f5", ":set foldlevel=5<CR>", desc = "Set fold lvl 5" },
          { "f6", ":set foldlevel=6<CR>", desc = "Set fold lvl 6" },
          { "f7", ":set foldlevel=7<CR>", desc = "Set fold lvl 7" },
          { "f8", ":set foldlevel=8<CR>", desc = "Set fold lvl 8" },
          { "f9", ":set foldlevel=9<CR>", desc = "Set fold lvl 9" },
          { "p", '"_dP', desc = "Better paste" },
          { "zH", "zH", desc = "Scroll left " },
          { "zL", "zL", desc = "Scroll right " },
        },
      })
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
