local keymaps = require"core.keymaps"

return {
  {
    "folke/which-key.nvim",
    dependencies = {
      -- The which-key config imports cmp, cmp_nvim_lsp,
      -- and luasnip, which are all listed as dependencies
      -- of nvim-lspconfig.
      -- By importing here we get the whole chain of dependencies
      -- and get grab the keymaps.
      "neovim/nvim-lspconfig",
    },
    event = "VeryLazy",
    init = function()
      -- TODO do I want these options? move them to options
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- config here or leave empty for defaults
    },
    config = function()
      local wk = require"which-key"

      wk.register(
        vim.tbl_extend(
          "force",
          keymaps.normal,
          -- keymaps.lsp,
          -- keymaps.cmp,
          -- i mode bindings configured in the plugin config
          keymaps.telescope.which_key.normal
        ),
        { mode = "n" }
      )
      wk.register(
        vim.tbl_extend(
          "force",
          keymaps.visual,
          keymaps.telescope.which_key.visual
        ),
        { mode = "v" }
      )
    end,
  },
}
