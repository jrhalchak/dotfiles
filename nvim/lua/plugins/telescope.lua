return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-symbols.nvim",
    },
    config = function()
      local keymaps = require"core.keymaps"

      require"telescope".setup {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          file_ignore_patterns = { ".git/", "node_modules" },

          mappings = {
            i = keymaps.telescope.get_mapping_presets(),
          },
        },
      }
    end,
  },
}
