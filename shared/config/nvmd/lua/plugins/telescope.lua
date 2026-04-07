return {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                          , branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim'
    },
    config = function()
        local telescope = require"telescope"
        telescope.setup {
            -- extensions = {
                -- ['ui-select'] = {
                    -- require('telescope.themes').get_dropdown { }
        }

        telescope.load_extension("ui-select")
    end
  },
  {
    "allaman/emoji.nvim",
    -- version = "1.0.0", -- optionally pin to a tag
    ft = "markdown", -- adjust to your needs
    dependencies = {
      -- optional for nvim-cmp integration
      "hrsh7th/nvim-cmp",
      -- optional for telescope integration
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      -- default is false, also needed for blink.cmp integration!
      enable_cmp_integration = true,
    },
    config = function(_, opts)
      require("emoji").setup(opts)
    end,
  }
}
