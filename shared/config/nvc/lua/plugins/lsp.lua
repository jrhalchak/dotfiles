local autocmds = require("config.autocmds")
local lspsetup = require("config.lspsetup")

return {
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  {
    "williamboman/mason-lspconfig.nvim",
    -- Stop race conditions when opening directly to an oil folder view
    dependencies = { "stevearc/oil.nvim" },
    config = function()
      autocmds.setup()
      lspsetup.setup()
    end
  },
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "saadparwaiz1/cmp_luasnip",
  "L3MON4D3/LuaSnip",
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    opts = {
      ensure_installed = "all",
      sync_install = false,
      auto_install = true,
      ignore_install = { "ipkg" },
      modules = {},
      highlight = {
        enable = true,
        disable = function(lang, buf)
          local max_filesize = 1000 * 1024
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      vim.treesitter.language.register("markdown", "mdx")
    end,
  }
}
